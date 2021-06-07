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

resource "google_cloud_run_service" "default" {
    provider = google-beta
    name     = "youtube-comment-${random_id.default.hex}"
    location = var.location
    template {
        spec {
            containers {
                image = var.image
                env {
                    name = "OAUTHLIB_RELAX_TOKEN_SCOPE"
                    value = "1"
                }
                env {
                    name = "CLIENT_SECRET_FILE"
                    value = "/secrets/${var.secret_name}"
                }
                env {
                    name = "ENV"
                    value = "production"
                }
                volume_mounts {
                    name = "oauth"
                    mount_path = "/secrets"
                }
            }
            volumes {
                name = "oauth"
                secret {
                    secret_name = var.secret_name
                    items {
                        key = "latest"
                        path = var.secret_name
                    }
                }
            }
            service_account_name = var.service_account_name
        }
        metadata {
            labels = var.labels
            annotations = {
                "autoscaling.knative.dev/maxScale"  = "3"
                "autoscaling.knative.dev/minScale"  = "0"
                "run.googleapis.com/launch-stage"   = "BETA"
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

# resource "google_endpoints_service" "public_service" {
#     service_name         = "${replace(google_cloud_run_service.default.status[0].url, "https://", "")}"
#     grpc_config          = templatefile("${path.module}/api_config.yaml", {
#         _HOSTNAME = "${replace(google_cloud_run_service.default.status[0].url, "https://", "")}"
#     })
#     protoc_output_base64 = filebase64("${path.module}/api_descriptor.pb")
# }
