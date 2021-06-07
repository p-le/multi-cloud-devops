data "google_project" "project" {
}
data "google_storage_project_service_account" "gcs_account" {
}
resource "random_id" "image_processing_topic_suffix" {
    byte_length = 2
}

resource "google_project_iam_member" "service_account_token_creator" {
    role    = "roles/iam.serviceAccountTokenCreator"
    member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "image_processing" {
    name = "image-processing-topic-${random_id.image_processing_topic_suffix.hex}"
}

resource "google_pubsub_topic_iam_member" "image_processing_pubsub_publisher" {
  topic   = google_pubsub_topic.image_processing.id
  role    = "roles/pubsub.publisher"
  member = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_pubsub_subscription" "image_processing_cloudrun_subcription" {
    name  = "image-processing-cloud-run-subscription"
    topic = google_pubsub_topic.image_processing.name

    push_config {
        push_endpoint = var.image_processing_endpoint
        oidc_token {
            service_account_email = var.image_processing_cloudrun_invoker_service_account
            # audience = data.http.cloudrun.body
        }
    }
}
