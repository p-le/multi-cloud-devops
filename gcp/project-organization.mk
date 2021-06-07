ORGANIZATION_GCLOUD_CONFIGURATION=organization-management
ORGANIZATION_SOURCE_DIR=/work/organization
ORGANIZATION_CREDENTIAL_FILE=organization-manager-key.json

.PHONY: organization-gcloud-configuration
organization-gcloud-configuration:
	@$(MAKE) gcloud-sdk CMD="gcloud config configurations activate $(ORGANIZATION_GCLOUD_CONFIGURATION)"

.PHONY: organization-tf
organization-tf: organization-gcloud-configuration
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(ORGANIZATION_SOURCE_DIR) $(TF_CMD)" \
		CREDENTIAL_FILE=$(ORGANIZATION_CREDENTIAL_FILE)
