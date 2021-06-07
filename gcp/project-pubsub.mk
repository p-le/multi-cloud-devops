PUBSUB_PROJECT_ID	:= multicloud-architect-b5e6e149
PUBSUB_TF_KEY		:= multicloud-architect-terraform-sa-key
PUBSUB_TF_VERSION	:= 1
PUBSUB_TF_SRC_DIR	:= /work/compute/pubsub

.PHONY: pubsub-gcloud-authenticate
pubsub-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=pubsub \
		PROJECT_ID=$(PUBSUB_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(PUBSUB_TF_VERSION) --secret=$(PUBSUB_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(PUBSUB_TF_KEY))


.PHONY: pubsub-tf
pubsub-tf:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(PUBSUB_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(PUBSUB_TF_SRC_DIR) $(TF_CMD)" \
		PROJECT_ID=$(PUBSUB_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(PUBSUB_TF_KEY))
