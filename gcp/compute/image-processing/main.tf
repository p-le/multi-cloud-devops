locals {
    region  = "asia-northeast1"
}

data "google_project" "project" {

}

resource "google_artifact_registry_repository" "image_processing_docker" {
    provider    = google-beta
    location    = local.region
    format      = "DOCKER"
    repository_id   = "image-processing"
    description     = "Repository for Image Processing App"
}


module "services" {
    source      = "./services"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/image-processing/image-processing:1.0.1"
    location    = local.region
}

module "topics" {
    source      = "./topics"
    image_processing_endpoint                           = module.services.image_processing_endpoint
    image_processing_cloudrun_invoker_service_account   = module.services.image_processing_service_account
}

module "buckets" {
    source      = "./buckets"
    topic_id    = module.topics.image_processing_topic
}
