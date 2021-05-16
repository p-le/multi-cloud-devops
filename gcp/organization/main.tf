locals {
    organization_id = "organizations/966390809592"
}

resource "random_id" "viet_ocr_suffix" {
  byte_length = 4
}

resource "random_id" "youtube_ml_suffix" {
  byte_length = 4
}

resource "google_folder" "demo" {
    display_name = "Demo"
    parent       = local.organization_id
}

resource "google_folder" "viet_ocr" {
    display_name = "Viet OCR"
    parent       = local.organization_id
}

resource "google_folder" "youtube_ml" {
    display_name = "Youtube ML"
    parent       = local.organization_id
}

resource "google_project" "viet_ocr_stage" {
    name       = "Viet OCR Stage"
    project_id = "viet-ocr-stage-${random_id.viet_ocr_suffix.hex}"
    folder_id  = google_folder.viet_ocr.name
}

resource "google_project" "youtube_ml_stage" {
    name       = "Youtube ML Stage"
    project_id = "youtube-ml-stage-${random_id.youtube_ml_suffix.hex}"
    folder_id  = google_folder.youtube_ml.name
}
