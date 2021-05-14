TERRAFORM_VERSION 		:= 0.15.1
BASE_PATH 				:= $(shell pwd)

include $(BASE_PATH)/aws/Makefile
include $(BASE_PATH)/gcp/Makefile
include $(BASE_PATH)/azure/Makefile
