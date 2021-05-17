locals {
    location = "asia-northeast1"
    viet_ocr_image = "asia-northeast1-docker.pkg.dev/viet-ocr-stage-8650711b/viet-ocr-stage-repository/viet-ocr"
    viet_ocr_image_version = "1.0.0"
}

data "google_iam_policy" "viet_ocr_noauth" {
    binding {
        role = "roles/run.invoker"
        members = [
            "allUsers",
        ]
    }
}

resource "google_artifact_registry_repository" "viet_ocr_docker_repository" {
    provider = google-beta
    location = local.location
    repository_id   = "viet-ocr-stage-repository"
    description     = "Repository for Viet OCR"
    project = "viet-ocr-stage-8650711b"
    format  = "DOCKER"
}

resource "google_service_account" "viet_ocr_cloudrun_revision" {
    account_id   = "viet-ocr-cloudrun-revision-sa"
    display_name = "Viet OCR Cloud run Revision Service Account"
}

resource "google_project_iam_member" "viet_ocr_cloudrun_serviceaccount_user" {
    role    = "roles/iam.serviceAccountUser"
    member  = "serviceAccount:${google_service_account.viet_ocr_cloudrun_revision.email}"
}

resource "google_project_iam_member" "viet_ocr_cloudrun_runadmin" {
    role    = "roles/run.admin"
    member  = "serviceAccount:${google_service_account.viet_ocr_cloudrun_revision.email}"
}

resource "google_project_iam_member" "viet_ocr_cloudrun_artifactregistry_reader" {
    role    = "roles/artifactregistry.reader"
    member  = "serviceAccount:${google_service_account.viet_ocr_cloudrun_revision.email}"
}


resource "google_cloud_run_service" "viet_ocr" {
    name     = "viet-ocr-backend-srv"
    location = local.location

    template {
        spec {
            containers {
                image = "${local.viet_ocr_image}:${local.viet_ocr_image_version}"
            }
            service_account_name = google_service_account.viet_ocr_cloudrun_revision.email
        }
        metadata {
            labels = {
                role = "viet-ocr-backend"
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }

    autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_policy" "viet_ocr_noauth" {
  location    = google_cloud_run_service.viet_ocr.location
  project     = google_cloud_run_service.viet_ocr.project
  service     = google_cloud_run_service.viet_ocr.name
  policy_data = data.google_iam_policy.viet_ocr_noauth.policy_data
}
