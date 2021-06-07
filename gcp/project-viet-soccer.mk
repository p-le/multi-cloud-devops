VIET_SOCCER_PROJECT_ID		:= multicloud-architect-b5e6e149
VIET_SOCCER_TF_KEY		:= multicloud-architect-terraform-sa-key
VIET_SOCCER_TF_SOURCE_DIR	:= /work/compute/viet-soccer

.PHONY: viet-soccer-tf
viet-soccer-tf:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(VIET_SOCCER_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(VIET_SOCCER_TF_SOURCE_DIR) $(TF_CMD)" \
		CREDENTIAL_FILE=$(addsuffix .json, $(VIET_SOCCER_TF_KEY))
