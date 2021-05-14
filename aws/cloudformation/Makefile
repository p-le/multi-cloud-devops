.PHONY: aws-cloudformation-upload
aws-cloudformation-upload:
	$(MAKE) awscli ARG="--profile terraform \
		s3 sync \
			/cloudformation/ \
			s3://infra-cloudformation-templates-ap-northeast-1/ \
			--include '*.yaml' \
			--exclude 'Makefile' \
			--exclude '*.zip'"

.PHONY: aws-cloudformation-estimate-stack
aws-cloudformation-estimate-stack:
	$(MAKE) awscli ARG="--profile provisioner \
		cloudformation \
			estimate-template-cost \
			--template-body file:///cloudformation/template.yaml"

.PHONY: aws-cloudformation-create-stack
aws-cloudformation-create-stack:
	$(MAKE) awscli ARG="--profile provisioner \
		cloudformation \
			create-stack \
			--stack-name phule-devops-cf \
			--template-body file:///cloudformation/template.yaml"

.PHONY: aws-cloudformation-update-stack
aws-cloudformation-update-stack:
	$(MAKE) awscli ARG="--profile provisioner \
		cloudformation \
			update-stack \
			--stack-name=phule-devops-cf \
			--template-body file:///cloudformation/template.yaml"

.PHONY: aws-cloudformation-delete-stack
aws-cloudformation-delete-stack:
	$(MAKE) awscli ARG="--profile provisioner \
		cloudformation \
			delete-stack \
			--stack-name=phule-devops-cf"
