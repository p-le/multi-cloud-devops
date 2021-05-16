terraform {
    backend "gcs" {
        bucket  = "multicloud-dev-terraform-state"
        prefix  = "artifact-registry/state"
    }
}
