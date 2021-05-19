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
            timeout_seconds         = 60
            service_account_name    = var.service_account_name
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

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_endpoints_service" "grpc_service" {
    service_name         = "${replace(google_cloud_run_service.default.status[0].url, "https://", "")}"
    grpc_config          = templatefile("${path.module}/api_config.yaml", {
        _HOSTNAME = "${replace(google_cloud_run_service.default.status[0].url, "https://", "")}"
    })
    protoc_output_base64 = filebase64("${path.module}/protos/helloworld/generated_pb2/api_descriptor.pb")
}
