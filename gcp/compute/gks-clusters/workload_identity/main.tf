locals {
    cluster_type = "regional"
}


module "gke" {
  source                   = "../../"
  project_id               = var.project_id
  name                     = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region                   = var.region
  network                  = var.network
  subnetwork               = var.subnetwork
  ip_range_pods            = var.ip_range_pods
  ip_range_services        = var.ip_range_services
  remove_default_node_pool = true
  service_account          = "create"
  node_metadata            = "GKE_METADATA_SERVER"
  node_pools = [
    {
      name         = "wi-pool"
      min_count    = 1
      max_count    = 2
      auto_upgrade = true
    }
  ]
}

# example without existing KSA
module "workload_identity" {
    source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
    project_id          = var.project_id
    name                = "iden-${module.gke.name}"
    namespace           = "default"
    use_existing_k8s_sa = false
}


# example with existing KSA
resource "kubernetes_service_account" "test" {
    metadata {
        name = "foo-ksa"
    }
    secret {
        name = "bar"
    }
}

module "workload_identity_existing_ksa" {
    source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
    project_id          = var.project_id
    name                = "existing-${module.gke.name}"
    cluster_name        = module.gke.name
    location            = module.gke.location
    namespace           = "default"
    use_existing_k8s_sa = true
    k8s_sa_name         = kubernetes_service_account.test.metadata.0.name
}
