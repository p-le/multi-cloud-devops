ANTHOS_PROJECT_ID	:= multicloud-architect-b5e6e149
ANTHOS_TF_KEY		:= multicloud-architect-terraform-sa-key
ANTHOS_TF_VERSION	:= 1
ANTHOS_TF_SRC_DIR	:= /work/compute/anthos

.PHONY: anthos-gcloud-authenticate
anthos-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=anthos \
		PROJECT_ID=$(ANTHOS_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(ANTHOS_TF_VERSION) --secret=$(ANTHOS_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(ANTHOS_TF_KEY))

.PHONY: anthos-kubectl-context
anthos-kubectl-context: CLUSTER_NAME := anthos-cloud-run-cluster-0e02
anthos-kubectl-context:
	@$(MAKE) gcloud-sdk CMD="gcloud container clusters get-credentials --region $(REGION) $(CLUSTER_NAME)"

.PHONY: anthos-tf
anthos-tf:
	$(MAKE) gcloud-activate-configuration PROJECT_ID=$(ANTHOS_PROJECT_ID)
	$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(ANTHOS_TF_SRC_DIR) $(TF_CMD)" \
		PROJECT_ID=$(ANTHOS_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(ANTHOS_TF_KEY))
