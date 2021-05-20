locals {
    region      = "asia-northeast1"
}

data "google_project" "project" {

}

resource "google_artifact_registry_repository" "pubsub_docker" {
    provider    = google-beta
    location    = local.region
    format      = "DOCKER"
    repository_id   = "pubsub"
    description     = "Repository for Pubsub App"
}


module "pubsub_app" {
    source      = "./cloudrun"
    name        = "pubsub-app"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/pubsub/pubsub:1.0.2"
    location    = local.region
}

module "pubsub_topic" {
    source      = "./topic"
    service_endpoint = module.pubsub_app.service_endpoint
    cloudrun_invoker_service_account = module.pubsub_app.service_account
}
