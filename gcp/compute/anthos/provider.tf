data "google_client_config" "default" {}

terraform {
    required_providers {
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0"
        }
    }
}

provider "google" {
    project = "multicloud-architect-b5e6e149"
    region  = "asia-northeast1"
}

provider "google-beta" {
    project = "multicloud-architect-b5e6e149"
    region  = "asia-northeast1"
}

provider "kubernetes" {
    host        = "https://${google_container_cluster.primary.endpoint}"
    token       = data.google_client_config.default.access_token
    config_path = "/root/.kube/config"
    cluster_ca_certificate  = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "kubernetes-alpha" {
    host        = "https://${google_container_cluster.primary.endpoint}"
    token       = data.google_client_config.default.access_token
    config_path = "/root/.kube/config"
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}
