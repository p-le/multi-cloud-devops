# data "google_iam_policy" "noauth" {
#     binding {
#         role = "roles/run.invoker"
#         members = [
#             "allUsers",
#         ]
#     }
# }

resource "random_id" "default" {
  byte_length = 2
}

resource "google_service_account" "default" {
    account_id   = "${var.name}-sa"
    display_name = "Bookstore Server Service Account"
}

resource "google_project_iam_member" "cloudrun_invoker" {
    role    = "roles/run.invoker"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_cloud_run_service" "default" {
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
            labels = var.labels
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }

    autogenerate_revision_name = true
}

# resource "google_cloud_run_service_iam_policy" "noauth" {
#   location    = google_cloud_run_service.default.location
#   project     = google_cloud_run_service.default.project
#   service     = google_cloud_run_service.default.name
#   policy_data = data.google_iam_policy.noauth.policy_data
# }

resource "google_endpoints_service" "public_service" {
    service_name         = "${replace(google_cloud_run_service.default.status[0].url, "https://", "")}"
    grpc_config          = templatefile("${path.module}/api_config.yaml", {
        _HOSTNAME = "${replace(google_cloud_run_service.default.status[0].url, "https://", "")}"
    })
    protoc_output_base64 = filebase64("${path.module}/api_descriptor.pb")
}
