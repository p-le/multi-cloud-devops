.PHONY: awscli
awscli:
	@docker container run -it --rm \
		-v $(BASE_PATH)/aws/config:/root/.aws \
		-v $(BASE_PATH)/aws/cloudformation:/cloudformation \
		amazon/aws-cli:$(AWS_CLI_VERSION) \
			$(ARG)

.PHONY: aws-download-credentials
aws-download-credentials:
	$(MAKE) awscli ARG="--profile terraform s3 cp s3://phule-credentials/credentials ${BASE_PATH}/aws/config/"

include $(BASE_PATH)/aws/terraform/Makefile
include $(BASE_PATH)/aws/cloudformation/Makefile
