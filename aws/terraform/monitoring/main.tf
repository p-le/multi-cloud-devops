provider "aws" {
  region = "ap-northeast-1"
  profile = "provisioner"
}

locals {
  env = "dev"
  organization = "phule"
}

module "dashboards" {
  source  = "./modules/dashboards"
  env           = local.env
  organization  = local.organization
}

# module "configs" {
#   source  = "./modules/configs"
#   organization  = local.organization
# }
