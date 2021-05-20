resource "random_id" "floor_service_suffix" {
  byte_length = 2
}

resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${var.service_account}"
}


resource "google_cloud_run_service" "floor" {
    provider = google-beta

    name     = "${var.name}-${random_id.floor_service_suffix.hex}"
    location = var.location

    template {
        spec {
            containers {
                image = var.image
            }
            service_account_name = var.service_account
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
