data "google_project" "project" {
}

locals {
    cluster_type    = "simple-regional"
    region          = "asia-northeast1"
    ip_range_pods       = "192.168.0.0/21"
    ip_range_services   = "192.168.152.0/24"
    project_id          = element(split("/", data.google_project.project.id), 1)
}

resource "random_id" "cluster_name_suffix" {
    byte_length = 2
}

resource "google_service_account" "default" {
    account_id   = "gks-${local.cluster_type}-sa"
    display_name = "GKS ${title(replace(local.cluster_type, "-", " "))} Cluster Service Account"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
    provider    = google-beta
    project     = local.project_id
    location    = data.terraform_remote_state.storage.outputs.cloud_native_repository_location
    repository  = data.terraform_remote_state.storage.outputs.cloud_native_repository_name
    role    = "roles/artifactregistry.reader"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_compute_network" "custom" {
  name                    = "gks-${local.cluster_type}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom" {
    name          = "gks-${local.cluster_type}-asia-northeast1-subnetwork"
    ip_cidr_range = "10.2.0.0/16"
    region        = local.region
    network       = google_compute_network.custom.id
    secondary_ip_range {
        range_name    = "services-range"
        ip_cidr_range = local.ip_range_services
    }
    secondary_ip_range {
        range_name    = "pod-ranges"
        ip_cidr_range = local.ip_range_pods
    }
}

module "gke" {
    source      = "terraform-google-modules/kubernetes-engine/google"
    name        = "${local.cluster_type}-cluster-${random_id.cluster_name_suffix.hex}"
    project_id  = local.project_id
    regional    = true
    region      = local.region
    network     = "gks-${local.cluster_type}-network"
    subnetwork  = "gks-${local.cluster_type}-asia-northeast1-subnetwork"
    ip_range_pods       = "pod-ranges"
    ip_range_services   = "services-range"
    service_account     = google_service_account.default.email
    create_service_account      = false
    enable_binary_authorization = false
    skip_provisioners           = false

    depends_on = [
        google_compute_network.custom,
        google_compute_subnetwork.custom
    ]
}
