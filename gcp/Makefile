.PHONY: gcloud
gcloud: GCLOUD_CLI_VERSION := 337.0.0 # https://hub.docker.com/r/google/cloud-sdk/tags
gcloud:
	@docker container run -it --rm \
		-v ${BASE_PATH}/gcloud/config:/gcloud/config \
		-v ${BASE_PATH}/gcloud/certs:/certs \
		-e CLOUDSDK_CONFIG=/gcloud/config \
		google/cloud-sdk:${GCLOUD_CLI_VERSION} \
		gcloud $(ARG)
