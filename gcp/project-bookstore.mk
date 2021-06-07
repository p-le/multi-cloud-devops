BOOKSTORE_PROJECT_ID	:= multicloud-architect-b5e6e149
BOOKSTORE_TF_KEY		:= multicloud-architect-terraform-sa-key
BOOKSTORE_TF_VERSION	:= 1
BOOKSTORE_TF_SOURCE_DIR	:= /work/compute/bookstore

.PHONY: bookstore-gcloud-authenticate
bookstore-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=bookstore \
		PROJECT_ID=$(BOOKSTORE_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(BOOKSTORE_TF_VERSION) --secret=$(BOOKSTORE_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(BOOKSTORE_TF_KEY))

.PHONY: bookstore-tf
bookstore-tf:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(BOOKSTORE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(BOOKSTORE_TF_SOURCE_DIR) $(TF_CMD)" \
		CREDENTIAL_FILE=$(addsuffix .json, $(BOOKSTORE_TF_KEY))

.PHONE: bookstore-setup
bookstore-setup:
	cp -R $(BASE_PATH)/grpc/bookstore/generated_pb2/api_descriptor.pb $(BASE_PATH)/gcp/compute/bookstore/cloudrun/services/server/api_descriptor.pb
