VIET_OCR_STAGE_PROJECT_ID	:= viet-ocr-stage-8650711b
VIET_OCR_STAGE_PROJECT_NAME	:= viet-ocr-stage
VIET_OCR_STAGE_TF_KEY			:= viet-ocr-stage-terraform-sa-key # Secret Manager Key
VIET_OCR_STAGE_TF_KEY_VERSION	:= 1	# Secret Manager Version
VIET_OCR_STAGE_TF_SOURCE_DIR	:= /work/compute/viet-ocr-stage


.PHONY: gcloud-authenticate-$(VIET_OCR_STAGE_PROJECT_NAME)
gcloud-authenticate-$(VIET_OCR_STAGE_PROJECT_NAME):
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=$(VIET_OCR_STAGE_PROJECT_NAME) \
		PROJECT_ID=$(VIET_OCR_STAGE_PROJECT_ID)
	@$(MAKE) gcloud-sdk ARG="secrets versions access $(VIET_OCR_STAGE_TF_KEY_VERSION) --secret=$(VIET_OCR_STAGE_TF_KEY)" > ./miscs/gcp/credentials/$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONY: gcp-tf-$(VIET_OCR_STAGE_PROJECT_NAME)-init
gcp-tf-$(VIET_OCR_STAGE_PROJECT_NAME)-init:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(VIET_OCR_STAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) init" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONY: gcp-tf-$(VIET_OCR_STAGE_PROJECT_NAME)-plan
gcp-tf-$(VIET_OCR_STAGE_PROJECT_NAME)-plan:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(VIET_OCR_STAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) plan" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONY: gcp-tf-$(VIET_OCR_STAGE_PROJECT_NAME)-apply
gcp-tf-$(VIET_OCR_STAGE_PROJECT_NAME)-apply:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(VIET_OCR_STAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) apply" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))
