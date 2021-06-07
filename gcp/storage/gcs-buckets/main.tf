resource "random_id" "cloud_functions_suffix" {
  byte_length = 2
}
resource "random_id" "static_assets_suffix" {
  byte_length = 2
}
resource "google_storage_bucket" "cloud_functions_bucket" {
    name = "cloud-functions-${random_id.cloud_functions_suffix.hex}"
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

resource "google_storage_bucket" "static_assets_bucket" {
    name            = "static-assets-${random_id.static_assets_suffix.hex}"
    location        = "ASIA"
    force_destroy   = true
    versioning {
        enabled = true
    }
    cors {
        origin          = ["http://image-store.com"]
        method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
        response_header = ["*"]
        max_age_seconds = 3600
    }
    lifecycle_rule {
        condition {
            num_newer_versions = 3
        }
        action {
            type = "Delete"
        }
    }
    uniform_bucket_level_access = false
}

resource "google_storage_bucket_iam_member" "member" {
    bucket  = google_storage_bucket.static_assets_bucket.name
    role    = "roles/storage.objectViewer"
    member  = "allUsers"
}

resource "google_compute_backend_bucket" "static_assets_backend" {
    provider    = google-beta
    name        = "static-assets-backend"
    description = "Static Assets for Application"
    bucket_name = google_storage_bucket.static_assets_bucket.name
    enable_cdn  = true
}
