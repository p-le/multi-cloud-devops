IDP_SQL_PROJECT_ID	:= multicloud-architect-b5e6e149
IDP_SQL_TF_KEY		:= multicloud-architect-terraform-sa-key
IDP_SQL_TF_VERSION	:= 1
IDP_SQL_TF_SOURCE_DIR	:= /work/compute/idp-sql

.PHONY: idp-sql-gcloud-authenticate
idp-sql-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=idp-sql \
		PROJECT_ID=$(IDP_SQL_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(IDP_SQL_TF_VERSION) --secret=$(IDP_SQL_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(IDP_SQL_TF_KEY))

.PHONY: idp-sql-tf
idp-sql-tf:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(IDP_SQL_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(IDP_SQL_TF_SOURCE_DIR) $(TF_CMD)" \
		PROJECT_ID=$(IDP_SQL_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(IDP_SQL_TF_KEY))

.PHONE: idp-sql-setup
idp-sql-setup:
	cp -R $(BASE_PATH)/grpc/idp-sql/generated_pb2/api_descriptor.pb $(BASE_PATH)/gcp/compute/idp-sql/cloudrun/services/server/api_descriptor.pb
