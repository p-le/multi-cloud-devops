ARG TERRAFORM_VERSION
ARG GCLOUD_SDK_VERSION

FROM hashicorp/terraform:$TERRAFORM_VERSION as terraform-base

FROM google/cloud-sdk:$GCLOUD_SDK_VERSION

WORKDIR /work

COPY --from=terraform-base /bin/terraform /bin/terraform
