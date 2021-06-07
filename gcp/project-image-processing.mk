IMAGE_PROCESSING_PROJECT_ID	:= multicloud-architect-b5e6e149
IMAGE_PROCESSING_TF_KEY		:= multicloud-architect-terraform-sa-key
IMAGE_PROCESSING_TF_VERSION	:= 1
IMAGE_PROCESSING_TF_SRC_DIR	:= /work/compute/image-processing

.PHONY: image-processing-gcloud-authenticate
image-processing-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=image-processing \
		PROJECT_ID=$(IMAGE_PROCESSING_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(IMAGE_PROCESSING_TF_VERSION) --secret=$(IMAGE_PROCESSING_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(IMAGE_PROCESSING_TF_KEY))


.PHONY: image-processing-tf
image-processing-tf:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(IMAGE_PROCESSING_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(IMAGE_PROCESSING_TF_SRC_DIR) $(TF_CMD)" \
		PROJECT_ID=$(IMAGE_PROCESSING_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(IMAGE_PROCESSING_TF_KEY))
