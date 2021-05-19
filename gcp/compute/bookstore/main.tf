locals {
    project_id  = "multicloud-architect-b5e6e149"
    location    = "asia-northeast1"
}

resource "google_artifact_registry_repository" "bookstore_docker" {
    provider    = google-beta
    project     = local.project_id
    location    = local.location
    format      = "DOCKER"
    repository_id   = "bookstore"
    description     = "Repository for Bookstore"
}

module "bookstore_server" {
    source      = "./cloudrun/services/server"
    name        = "bookstore-server"
    image       = "asia-northeast1-docker.pkg.dev/${local.project_id}/bookstore/bookstore-server:1.0.1"
    location    = local.location
    labels  = {
        role = "bookstore-server"
    }
}

module "bookstore_gateway" {
    source      = "./cloudrun/services/gateway"
    name        = "bookstore-gateway"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/bookstore/bookstore-gateway:bookstore-server-1c64-duw6v5yogq-an.a.run.app-2021-05-18r0-1.0.0"
    location    = local.location
    labels  = {
        role = "bookstore-gateway"
    }
}
