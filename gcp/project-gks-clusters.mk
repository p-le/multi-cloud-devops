GKS_CLUSTERS_PROJECT_ID	:= multicloud-architect-b5e6e149
GKS_CLUSTERS_TF_KEY		:= multicloud-architect-terraform-sa-key
GKS_CLUSTERS_TF_VERSION	:= 1
GKS_CLUSTERS_TF_SOURCE_DIR	:= /work/compute/gks-clusters
GKS_CLUSTERS_PROJECTS 	:= simple_regional simple_regional_beta simple_zonal_private simple_regional_autopilot

.PHONY: gks-clusters-gcloud-authenticate
gks-clusters-gcloud-authenticate:
	@$(MAKE) gcloud-authenticate \
		CONFIGURATION_NAME=gks-clusters \
		PROJECT_ID=$(GKS_CLUSTERS_PROJECT_ID)
	@$(MAKE) gcloud-sdk CMD="gcloud secrets versions access $(GKS_CLUSTERS_TF_VERSION) --secret=$(GKS_CLUSTERS_TF_KEY)" | grep -v "make" > ./miscs/gcp/credentials/$(addsuffix .json, $(GKS_CLUSTERS_TF_KEY))


define make-project-targets
gks-clusters-$(subst _,-,$1)-tf:
	@$(MAKE) gcloud-activate-configuration PROJECT_ID=$(GKS_CLUSTERS_PROJECT_ID)
	@$(MAKE) gcloud-terraform-sdk \
		CMD="terraform -chdir=$(GKS_CLUSTERS_TF_SOURCE_DIR)/$1 $(TF_CMD)" \
		PROJECT_ID=$(GKS_CLUSTERS_PROJECT_ID) \
		CREDENTIAL_FILE=$(addsuffix .json, $(GKS_CLUSTERS_TF_KEY))
endef

$(foreach project,$(GKS_CLUSTERS_PROJECTS),$(eval $(call make-project-targets,$(project))))

