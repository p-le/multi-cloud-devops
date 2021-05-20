WORKFLOW_PROJECT_ID	:= multicloud-architect-b5e6e149
WORKFLOW_TF_KEY		:= multicloud-architect-terraform-sa-key
WORKFLOW_TF_VERSION	:= 1
WORKFLOW_TF_SRC_DIR	:= /work/compute/workflow

.PHONY: workflow-gcloud-authenticate
workflow-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=workflow \
		PROJECT_ID=$(WORKFLOW_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(WORKFLOW_TF_VERSION) --secret=$(WORKFLOW_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(WORKFLOW_TF_KEY))


.PHONY: workflow-tf-init
workflow-tf-init:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(WORKFLOW_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(WORKFLOW_TF_SRC_DIR) init" \
		PROJECT_ID=$(WORKFLOW_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(WORKFLOW_TF_KEY))


.PHONY: workflow-tf-plan
workflow-tf-plan:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(WORKFLOW_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(WORKFLOW_TF_SRC_DIR) plan" \
		PROJECT_ID=$(WORKFLOW_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(WORKFLOW_TF_KEY))

.PHONY: workflow-tf-apply
workflow-tf-apply:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(WORKFLOW_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(WORKFLOW_TF_SRC_DIR) apply" \
		PROJECT_ID=$(WORKFLOW_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(WORKFLOW_TF_KEY))
