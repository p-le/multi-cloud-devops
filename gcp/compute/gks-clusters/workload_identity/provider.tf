data "google_client_config" "default" {}

provider "google" {
    project = "multicloud-architect-b5e6e149"
    region  = "asia-northeast1"
}

provider "google-beta" {
    project = "multicloud-architect-b5e6e149"
    region  = "asia-northeast1"
}

provider "kubernetes" {
    host                    = "https://${module.gke.endpoint}"
    token                   = data.google_client_config.default.access_token
    cluster_ca_certificate  = base64decode(module.gke.ca_certificate)
    config_path             = "/root/.kube/config"
}
