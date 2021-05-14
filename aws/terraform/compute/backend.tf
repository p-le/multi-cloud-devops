terraform {
  backend "s3" {
    bucket = "phule-terraform-state"
    key    = "compute/state"
    region = "ap-northeast-1"
    profile = "provisioner"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "phule-terraform-state"
    key    = "network/state"
    region = "ap-northeast-1"
    profile = "provisioner"
  }
}
