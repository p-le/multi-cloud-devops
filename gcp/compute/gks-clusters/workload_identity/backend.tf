terraform {
    backend "gcs" {
        bucket  = "multicloud-architect-terraform"
        prefix  = "gks-clusters/workload-identity"
    }
}

data "terraform_remote_state" "storage" {
    backend = "gcs"
    config = {
        bucket  = "multicloud-architect-terraform"
        prefix  = "storage"
    }
}
