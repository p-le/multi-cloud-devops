terraform {
    backend "gcs" {
        bucket  = "multicloud-architect-terraform"
        prefix  = "pubsub"
    }
}
