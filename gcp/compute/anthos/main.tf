locals {
    cluster_type    = "anthos-cloud-run"
    region          = "asia-northeast1"
    ip_range_pods       = "192.168.0.0/21"
    ip_range_services   = "192.168.152.0/24"
}

data "google_project" "project" {
}

resource "random_id" "cluster_name_suffix" {
    byte_length = 2
}

resource "google_service_account" "default" {
    account_id   = "anthos-sa"
    display_name = "${title(replace(local.cluster_type, "-", " "))} Cluster Service Account"
}

resource "google_compute_network" "custom" {
  name                    = "${local.cluster_type}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom" {
    name          = "${local.cluster_type}-asia-northeast1-subnetwork"
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
    initial_node_count = 2 # 1 Number of Nodes per Zone
    node_config {
        # preemptible  = true
        machine_type = "e2-medium"
        # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
        service_account = google_service_account.default.email
        metadata = { # Required to avoit replacement
            "disable-legacy-endpoints" = true
        }
        oauth_scopes    = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
    addons_config {
        http_load_balancing {
            disabled = false
        }
        cloudrun_config {
            disabled = false
            load_balancer_type = "LOAD_BALANCER_TYPE_INTERNAL"
            # load_balancer_type = "LOAD_BALANCER_TYPE_EXTERNAL"
        }
        istio_config {
            disabled = false
        }
    }
    logging_service = "logging.googleapis.com/kubernetes"
    ip_allocation_policy {
        services_secondary_range_name = google_compute_subnetwork.custom.secondary_ip_range.0.range_name
        cluster_secondary_range_name  = google_compute_subnetwork.custom.secondary_ip_range.1.range_name
    }
    timeouts {
        create = "7m"
        update = "10m"
    }
    depends_on = [
        google_compute_network.custom,
        google_compute_subnetwork.custom
    ]
}


resource "kubernetes_namespace" "example" {
    metadata {
        annotations = {
            name = "cloud-run-services"
        }

        labels = {
            maintainer = "terraform"
        }
        name = "cloud-run-services"
    }
}
