ORGANIZATION_GCLOUD_CONFIGURATION=organization-management
ORGANIZATION_SOURCE_DIR=/work/organization
ORGANIZATION_CREDENTIAL_FILE=organization-manager-key.json

.PHONY: gcp-tf-organization-configuration
gcp-tf-organization-configuration:
	@$(MAKE) gcloud-sdk ARG="config configurations activate $(ORGANIZATION_GCLOUD_CONFIGURATION)"

.PHONY: gcp-tf-organization-init
gcp-tf-organization-init: gcp-tf-organization-configuration
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(ORGANIZATION_SOURCE_DIR) init" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)


.PHONY: gcp-tf-organization-plan
gcp-tf-organization-plan: gcp-tf-organization-configuration
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(ORGANIZATION_SOURCE_DIR) plan" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)


.PHONY: gcp-tf-organization-apply
gcp-tf-organization-apply: gcp-tf-organization-configuration
	@$(MAKE) gcloud-terraform-sdk \
		ARG="-chdir=$(ORGANIZATION_SOURCE_DIR) apply" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)
