locals {
    region      = "asia-northeast1"
    workflow_region = "asia-southeast1" # Limited region
}

resource "google_storage_bucket" "workflow_functions_bucket" {
    name = "workflow-functions"
    location = "ASIA"
    force_destroy = true
    versioning {
        enabled = true
    }
    lifecycle_rule {
        condition {
            num_newer_versions = 3
        }
        action {
            type = "Delete"
        }
    }
}

resource "google_service_account" "workflow" {
    account_id   = "workflow-sa"
    display_name = "Workflow Service Account (Cloud Run, Cloud Function)"
}


module "functions" {
    source  = "./functions"
    bucket  = google_storage_bucket.workflow_functions_bucket.name
    randomgen_archive   = "randomgen-1.0.2.zip"
    multiply_archive    = "multiply-1.0.0.zip"
    service_account     = google_service_account.workflow.email
}

module "services" {
    source  = "./services"
    name        = "floor"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/workflow/floor:1.0.0"
    location    = local.region
    service_account = google_service_account.workflow.email
}

module "workflow" {
    source  = "./flow"
    name    = "workflow"
    region  = local.workflow_region
    service_account_id      = google_service_account.workflow.id
    service_account         = google_service_account.workflow.email
    randomgen_trigger_url   = module.functions.ramdomgen_trigger_url
    multiply_trigger_url    = module.functions.multiply_trigger_url
    floor_service_endpoint  = module.services.floor_service_endpoint
}
