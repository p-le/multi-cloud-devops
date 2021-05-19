resource "random_id" "default" {
  byte_length = 2
}

resource "google_service_account" "default" {
    account_id   = "${var.name}-sa"
    display_name = "Viet OCR Service Account for Endpoints - Cloud Run"
}

resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "cloudrun_servicemanagement_service_controller" {
    role    = "roles/servicemanagement.serviceController"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_cloud_run_service" "default" {
    name     = "${var.name}-${random_id.default.hex}"
    location = var.location
    template {
        spec {
            containers {
                image = var.image
                env {
                    name = "ESPv2_ARGS"
                    value = "--enable_debug"
                }
            }
            timeout_seconds         = 60
            service_account_name    = google_service_account.default.email
        }
        metadata {
            labels = var.labels
            annotations = {
                "autoscaling.knative.dev/minScale" = "0"
                "autoscaling.knative.dev/maxScale" = "3"
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }

    autogenerate_revision_name = true
}
