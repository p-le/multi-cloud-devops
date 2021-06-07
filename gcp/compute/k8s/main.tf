data "google_project" "project" {}

locals {
    region      = "asia-northeast1"
    project_id  = element(split("/", data.google_project.project.id), 1)
}



resource "google_service_account" "k8s_sa" {
    account_id   = "k8s-sa"
    display_name = "k8s Cluster Service Account"
}

resource "google_project_iam_member" "compute_network_viewer" {
    role    = "roles/compute.networkViewer"
    member  = "serviceAccount:${google_service_account.k8s_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
    provider    = google-beta
    project     = local.project_id
    location    = data.terraform_remote_state.storage.outputs.cloud_native_repository_location
    repository  = data.terraform_remote_state.storage.outputs.cloud_native_repository_name
    role        = "roles/artifactregistry.reader"
    member      = "serviceAccount:${google_service_account.k8s_sa.email}"
}

module "webserver_network" {
    source      = "./networking"
    name        = "webserver"
    regions     = ["asia-east2", "asia-northeast1"]
    cidr_range  = "172.19.0.0/16"
}

resource "google_compute_health_check" "autohealing" {
    provider            = google-beta
    name                = "webserver-autohealing-healthcheck"
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    http_health_check {
        request_path = "/health"
        port         = "80"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_compute_health_check" "loadbalancing" {
    provider            = google-beta
    name                = "webserver-loadbalancing-healthcheck"
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    http_health_check  {
        request_path = "/health"
        port = "80"
    }
    lifecycle {
        create_before_destroy = true
    }
}

module "webserver_asia_northeast_1" {
    source  = "./webserver"
    region  = "asia-northeast1"
    subnetwork  = module.webserver_network.subnetwork_names["asia-northeast1"]
    target_size = 1
    service_account_email       = google_service_account.k8s_sa.email
    autohealing_health_check    = google_compute_health_check.autohealing.id
}

module "webserver_asia_east2" {
    source  = "./webserver"
    region  = "asia-east2"
    subnetwork  = module.webserver_network.subnetwork_names["asia-east2"]
    target_size = 1
    service_account_email       = google_service_account.k8s_sa.email
    autohealing_health_check    = google_compute_health_check.autohealing.id
}

module "external_loadbalancing" {
    source  = "./load_balancer/external_http"
    name    = "webserver"
    backends  = [
        {
            "igm": module.webserver_asia_northeast_1.igm,
            "balancing_mode": "UTILIZATION"
        },
        {
            "igm": module.webserver_asia_east2.igm,
            "balancing_mode": "UTILIZATION"
        }
    ]
    loadbalancing_healthcheck = google_compute_health_check.loadbalancing.id
    port_range  = "80"
}

# module "etcd" {
#     source  = "./etcd"
#     region  = local.region
#     zones   = data.google_compute_zones.available_zones.names
#     target_size = 1
#     service_account_email = google_service_account.k8s_sa.email
# }

# module "k8s_master" {
#     source  = "./master"
#     type    = "kubeadm"
#     region  = local.region
#     zones   = data.google_compute_zones.available_zones.names
#     target_size = 1
#     service_account_email = google_service_account.k8s_sa.email
# }

# module "k8s_worker" {
#     source  = "./worker"
#     type    = "kubeadm"
#     region  = local.region
#     zones   = data.google_compute_zones.available_zones.names
#     target_size = 2
#     service_account_email = google_service_account.k8s_sa.email
# }
