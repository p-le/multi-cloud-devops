data "google_client_config" "default" {}

provider "google" {
    project = "multicloud-architect-b5e6e149"
    region  = "asia-northeast1"
}

provider "kubernetes" {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}
