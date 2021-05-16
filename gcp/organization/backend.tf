terraform {
    backend "gcs" {
        bucket  = "phu-le-dev-folders-terraform-state"
        prefix  = "terraform/state"
    }
}
