data "google_iam_policy" "noauth" {
    binding {
        role = "roles/run.invoker"
        members = [
            "allUsers",
        ]
    }
}

resource "random_id" "default" {
  byte_length = 2
}

resource "google_service_account" "default" {
    account_id   = "pubsub-app-cloud-run-sa"
    display_name = "PubSub App Cloud Run Service Account"
}

resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${google_service_account.default.email}"
}


resource "google_cloud_run_service" "default" {
    provider = google-beta

    name     = "${var.name}-${random_id.default.hex}"
    location = var.location

    template {
        spec {
            containers {
                image = var.image
            }
            service_account_name = google_service_account.default.email
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

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
