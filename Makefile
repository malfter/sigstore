# Used by `image`, `push` & `deploy` targets, override as required
IMAGE_REG ?= localhost:5000
IMAGE_REPO ?= malfter/sigstore/hello-sigstore
IMAGE_TAG ?= latest

.DEFAULT_GOAL := help

.PHONY: help
help:  ## 💬 This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: local
local:  ## 🏗  Creates a local environment for tests
	docker compose up -d

.PHONY: lint
lint:  ## 🔎 Lint & format, will not fix but sets exit code on error
	# Lint docker-compose.yml
	docker run -t --rm -v ${PWD}:/app zavoloklom/dclint .
	# Lint Dockerfile(s)
	docker run --rm -i hadolint/hadolint < hello-sigstore/Dockerfile
	docker run --rm -i hadolint/hadolint < .devcontainer/Dockerfile

.PHONY: lint-fix
lint-fix:  ## 📜 Lint & format, will try to fix errors and modify code
	docker run -t --rm -v ${PWD}:/app zavoloklom/dclint . --fix

.PHONY: build
build:  ## 🔨 Build container image from Dockerfile
	docker build . --file hello-sigstore/Dockerfile \
	--tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: scan
scan:  ## 🔍️ Scan container image with trivy
	command -v trivy || bin install -f https://github.com/aquasecurity/trivy
	trivy --version
	# Prints full report
	trivy image --exit-code 0 --no-progress $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)
	# Fail on critical vulnerabilities
	trivy image --exit-code 1 --severity CRITICAL --no-progress $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: pull
pull:  ## 📥 Pull container image from registry
	docker pull $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: ci-tag-image
ci-tag-image:  ## 🏷️  Tag container image to final tag
	docker tag $(IMAGE_REG)/$(IMAGE_REPO):$(CI_IMAGE_TAG) $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: tag-latest
tag-latest:  ## 🏷️  Tag container image as latest
	docker tag $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG) $(IMAGE_REG)/$(IMAGE_REPO):latest

.PHONY: push
push:  ## 📤 Push container image to registry
	docker push $(IMAGE_REG)/$(IMAGE_REPO):$(IMAGE_TAG)

.PHONY: push-latest
push-latest:  ## 📤 Push container image to registry (tag: latest)
	docker push $(IMAGE_REG)/$(IMAGE_REPO):latest

.PHONY: clean
clean:  ## 🧹 Clean up project
	docker compose down -v
	rm -rf ./oci-registry
