locals {
    cluster_type    = "simple-zonal-private"
    region          = "asia-northeast1"
    ip_range_pods       = "192.168.64.0/22"
    ip_range_services   = "192.168.152.0/24"
}

data "google_project" "project" {
}

data "google_compute_zones" "asia_northeast1_zones" {
    region = local.region
}


resource "random_id" "cluster_name_suffix" {
    byte_length = 2
}

resource "google_artifact_registry_repository" "default" {
    provider    = google-beta
    location    = local.region
    format      = "DOCKER"
    repository_id   = local.cluster_type
    description     = "Repository for ${title(replace(local.cluster_type, "-", " "))} GKS Cluster"
}

resource "google_service_account" "default" {
    account_id   = "gks-${local.cluster_type}-sa"
    display_name = "GKS ${title(replace(local.cluster_type, "-", " "))} Cluster Service Account"
}

# Enable pull image from Artifact Docker Registry
resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
    provider    = google-beta
    project     = google_artifact_registry_repository.default.project
    location    = google_artifact_registry_repository.default.location
    repository  = google_artifact_registry_repository.default.name
    role        = "roles/artifactregistry.reader"
    member      = "serviceAccount:${google_service_account.default.email}"
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
    source                  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster/"
    project_id              = element(split("/", data.google_project.project.id), 1)
    name                    = "${local.cluster_type}-cluster-${random_id.cluster_name_suffix.hex}"
    regional                = false
    region                  = local.region
    zones                   = data.google_compute_zones.asia_northeast1_zones.names
    network                 = "gks-${local.cluster_type}-network"
    subnetwork              = "gks-${local.cluster_type}-asia-northeast1-subnetwork"
    ip_range_pods           = "pod-ranges"
    ip_range_services       = "services-range"
    create_service_account  = false
    service_account         = google_service_account.default.email
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
    master_authorized_networks = [
        {
            cidr_block   = google_compute_subnetwork.custom.ip_cidr_range
            display_name = "VPC"
        },
    ]

    depends_on = [
        google_compute_network.custom,
        google_compute_subnetwork.custom
    ]
}
