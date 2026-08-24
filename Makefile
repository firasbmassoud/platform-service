.PHONY: help setup run test build bootstrap init push plan deploy destroy fmt

NAME     := platform-service
REGION   := eu-west-1

# Override with: AWS_PROFILE=my-profile make deploy
AWS_PROFILE ?= service-dev
export AWS_PROFILE
export AWS_REGION = $(REGION)
TAG      := $(shell git rev-parse --short HEAD)

# Lazy (=) rather than immediate (:=) so the local targets work with no AWS session.
ACCOUNT   = $(shell AWS_PROFILE=$(AWS_PROFILE) aws sts get-caller-identity --query Account --output text)
REGISTRY  = $(ACCOUNT).dkr.ecr.$(REGION).amazonaws.com

TF       := terraform -chdir=infra/main

help:  ## Show this help
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

setup:  ## Install the toolchain
	brew bundle

run:  ## Run the service locally on :8080
	cd app && ./mvnw spring-boot:run

test:  ## Run the tests
	cd app && ./mvnw test

build:  ## Build the container image locally
	docker buildx build --platform linux/arm64 -t $(NAME):local --load app

bootstrap:  ## Create the state bucket and registry (once per AWS account)
	terraform -chdir=infra/bootstrap init -input=false
	terraform -chdir=infra/bootstrap apply -input=false -auto-approve

init:  ## Point the Terraform backend at this account's state bucket
	$(TF) init -input=false -reconfigure \
	  -backend-config="bucket=$(NAME)-tfstate-$(ACCOUNT)" \
	  -backend-config="key=main/terraform.tfstate" \
	  -backend-config="region=$(REGION)"

push:  ## Build the image and push it to ECR, tagged with the git SHA
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(REGISTRY)
	docker buildx build --platform linux/arm64 -t $(REGISTRY)/$(NAME):$(TAG) --push app

plan: init  ## Show what a deploy would change, without applying
	$(TF) plan -var image_tag=$(TAG)

deploy: push init  ## Build, push and deploy
	$(TF) apply -input=false -auto-approve -var image_tag=$(TAG)
	@echo
	@echo "Deployed $(TAG) to $$($(TF) output -raw service_url)"

destroy: init  ## Tear down the application infrastructure
	$(TF) destroy -input=false -auto-approve -var image_tag=unused

fmt:  ## Format the Terraform
	terraform fmt -recursive infra/
