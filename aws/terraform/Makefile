
.PHONY: aws-terraform-monitoring
aws-terraform-monitoring: WORKDIR := /terraform/monitoring
aws-terraform-monitoring:
	docker container run -it --rm \
	-v $(BASE_PATH)/aws/terraform:/terraform \
	-v $(BASE_PATH)/aws/config:/root/.aws \
	-w $(WORKDIR) \
	hashicorp/terraform:$(TERRAFORM_VERSION) \
		$(ARG)

.PHONY: aws-terraform-monitoring-init
aws-terraform-monitoring-init:
	$(MAKE) aws-terraform-monitoring ARG="init"

.PHONY: aws-terraform-monitoring-plan
aws-terraform-monitoring-plan:
	$(MAKE) aws-terraform-monitoring ARG="plan"

.PHONY: aws-terraform-monitoring-apply
aws-terraform-monitoring-apply:
	$(MAKE) aws-terraform-monitoring ARG="apply"

.PHONY: aws-terraform--monitoring-destroy
aws-terraform-monitoring-destroy:
	$(MAKE) aws-terraform-monitoring ARG="destroy"




.PHONY: aws-terraform-compute
aws-terraform-compute: WORKDIR := /terraform/compute
aws-terraform-compute:
	docker container run -it --rm \
	-v $(BASE_PATH)/aws/terraform:/terraform \
	-v $(BASE_PATH)/aws/config:/root/.aws \
	-w $(WORKDIR) \
	hashicorp/terraform:$(TERRAFORM_VERSION) \
		$(ARG)

.PHONY: aws-terraform-compute-init
aws-terraform-compute-init:
	$(MAKE) aws-terraform-compute ARG="init"

.PHONY: aws-terraform-compute-plan
aws-terraform-compute-plan:
	$(MAKE) aws-terraform-compute ARG="plan"

.PHONY: aws-terraform-compute-apply
aws-terraform-compute-apply:
	$(MAKE) aws-terraform-compute ARG="apply"

.PHONY: aws-terraform--compute-destroy
aws-terraform-compute-destroy:
	$(MAKE) aws-terraform-compute ARG="destroy"




.PHONY: aws-terraform-network
aws-terraform-network: WORKDIR := /terraform/network
aws-terraform-network:
	docker container run -it --rm \
	-v $(BASE_PATH)/aws/terraform:/terraform \
	-v $(BASE_PATH)/aws/config:/root/.aws \
	-w $(WORKDIR) \
	hashicorp/terraform:$(TERRAFORM_VERSION) \
		$(ARG)

.PHONY: aws-terraform-network-init
aws-terraform-network-init:
	$(MAKE) aws-terraform-network ARG="init"

.PHONY: aws-terraform-network-plan
aws-terraform-network-plan:
	$(MAKE) aws-terraform-network ARG="plan"

.PHONY: aws-terraform-network-apply
aws-terraform-network-apply:
	$(MAKE) aws-terraform-network ARG="apply"

.PHONY: aws-terraform--network-destroy
aws-terraform-network-destroy:
	$(MAKE) aws-terraform-network ARG="destroy"
