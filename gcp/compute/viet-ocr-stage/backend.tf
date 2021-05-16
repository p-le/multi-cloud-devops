terraform {
    backend "gcs" {
        bucket  = "viet-ocr-stage-terraform-state"
        prefix  = "viet-ocr/state"
    }
}
