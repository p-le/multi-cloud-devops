resource "google_artifact_registry_repository" "cloud_native_repository" {
    provider = google-beta
    location = var.location
    repository_id = "cloud-native-registry"
    description = "Registry for Cloud Native Applications"
    format = "DOCKER"
}

resource "google_artifact_registry_repository" "viet_soccer_repository" {
    provider = google-beta
    location = var.location
    repository_id = "viet-soccer-registry"
    description = "Registry for Viet Soccer Applications"
    format = "DOCKER"
}
