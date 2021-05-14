terraform {
  backend "s3" {
    bucket = "phule-terraform-state"
    key    = "monitoring/state"
    region = "ap-northeast-1"
    profile = "provisioner"
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"

  config = {
    bucket = "phule-terraform-state"
    key    = "compute/state"
    region = "ap-northeast-1"
    profile = "provisioner"
  }
}
