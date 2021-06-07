VIET_OCR_STAGE_PROJECT_ID	:= viet-ocr-stage-8650711b
VIET_OCR_STAGE_PROJECT_NAME	:= viet-ocr-stage
VIET_OCR_STAGE_TF_KEY			:= viet-ocr-stage-terraform-sa-key # Secret Manager Key
VIET_OCR_STAGE_TF_KEY_VERSION	:= 1	# Secret Manager Version
VIET_OCR_STAGE_TF_SOURCE_DIR	:= /work/compute/viet-ocr-stage


.PHONY: $(VIET_OCR_STAGE_PROJECT_NAME)-gcloud-authenticate
$(VIET_OCR_STAGE_PROJECT_NAME)-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=$(VIET_OCR_STAGE_PROJECT_NAME) \
		PROJECT_ID=$(VIET_OCR_STAGE_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(VIET_OCR_STAGE_TF_KEY_VERSION) --secret=$(VIET_OCR_STAGE_TF_KEY)" > ./miscs/gcp/credentials/$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONY: $(VIET_OCR_STAGE_PROJECT_NAME)-tf
$(VIET_OCR_STAGE_PROJECT_NAME)-tf-init:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(VIET_OCR_STAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) $(TF_CMD)" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONE: $(VIET_OCR_STAGE_PROJECT_NAME)-setup
$(VIET_OCR_STAGE_PROJECT_NAME)-setup:
	mkdir -p $(BASE_PATH)/gcp/compute/viet-ocr-stage/cloudrun/services/viet-ocr-espv2/protos/
	cp -R $(BASE_PATH)/grpc/helloworld $(BASE_PATH)/gcp/compute/viet-ocr-stage/cloudrun/services/viet-ocr-espv2/protos/helloworld
	mkdir -p $(BASE_PATH)/gcp/compute/viet-ocr-stage/cloudrun/services/viet-ocr-backend/protos/
	cp -R $(BASE_PATH)/grpc/helloworld $(BASE_PATH)/gcp/compute/viet-ocr-stage/cloudrun/services/viet-ocr-backend/protos/helloworld
