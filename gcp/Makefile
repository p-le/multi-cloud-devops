.PHONY: gcp-deploy-management
gcp-deploy-management: DEPLOYMENT_NAME := iam-deployment
gcp-deploy-management: CONFIG_PATH := management/iam.yaml
gcp-deploy-management:
	# $(MAKE) gcloud-sdk ARG="deployment-manager deployments create $(DEPLOYMENT_NAME) --config $(CONFIG_PATH) --preview"
	$(MAKE) gcloud-sdk ARG="deployment-manager deployments create $(DEPLOYMENT_NAME) --config $(CONFIG_PATH)"


.PHONY: gcp-describe-management
gcp-describe-management: DEPLOYMENT_NAME := iam-deployment
gcp-describe-management:
	$(MAKE) gcloud-sdk ARG="deployment-manager deployments describe  $(DEPLOYMENT_NAME)"



.PHONY: gcloud-sdk
gcloud-sdk :
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcp:/work \
		-v ${BASE_PATH}/miscs/gcp/config:/gcloud/config \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		-w /work \
		google/cloud-sdk:${GCLOUD_SDK_VERSION} \
		gcloud $(ARG)

.PHONY: gcloud-authenticate
gcloud-authenticate :
	@$(MAKE) gcloud-sdk ARG="auth login"
	@$(MAKE) gcloud-sdk ARG="config set project multicloud-313515"
