resource "random_id" "demo_topic_suffix" {
    byte_length = 2
}

resource "google_project_iam_member" "service_account_token_creator" {
    role    = "roles/iam.serviceAccountTokenCreator"
    member  = "serviceAccount:service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "demo_topic" {
    name = "demo-topic-${random_id.demo_topic_suffix.hex}"
}

resource "google_pubsub_subscription" "demo_pull_subcription" {
    name  = "demo-pull-subscription"
    topic = google_pubsub_topic.demo_topic.name
    expiration_policy {
        # Required: Minimum value is 24h
        ttl = "86400s"
    }
    retry_policy {
        minimum_backoff = "10s"
    }
    # Required: 10m and 168h
    # Required: Cannot be greater than the TTL in the subscription's expiration policy
    message_retention_duration  = "600s" # Required: 10m and 168h
    retain_acked_messages       = true
    ack_deadline_seconds        = 20
    enable_message_ordering     = false
}
