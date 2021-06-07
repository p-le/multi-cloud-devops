K8S_PROJECT_ID	:= multicloud-architect-b5e6e149
K8S_TF_KEY		:= multicloud-architect-terraform-sa-key
K8S_TF_VERSION	:= 1
K8S_TF_SRC_DIR	:= /work/compute/k8s

.PHONY: k8s-gcloud-authenticate
k8s-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=anthos \
		PROJECT_ID=$(K8S_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(K8S_TF_VERSION) --secret=$(K8S_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(K8S_TF_KEY))

.PHONY: k8s-kubectl-context
k8s-kubectl-context: CLUSTER_NAME := k8s-cloud-run-cluster-0e02
k8s-kubectl-context:
	@$(MAKE) gcloud-sdk CMD="gcloud container clusters get-credentials --region $(REGION) $(CLUSTER_NAME)"

.PHONY: k8s-tf
k8s-tf:
	$(MAKE) gcloud-activate-configuration PROJECT_ID=$(K8S_PROJECT_ID)
	$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(K8S_TF_SRC_DIR) $(TF_CMD)" \
		PROJECT_ID=$(K8S_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(K8S_TF_KEY))
