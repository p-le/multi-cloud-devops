data "google_compute_image" "ubuntu_focal" {
    family  = "ubuntu-2004-lts"
    project = "ubuntu-os-cloud"
}

data "google_compute_image" "cos" {
    project = "cos-cloud"
    family  = "cos-89-lts"
}

data "google_compute_network" "default" {
    name = "default"
}

resource "random_id" "template_suffix" {
    keepers = {
        region          = var.region
        user-data       = file("${path.module}/data/cloud-config.${var.type}.yaml")
        source_image    = data.google_compute_image.ubuntu_focal.self_link
        shutdown-script = file("${path.module}/data/shutdown-script.sh")
    }
    byte_length = 8
}

resource "google_compute_firewall" "default" {
    name    = "k8s-master-nodes-firewall"
    network = data.google_compute_network.default.name
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports    = ["22", "6443", "2379-2380", "10250", "10251", "10252"]
    }
    target_tags = ["k8s-master"]
}

resource "google_compute_instance_template" "default" {
    name        = "k8s-master-template-${random_id.template_suffix.hex}"
    description = "This template is used to create k8s cluster master"
    region      = random_id.template_suffix.keepers.region
    instance_description = "Kubernetes Cluster Master Node"
    tags        = ["k8s-master"]
    machine_type         = "e2-medium"
    can_ip_forward       = false

    scheduling {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
    }
    disk {
        source_image      = random_id.template_suffix.keepers.source_image
        auto_delete       = true
        boot              = true
    }
    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }
    metadata = {
        "enable-oslogin"    = true
        "user-data"         = random_id.template_suffix.keepers.user-data
        "shutdown-script"   = random_id.template_suffix.keepers.shutdown-script
    }
    service_account {
        email  = var.service_account_email
        scopes = ["cloud-platform"]
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_compute_region_instance_group_manager" "default" {
    name                        = "k8s-master-igm"
    base_instance_name          = "k8s-master"
    region                      = var.region
    distribution_policy_zones   = var.zones
    target_size                 = var.target_size
    version {
        instance_template = google_compute_instance_template.default.id
    }
    update_policy {
        type                    = "PROACTIVE"
        minimal_action          = "REPLACE"
        max_surge_fixed         = length(var.zones)
        max_unavailable_fixed   = 0
        replacement_method      = "SUBSTITUTE"
    }
}
