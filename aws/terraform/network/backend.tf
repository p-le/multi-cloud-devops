terraform {
  backend "s3" {
    bucket = "phule-terraform-state"
    key    = "network/state"
    region = "ap-northeast-1"
    profile = "provisioner"
  }
}
