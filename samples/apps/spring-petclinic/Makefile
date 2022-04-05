PETCLINIC_REPO ?= quay.io/service-binding/spring-petclinic
PETCLINIC_APP_IMAGE ?= $(PETCLINIC_REPO):latest
PETCLINIC_ENV_PROFILE ?= postgres

NAMESPACE ?= my-petclinic

MULTIARCH_PLATFORMS ?= linux/amd64,linux/arm64,linux/s390x,linux/ppc64le

# one of "openshift", "minikube"
KUBERNETES_RUNTIME ?= minikube

.PHONY: namespace
namespace:
ifeq ($(KUBERNETES_RUNTIME), openshift)
	-oc new-project $(NAMESPACE)
else ifeq ($(KUBERNETES_RUNTIME), minikube)
	-kubectl create namespace $(NAMESPACE)
	kubectl config set-context --current --namespace=$(NAMESPACE)
endif

.PHONY: deploy-keycloak
deploy-keycloak:
	kubectl apply -f keycloak-sample/keycloak-deployment.yaml -n $(NAMESPACE)

.PHONY: deploy-postgresql
deploy-postgresql:
	kubectl apply -f postgresql-sample/postgresql-deployment.yaml -n $(NAMESPACE)

.PHONY: deploy-pgcluster
deploy-pgcluster:
	kubectl apply -f pgcluster-sample/pgcluster-deployment.yaml -n $(NAMESPACE)

.PHONY: deploy-mysqlcluster
deploy-pgcluster:
	kubectl apply -f mysqlcluster-sample/mysqlcluster-deployment.yaml -n $(NAMESPACE)

.PHONY: build-app
build-app:
	docker build -f petclinic-app/build/Dockerfile.app -t $(PETCLINIC_APP_IMAGE) .

.PHONY: push-app
push-app:
	docker push $(PETCLINIC_APP_IMAGE)

.PHONY: build-app-multiarch
build-app-multiarch:
	docker buildx build --platform "$(MULTIARCH_PLATFORMS)" -f petclinic-app/build/Dockerfile.app -t $(PETCLINIC_APP_IMAGE) .

.PHONY: push-app-multiarch
push-app-multiarch:
	docker buildx build --push --platform "$(MULTIARCH_PLATFORMS)" -f petclinic-app/build/Dockerfile.app -t $(PETCLINIC_APP_IMAGE) .

.PHONY: deploy-app
deploy-app:
	sed -e 's,quay.io/service-binding/spring-petclinic:latest,'$(PETCLINIC_APP_IMAGE)',g' petclinic-app/petclinic-deployment.yaml | \
	sed -e 's,postgres,'$(PETCLINIC_ENV_PROFILE)',g' | \
	kubectl apply -f - -n $(NAMESPACE) --wait

.PHONY: bind-keycloak
bind-keycloak:
	kubectl apply -f keycloak-sample/petclinic-keycloak-binding.yaml -n $(NAMESPACE)

.PHONY: bind-postgresql
bind-postgresql:
	kubectl apply -f postgresql-sample/petclinic-postgresql-binding.yaml -n $(NAMESPACE)

.PHONY: bind-pgcluster
bind-pgcluster:
	kubectl apply -f pgcluster-sample/petclinic-pgcluster-binding.yaml -n $(NAMESPACE)

.PHONY: unbind-keycloak
unbind-keycloak:
	kubectl delete -f keycloak-sample/petclinic-keycloak-binding.yaml -n $(NAMESPACE)

.PHONY: unbind-postgresql
unbind-postgresql:
	kubectl delete -f postgresql-sample/petclinic-postgresql-binding.yaml -n $(NAMESPACE)

.PHONY: unbind-pgcluster
unbind-pgcluster:
	kubectl delete -f pgcluster-sample/petclinic-pgcluster-binding.yaml -n $(NAMESPACE)
