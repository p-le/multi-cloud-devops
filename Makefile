BASE_PATH 			:= $(shell pwd)
TERRAFORM_VERSION	:= 0.15.3
AWS_CLI_VERSION		:= 2.1.39
GCLOUD_SDK_VERSION 	:= 341.0.0
KUBECTL_VERSION		:= 1.21.1

include $(BASE_PATH)/aws/Makefile
include $(BASE_PATH)/gcp/Makefile
include $(BASE_PATH)/azure/Makefile
