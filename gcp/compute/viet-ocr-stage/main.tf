resource "google_artifact_registry_repository" "viet_ocr_docker_repository" {
    provider = google-beta
    location = "asia-northeast1"
    repository_id   = "viet-ocr-stage-repository"
    description     = "Repository for Viet OCR"
    project = "viet-ocr-stage-8650711b"
    format  = "DOCKER"
}
