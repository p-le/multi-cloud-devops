resource "random_id" "project_name_suffix" {
  byte_length = 4
}

resource "google_project" "default" {
    name       = "Multicloud Architect"
    project_id = "multicloud-architect-${random_id.project_name_suffix.hex}"
    folder_id  = var.folder_id
}
# Firebase Management API Enable Required
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = google_project.default.project_id
}

resource "google_service_account" "terraform" {
    account_id   = "terraform-provisioner-sa"
    display_name = "Terraform Provisioner Service Account"
    project      = element(split("/", google_project.default.id), 1)
}
