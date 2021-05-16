resource "google_artifact_registry_repository" "multicloud_docker_repo" {
    provider = google-beta
    location = "asia-northeast1"
    repository_id = "multicloud-registry"
    description = "Registry for Multicloud Applications"
    format = "DOCKER"
}
