SYSTEM_PACKAGE_PROJECT_ID	:= multicloud-architect-b5e6e149
SYSTEM_PACKAGE_TF_KEY		:= multicloud-architect-terraform-sa-key
SYSTEM_PACKAGE_TF_VERSION	:= 1
SYSTEM_PACKAGE_TF_SRC_DIR	:= /work/compute/system-package

.PHONY: system-package-gcloud-authenticate
system-package-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=system-package \
		PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(SYSTEM_PACKAGE_TF_VERSION) --secret=$(SYSTEM_PACKAGE_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(SYSTEM_PACKAGE_TF_KEY))


.PHONY: system-package-tf-init
system-package-tf-init:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(SYSTEM_PACKAGE_TF_SRC_DIR) init" \
		PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(SYSTEM_PACKAGE_TF_KEY))


.PHONY: system-package-tf-plan
system-package-tf-plan:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(SYSTEM_PACKAGE_TF_SRC_DIR) plan" \
		PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(SYSTEM_PACKAGE_TF_KEY))

.PHONY: system-package-tf-apply
system-package-tf-apply:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(SYSTEM_PACKAGE_TF_SRC_DIR) apply" \
		PROJECT_ID=$(SYSTEM_PACKAGE_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(SYSTEM_PACKAGE_TF_KEY))
