# platform-service

An HTTP service and the AWS infrastructure to run it.

The service is deliberately small — it returns a greeting. The substance of
this repository is everything around it: how a new laptop gets to a running
deployment, and how the infrastructure is defined, deployed and torn down.

```
$ curl http://<load-balancer>/
{"message":"Hello from platform-service","instance":"ip-10-0-10-31.eu-west-1.compute.internal"}
```

The `instance` field is the container that served the request. With two tasks
running, repeated calls return different values — the simplest way to see that
load balancing is working.

---

## Quick start

**Prerequisites:** a Mac, an AWS account, and [Homebrew](https://brew.sh).
Everything else is installed in step 1.

### 1. Install the toolchain

```bash
brew bundle          # terraform, aws cli, colima, docker, jdk 21
colima start         # starts the container runtime
```

Homebrew does not link `openjdk@21` automatically, so add it to your shell:

```bash
echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@21"' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
exec zsh
```

### 2. Run it locally

```bash
make run                      # starts on :8080
curl localhost:8080/
make test
```

Nothing above touches AWS. Stop here if you only want to see the service run.

### 3. Connect to AWS

```bash
aws configure sso --profile service-dev
aws sso login --profile service-dev
aws sts get-caller-identity        # must succeed before continuing
```

Any AWS credentials work — SSO is what this was built with, but the Makefile
only requires that `aws sts get-caller-identity` returns something. Use a
different profile with `AWS_PROFILE=my-profile make deploy`.

### 4. Deploy

```bash
make bootstrap     # once per AWS account, ~30 seconds
make deploy        # ~8 minutes, prints the URL when finished
```

### 5. Tear down

```bash
make destroy
```

**Do not skip this.** The NAT gateway and load balancer bill hourly whether or
not any traffic arrives; this stack is not free tier.

`make help` lists every shortcut.

---

## Architecture

```
                            internet
                               │
                         ┌─────▼─────┐
                         │ Internet  │
                         │  Gateway  │
                         └─────┬─────┘
  ═══════════════════════════ VPC 10.0.0.0/16 ══════════════════════
                               │
   public 10.0.0.0/24          │            public 10.0.1.0/24
   ┌───────────────────────────▼──────────────────────────────────┐
   │                Application Load Balancer :80                  │
   └────────┬─────────────────────────────────────┬───────────────┘
   ┌────────▼────────┐                            │ :8080
   │   NAT Gateway   │                            │
   └────────▲────────┘                            │
            │ outbound only                       │
   private 10.0.10.0/24                  private 10.0.11.0/24
   ┌────────┴────────┐                   ┌────────▼────────┐
   │  Fargate task   │                   │  Fargate task   │
   │  ARM64, no      │                   │  ARM64, no      │
   │  public IP      │                   │  public IP      │
   └────────┬────────┘                   └────────┬────────┘
  ══════════╪═════════════════════════════════════╪═════════════════
            │            image pull               │
            └──────────────────┬──────────────────┘
                               ▼
                              ECR
```

**Two availability zones**, because an Application Load Balancer requires a
minimum of two.

**The tasks are not reachable from the internet.** They have no public IP, and
their security group accepts traffic only from the load balancer's security
group — referenced as a security group, not a CIDR range, so the rule stays
correct if addresses change. There is no route from the internet to a task;
not a blocked route, an absent one.

**Outbound traffic goes through the NAT gateway.** The tasks still need to
reach ECR to pull their image, and a NAT gateway is what gives a private
subnet outbound-only internet access.

---

## Assumptions

Listed because the brief asks for them, and because each one is a place a real
team would likely decide differently.

**Scope**

- One environment, one region (`eu-west-1`).

**Access**

- AWS access is via IAM Identity Center (SSO) with a profile named
  `service-dev`. Any working credentials are fine; the Makefile only requires
  that `aws sts get-caller-identity` succeeds.
- The deployer has broad AWS permissions, since Terraform creates VPCs, IAM
  roles and load balancers. In production, applies would run through a CI role
  with a narrower policy rather than a human's admin session.
- Deployed into the AWS Organization's management account, which AWS advises
  against. Production would use a dedicated workload account per environment.

**Security**

- **HTTP, not HTTPS.** TLS requires a certificate, which requires a domain.
  Nothing sensitive should go through this listener.
- **Network ACLs are left at their permissive default.** Isolation comes from
  route tables and security groups. NACLs are stateless and, for this topology,
  would block nothing the security groups do not already block.

**Operations**

- **No log aggregation.** Container output is not shipped anywhere. Tasks run
  fine without it, but a container that fails on startup leaves nothing to
  read. This is the first thing to add.
- **No CI pipeline.** The Makefile is the deployment process and runs
  identically on a laptop or a runner. A pipeline would call `make deploy`,
  authenticating with OIDC rather than stored credentials. An untested workflow
  file is worth less than a process that demonstrably works.
- **A single NAT gateway**, not one per availability zone. It is a single point
  of failure for outbound traffic, and a deliberate trade: a second costs about
  $32/month for a service with no availability target yet.
