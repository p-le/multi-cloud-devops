locals {
    region      = "asia-northeast1"
}

resource "google_artifact_registry_repository" "system_package_docker" {
    provider    = google-beta
    location    = local.region
    format      = "DOCKER"
    repository_id   = "system-package"
    description     = "Repository for System Package"
}

module "system_package_service" {
    source      = "./cloudrun"
    name        = "system-package"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/system-package/system-package:1.0.0"
    location    = local.region
}
