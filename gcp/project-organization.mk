ORGANIZATION_GCLOUD_CONFIGURATION=organization-management
ORGANIZATION_SOURCE_DIR=/work/organization
ORGANIZATION_CREDENTIAL_FILE=organization-manager-key.json

.PHONY: organization-gcloud-configuration
organization-gcloud-configuration:
	@$(MAKE) gcloud-sdk ARG="config configurations activate $(ORGANIZATION_GCLOUD_CONFIGURATION)"

.PHONY: organization-tf-init
organization-tf-init: organization-gcloud-configuration
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(ORGANIZATION_SOURCE_DIR) init" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)


.PHONY: organization-tf-plan
organization-tf-plan: organization-gcloud-configuration
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(ORGANIZATION_SOURCE_DIR) plan" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)


.PHONY: organization-tf-apply
organization-tf-apply: organization-gcloud-configuration
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(ORGANIZATION_SOURCE_DIR) apply" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)
