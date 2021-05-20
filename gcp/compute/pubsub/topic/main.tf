data "google_project" "project" {
}

# data "google_service_account_id_token" "oidc" {
#     target_audience         = var.service_endpoint
# }


# data "http" "cloudrun" {
#     url = var.service_endpoint
#     request_headers  = {
#         Authorization = "Bearer ${data.google_service_account_id_token.oidc.id_token}"
#     }
# }

resource "random_id" "topic_suffix" {
    byte_length = 2
}

resource "google_project_iam_member" "service_account_token_creator" {
    role    = "roles/iam.serviceAccountTokenCreator"
    member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "app" {
    name = "pubsub-app-topic-${random_id.topic_suffix.hex}"
}

resource "google_pubsub_subscription" "example" {
    name  = "pubsub-app-subscription"
    topic = google_pubsub_topic.app.name

    push_config {
        push_endpoint = var.service_endpoint
        oidc_token {
            service_account_email = var.cloudrun_invoker_service_account
            # audience = data.http.cloudrun.body
        }
    }
}
