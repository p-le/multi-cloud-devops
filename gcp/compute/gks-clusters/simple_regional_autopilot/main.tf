locals {
    cluster_type    = "simple-regional-autopilot"
    region          = "asia-northeast1"
    ip_range_pods       = "192.168.64.0/22"
    ip_range_services   = "192.168.152.0/24"
}

data "google_project" "project" {
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
    account_id   = "gks-autopilot-sa"
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

resource "google_container_cluster" "primary" {
    provider    = google-beta
    name        = "${local.cluster_type}-cluster-${random_id.cluster_name_suffix.hex}"
    location    = local.region

    networking_mode = "VPC_NATIVE"
    network     = google_compute_network.custom.id
    subnetwork  = google_compute_subnetwork.custom.id
    ip_allocation_policy {
        services_secondary_range_name = google_compute_subnetwork.custom.secondary_ip_range.0.range_name
        cluster_secondary_range_name  = google_compute_subnetwork.custom.secondary_ip_range.1.range_name
    }

    timeouts {
        create = "10m"
        update = "15m"
    }

    # Conflicts with: node_pool, node_config
    enable_autopilot = true

    lifecycle {
        ignore_changes = [ node_pool, initial_node_count ]
    }
    depends_on = [
        google_compute_network.custom,
        google_compute_subnetwork.custom
    ]
}
