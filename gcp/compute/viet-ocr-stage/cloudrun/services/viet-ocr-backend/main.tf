data "google_iam_policy" "noauth" {
    binding {
        role = "roles/run.invoker"
        members = [
            "allUsers",
        ]
    }
}

resource "google_cloud_run_service" "default" {
    name     = var.name
    location = var.location
    template {
        spec {
            containers {
                image = var.image
            }
            service_account_name = var.service_account_name
        }
        metadata {
            labels = var.labels
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }

    autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
