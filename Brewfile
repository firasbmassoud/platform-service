# Everything needed to build, run and deploy this service.
# Install with: brew bundle

tap "hashicorp/tap"

brew "hashicorp/tap/terraform"
brew "awscli"

# Colima rather than Docker Desktop: no licence restrictions for commercial
# use, and it is a CLI-only dependency. Start it with `colima start`.
brew "colima"
brew "docker"
brew "docker-buildx"

# Only needed to run the service outside a container. The Maven wrapper
# (./mvnw) handles Maven itself, so Maven is not listed here.
brew "openjdk@21"
