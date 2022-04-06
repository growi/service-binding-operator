PETCLINIC_REPO ?= quay.io/service-binding
PETCLINIC_APP_IMAGE_NAME ?= spring-petclinic
PETCLINIC_APP_IMAGE ?= $(PETCLINIC_REPO)/$(PETCLINIC_APP_IMAGE_NAME):latest

PETCLINIC_OAUTH2_REPO ?= $(PETCLINIC_REPO)
PETCLINIC_OAUTH2_APP_IMAGE_NAME = $(PETCLINIC_APP_IMAGE_NAME)-oauth2
PETCLINIC_OAUTH2_APP_IMAGE ?= $(PETCLINIC_OAUTH2_REPO)/$(PETCLINIC_OAUTH2_APP_IMAGE_NAME):latest

MULTIARCH_PLATFORMS ?= linux/amd64,linux/arm64,linux/s390x,linux/ppc64le


.PHONY: build-app
build-app: build-app-base build-app-oauth2

.PHONY: push-app
push-app: push-app-base push-app-oauth2

.PHONY: build-app-multiarch
build-app-multiarch: build-app-base-multiarch build-app-oauth2-multiarch

.PHONY: push-app-multiarch
push-app-multiarch: push-app-base-multiarch push-app-oauth2multiarch

.PHONY: build-app-base
build-app-base:
	echo "Buiding $(PETCLINIC_APP_IMAGE)"
	docker build -f Dockerfile.app -t $(PETCLINIC_APP_IMAGE) .

.PHONY: push-app-base
push-app-base:
	docker push $(PETCLINIC_APP_IMAGE)

.PHONY: build-app-base-multiarch
build-app-base-multiarch:
	docker buildx build --platform "$(MULTIARCH_PLATFORMS)" -f Dockerfile.app -t $(PETCLINIC_APP_IMAGE) .

.PHONY: push-app-base-multiarch
push-app-base-multiarch:
	docker buildx build --push --platform "$(MULTIARCH_PLATFORMS)" -f Dockerfile.app -t $(PETCLINIC_APP_IMAGE) .

.PHONY: build-app-oauth2
build-app-oauth2:
	docker build -f Dockerfile.app -t $(PETCLINIC_OAUTH2_APP_IMAGE) --build-arg PETCLINIC_FEATURE=base,oauth2 .

.PHONY: push-app-oauth2
push-app-oauth2:
	docker push $(PETCLINIC_OAUTH2_APP_IMAGE)

.PHONY: build-app-oauth2-multiarch
build-app-oauth2-multiarch:
	docker buildx build --platform "$(MULTIARCH_PLATFORMS)" -f Dockerfile.app -t $(PETCLINIC_OAUTH2_APP_IMAGE) .

.PHONY: push-app-oauth2-multiarch
push-app-oauth2-multiarch:
	docker buildx build --push --platform "$(MULTIARCH_PLATFORMS)" -f Dockerfile.app -t $(PETCLINIC_OAUTH2_APP_IMAGE) .
