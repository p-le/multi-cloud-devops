STORAGE_PROJECT_ID	:= multicloud-architect-b5e6e149
STORAGE_TF_KEY		:= multicloud-architect-terraform-sa-key
STORAGE_TF_VERSION	:= 1
STORAGE_TF_SRC_DIR	:= /work/storage

.PHONY: storage-gcloud-authenticate
storage-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=storage \
		PROJECT_ID=$(STORAGE_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(STORAGE_TF_VERSION) --secret=$(STORAGE_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(STORAGE_TF_KEY))

.PHONY: storage-tf
storage-tf:
	$(MAKE) gcloud-activate-configuration PROJECT_ID=$(STORAGE_PROJECT_ID)
	$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(STORAGE_TF_SRC_DIR) $(TF_CMD)" \
		PROJECT_ID=$(STORAGE_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(STORAGE_TF_KEY))
