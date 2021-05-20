.PHONY: gcp-deploy-gcs-create
gcp-deploy-gcs-create: DEPLOYMENT_NAME := gcs-deployment
gcp-deploy-gcs-create: CONFIG_PATH := storage/gcs/buckets.yaml
gcp-deploy-gcs-create:
	$(MAKE) gcloud-sdk CMD="gcloud deployment-manager deployments create $(DEPLOYMENT_NAME) --config $(CONFIG_PATH)"

.PHONY: gcp-deploy-gcs-update
gcp-deploy-gcs-update: DEPLOYMENT_NAME := gcs-deployment
gcp-deploy-gcs-update: CONFIG_PATH := storage/gcs/buckets.yaml
gcp-deploy-gcs-update:
	$(MAKE) gcloud-sdk CMD="gcloud deployment-manager deployments update $(DEPLOYMENT_NAME) --config $(CONFIG_PATH)"


.PHONY: gcp-deploy-management-basic-create
gcp-deploy-management-basic-create: DEPLOYMENT_NAME := basic-service-accounts-deployment
gcp-deploy-management-basic-create: CONFIG_PATH := management/basic-iam/service_accounts.yaml
gcp-deploy-management-basic-create:
	$(MAKE) gcloud-sdk CMD="gcloud deployment-manager deployments create $(DEPLOYMENT_NAME) --config $(CONFIG_PATH)"


.PHONY: gcp-deploy-management-basic-update
gcp-deploy-management-basic-update: DEPLOYMENT_NAME := basic-service-accounts-deployment
gcp-deploy-management-basic-update: CONFIG_PATH := management/basic-iam/service_accounts.yaml
gcp-deploy-management-basic-update:
	$(MAKE) gcloud-sdk CMD="gcloud deployment-manager deployments update $(DEPLOYMENT_NAME) --config $(CONFIG_PATH)"


.PHONY: build-gcloud-sdk-image
build-gcloud-sdk-image:
	@cd gcp/gcloud-sdk && \
		docker image build \
			-t cloud-sdk:$(GCLOUD_SDK_VERSION) \
			--build-arg GCLOUD_SDK_VERSION=$(GCLOUD_SDK_VERSION) .

.PHONY: gcloud-build-terraform-image
gcloud-build-terraform-image:
	@cd gcp/gcloud-sdk && docker image build \
		-f Dockerfile.terraform \
		--build-arg GCLOUD_SDK_VERSION=$(GCLOUD_SDK_VERSION) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		-t cloud-sdk-terraform:$(GCLOUD_SDK_VERSION)_$(TERRAFORM_VERSION) \
		.


.PHONY: gcloud-generate-terraform-key
gcloud-generate-terraform-key:
	@$(MAKE) gcloud-sdk CMD="gcloud iam service-accounts keys create /gcloud/credentials/terraform-key.json --iam-account=provisioner-terraform@multicloud-313515.iam.gserviceaccount.com"

.PHONY: gcloud-sdk
gcloud-sdk:
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcp:/work \
		-v ${BASE_PATH}/miscs/gcp/config:/gcloud/config \
		-v ${BASE_PATH}/miscs/gcp/credentials:/gcloud/credentials \
		$(ADDITIONAL_VOLUMES) \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		cloud-sdk:${GCLOUD_SDK_VERSION} $(CMD)

.PHONY: gcloud-terraform-sdk
gcloud-terraform-sdk:
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcp:/work \
		-v ${BASE_PATH}/miscs/gcp/config:/gcloud/config \
		-v ${BASE_PATH}/miscs/gcp/credentials:/gcloud/credentials \
		$(ADDITIONAL_VOLUMES) \
		-e GOOGLE_PROJECT=$(PROJECT_ID) \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		-e GOOGLE_APPLICATION_CREDENTIALS=/gcloud/credentials/$(CREDENTIAL_FILE) \
		cloud-sdk-terraform:$(GCLOUD_SDK_VERSION)_$(TERRAFORM_VERSION) $(CMD)

.PHONY: gcloud-activate-configuration
gcloud-activate-configuration:
	@$(MAKE) gcloud-sdk CMD="gcloud config set project $(PROJECT_ID)"

.PHONY: gcloud-authenticate
gcloud-authenticate:
	@$(MAKE) gcloud-sdk CMD="gcloud config configurations create $(CONFIGURATION_NAME) --activate"
	@$(MAKE) gcloud-sdk CMD="gcloud auth login"
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(PROJECT_ID)

.PHONY: gcloud-configurations
gcloud-configurations:
	@$(MAKE) gcloud-sdk CMD="gcloud config configurations list"

include $(BASE_PATH)/gcp/project-organization.mk
include $(BASE_PATH)/gcp/project-viet-ocr.mk
include $(BASE_PATH)/gcp/project-bookstore.mk
include $(BASE_PATH)/gcp/project-idp-sql.mk
include $(BASE_PATH)/gcp/project-pubsub.mk
include $(BASE_PATH)/gcp/project-system-package.mk
include $(BASE_PATH)/gcp/project-workflow.mk
