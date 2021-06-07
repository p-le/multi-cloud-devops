terraform {
    backend "gcs" {
        bucket  = "multicloud-architect-terraform"
        prefix  = "gks-clusters/simple-regional-beta"
    }
}

data "terraform_remote_state" "storage" {
    backend = "gcs"
    config = {
        bucket  = "multicloud-architect-terraform"
        prefix  = "storage"
    }
}
