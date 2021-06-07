resource "random_id" "bucket_suffix" {
    byte_length = 2
}

resource "google_storage_bucket" "image_processing_bucket" {
    name = "image-processing-${random_id.bucket_suffix.hex}"
    location = "ASIA"
    force_destroy = true
    versioning {
        enabled = true
    }
    lifecycle_rule {
        condition {
            num_newer_versions = 3
        }
        action {
            type = "Delete"
        }
    }
}

resource "google_storage_notification" "notification" {
    bucket         = google_storage_bucket.image_processing_bucket.name
    payload_format = "JSON_API_V1"
    topic          = var.topic_id
    event_types    = [
        "OBJECT_FINALIZE",
        "OBJECT_METADATA_UPDATE"
    ]
    custom_attributes = {
        new-attribute = "test"
    }
}
