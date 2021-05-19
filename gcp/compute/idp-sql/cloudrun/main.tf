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
    account_id   = "${var.name}-sa"
    display_name = "IDP SQL Service Account"
}

resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "cloudsql_client" {
    role    = "roles/cloudsql.client"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "secret_accessor" {
    role    = "roles/secretmanager.secretAccessor"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  provider = google-beta
  secret_id = var.db_credentials_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.default.email}"
}


resource "google_cloud_run_service" "default" {
    provider = google-beta

    name     = "${var.name}-${random_id.default.hex}"
    location = var.location

    template {
        spec {
            containers {
                image = var.image
                env {
                    name = "CLOUD_SQL_CREDENTIALS_SECRET"
                    value = var.db_credentials_version_id
                }
            }
            service_account_name = google_service_account.default.email
        }
        metadata {
            annotations = {
                "autoscaling.knative.dev/minScale"      = "0"
                "autoscaling.knative.dev/maxScale"      = "3"
                "run.googleapis.com/cloudsql-instances" = var.cloudsql_connection_name
                "run.googleapis.com/launch-stage"       = "BETA"
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }

    lifecycle {
        ignore_changes = [
            metadata.0.annotations,
        ]
    }

    autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
