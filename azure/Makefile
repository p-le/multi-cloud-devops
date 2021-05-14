.PHONY: azcli
azcli: AZURE_CLI_VERSION := 2.9.1 # https://mcr.microsoft.com/v2/azure-cli/tags/list
azcli:
	docker container run -it --rm \
		mcr.microsoft.com/azure-cli:${AZURE_CLI_VERSION} \
			az version
