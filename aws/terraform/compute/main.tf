provider "aws" {
  region = "ap-northeast-1"
  profile = "provisioner"
}

module "ec2_instance" {
  source = "./modules/ec2"
  count = 0
}

locals {
  env = "dev"
  organization = "phule"
  availability_zones  = keys(data.terraform_remote_state.networking.outputs.public_subnets)
  public_subnets      = values(data.terraform_remote_state.networking.outputs.public_subnets)
  private_subnets     = values(data.terraform_remote_state.networking.outputs.private_subnets)
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
}

module "security_groups" {
  source  = "./modules/security_groups"
  vpc_id  = local.vpc_id
}


module "launch_configurations" {
  source        = "./modules/launch_configurations"
  key_name      = "devops-ec2"
  env           = local.env
  organization  = local.organization
  security_groups = [
    module.security_groups.allow_ssh,
    module.security_groups.allow_http,
    module.security_groups.allow_outbound
  ]
}


module "lauch_templates" {
  source        = "./modules/launch_templates"
  key_name      = "devops-ec2"
  env           = local.env
  organization  = local.organization
  subnets       = local.public_subnets
}

# module "loadbalancers" {
#   source = "./modules/loadbalancers"
#   vpc_id                = local.vpc_id
#   env                   = local.env
#   organization          = local.organization
#   subnets               = local.public_subnets
#   security_groups = [
#     module.security_groups.allow_https,
#     module.security_groups.allow_http,
#     module.security_groups.allow_outbound
#   ]
# }

# module "austoscaling_ec2" {
#   source                = "./modules/autoscaling_ec2"
#   count = 0
#   vpc_id                = local.vpc_id
#   env                   = local.env
#   organization          = local.organization
#   availability_zones    = local.availability_zones
#   subnets               = local.public_subnets
#   launch_template       = module.lauch_templates.normal_launch_template
#   launch_configuration  = module.launch_configurations.web_launch_conf
#   frontend_target_arn   = module.loadbalancers.frontend_target_arn
# }
