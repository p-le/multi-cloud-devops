VIET_OCR_STAGE_PROJECT_ID	:= viet-ocr-stage-8650711b
VIET_OCR_STAGE_PROJECT_NAME	:= viet-ocr-stage
VIET_OCR_STAGE_TF_KEY			:= viet-ocr-stage-terraform-sa-key # Secret Manager Key
VIET_OCR_STAGE_TF_KEY_VERSION	:= 1	# Secret Manager Version
VIET_OCR_STAGE_TF_SOURCE_DIR	:= /work/compute/viet-ocr-stage


.PHONY: gcp-configuration-viet-ocr-stage
gcp-configuration-viet-ocr-stage:
	@$(MAKE) gcloud-sdk ARG="config set project $(VIET_OCR_STAGE_PROJECT_ID)"


.PHONY: gcloud-authenticate-viet-ocr-stage
gcloud-authenticate-viet-ocr-stage:
	@$(MAKE) gcloud-sdk ARG="config configurations create $(VIET_OCR_STAGE_PROJECT_NAME)"
	@$(MAKE) gcloud-sdk ARG="auth login"
	@$(MAKE) gcp-configuration-viet-ocr-stage
	@$(MAKE) gcloud-sdk ARG="secrets versions access $(VIET_OCR_STAGE_TF_KEY_VERSION) --secret=$(VIET_OCR_STAGE_TF_KEY)" > ./miscs/gcp/credentials/$(VIET_OCR_STAGE_TF_KEY).json


.PHONY: gcp-tf-viet-ocr-stage-init
gcp-tf-viet-ocr-stage-init: gcp-configuration-viet-ocr-stage
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) init" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONY: gcp-tf-viet-ocr-stage-plan
gcp-tf-viet-ocr-stage-plan: gcp-configuration-viet-ocr-stage
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) plan" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))


.PHONY: gcp-tf-viet-ocr-stage-apply
gcp-tf-viet-ocr-stage-apply: gcp-configuration-viet-ocr-stage
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(VIET_OCR_STAGE_TF_SOURCE_DIR) apply" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_OCR_STAGE_TF_KEY))
