terraform {
    backend "gcs" {
        bucket  = "multicloud-architect-terraform"
        prefix  = "k8s"
    }
}

data "terraform_remote_state" "storage" {
    backend = "gcs"
    config = {
        bucket  = "multicloud-architect-terraform"
        prefix  = "storage"
    }
}
