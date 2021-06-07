resource "random_id" "image_processing_suffix" {
  byte_length = 2
}

resource "google_service_account" "image_processing_sa" {
    account_id   = "image-processing-cloud-run-sa"
    display_name = "Image Processing Cloud Run Service Account"
}

resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${google_service_account.image_processing_sa.email}"
}

resource "google_cloud_run_service" "image_processing" {
    provider = google-beta

    name     = "image-processing-${random_id.image_processing_suffix.hex}"
    location = var.location

    template {
        spec {
            containers {
                image = var.image
            }
            service_account_name = google_service_account.image_processing_sa.email
        }
        metadata {
            annotations = {
                "autoscaling.knative.dev/minScale"      = "0"
                "autoscaling.knative.dev/maxScale"      = "3"
                "run.googleapis.com/launch-stage"       = "BETA"
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }

    autogenerate_revision_name = true
}
