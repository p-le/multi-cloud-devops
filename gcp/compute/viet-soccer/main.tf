data "google_project" "project" {}

locals {
    region      = "asia-northeast1"
    project_id  = element(split("/", data.google_project.project.id), 1)
}

resource "google_service_account" "viet_soccer_sa" {
    account_id   = "viet-soccer-sa"
    display_name = "Viet Soccer Service Account"
}

resource "google_project_iam_member" "secretmanager_secret_accessor" {
    role    = "roles/secretmanager.secretAccessor"
    member  = "serviceAccount:${google_service_account.viet_soccer_sa.email}"
}


resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${google_service_account.viet_soccer_sa.email}"
}

resource "google_project_iam_member" "secretmanager_secret_accessor" {
    role    = "roles/secretmanager.secretAccessor"
    member  = "serviceAccount:${google_service_account.viet_soccer_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
    provider    = google-beta
    project     = local.project_id
    location    = data.terraform_remote_state.storage.outputs.viet_soccer_repository_location
    repository  = data.terraform_remote_state.storage.outputs.viet_soccer_repository_name
    role        = "roles/artifactregistry.reader"
    member      = "serviceAccount:${google_service_account.viet_soccer_sa.email}"
}

module "youtube_comment" {
    source      = "./youtube-comment"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/viet-soccer-registry/youtube-comment:1.0.16"
    location    = local.region
    secret_name = "youtube-comment-credentials"
    secret_key  = "1"
    service_account_name = google_service_account.viet_soccer_sa.email
    labels  = {
        role = "youtube-comment"
    }
}
