data "google_project" "project" {

}

data "google_compute_zones" "asia_northeast1_zones" {
    region = local.region
}

locals {
    cluster_type    = "simple-regional-beta"
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

resource "google_project_iam_member" "cloud_sql_client" {
    project = local.project_id
    role    = "roles/cloudsql.client"
    member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_pubsub_subscription_iam_member" "pubsub_subcriber" {
    subscription = data.terraform_remote_state.storage.outputs.demo_pull_subscription
    role         = "roles/pubsub.subscriber"
    member       = "serviceAccount:${google_service_account.default.email}"
}

resource "google_compute_network" "custom" {
  name                    = "gks-${local.cluster_type}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom" {
    name          = "gks-${local.cluster_type}-asia-northeast1-subnetwork"
    ip_cidr_range = "10.4.0.0/16"
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
    source      = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
    project_id  = local.project_id
    name        = "${local.cluster_type}-cluster-${random_id.cluster_name_suffix.hex}"
    regional    = true
    region      = local.region
    zones       = data.google_compute_zones.asia_northeast1_zones.names
    network     = "gks-${local.cluster_type}-network"
    subnetwork  = "gks-${local.cluster_type}-asia-northeast1-subnetwork"
    ip_range_pods       = "pod-ranges"
    ip_range_services   = "services-range"
    service_account             = google_service_account.default.email
    create_service_account      = false
    istio                       = false
    cloudrun                    = false
    dns_cache                   = false
    gce_pd_csi_driver           = false
    sandbox_enabled             = false
    remove_default_node_pool    = false
    initial_node_count          = 1
    # node_pools                  = var.node_pools
    # database_encryption         = var.database_encryption
    # enable_binary_authorization = var.enable_binary_authorization
    # enable_pod_security_policy  = var.enable_pod_security_policy

    # Best practices for versioning and upgrading GKE clusters
    # Ability to balance between stability and feature set of the version deployed in cluster
    release_channel     = "REGULAR" # "RAPID", "REGULAR", "STABLE", "NONE"
    # Disable workload identity
    identity_namespace  = null
    node_metadata       = "UNSPECIFIED"
    # Enable Dataplane Setup
    datapath_provider   = "ADVANCED_DATAPATH"

    depends_on = [
        google_compute_network.custom,
        google_compute_subnetwork.custom
    ]
}
