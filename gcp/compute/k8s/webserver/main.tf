data "google_compute_image" "ubuntu_focal" {
    family  = "ubuntu-2004-lts"
    project = "ubuntu-os-cloud"
}

data "google_compute_zones" "available_zones" {
    region = var.region
}

resource "random_id" "template_suffix" {
    keepers = {
        user-data       = file("${path.module}/data/cloud-config.yaml")
        source_image    = data.google_compute_image.ubuntu_focal.self_link
    }
    byte_length = 2
}

resource "google_compute_instance_template" "default" {
    name            = "webserver-template-${random_id.template_suffix.hex}"
    description     = "This template is used to create Webserver"
    region          = var.region
    instance_description = "Webserver Node"
    tags            = ["webserver"]
    machine_type    = "e2-medium"
    can_ip_forward  = false

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
        subnetwork = var.subnetwork
        access_config {
            // Ephemeral IP
        }
    }
    metadata = {
        "enable-oslogin"    = true
        "user-data"         = random_id.template_suffix.keepers.user-data
    }
    service_account {
        email  = var.service_account_email
        scopes = ["cloud-platform"]
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "random_id" "igm_suffix" {
    byte_length = 2
}

resource "google_compute_region_instance_group_manager" "default" {
    name                        = "webserver-igm-${var.region}-${random_id.igm_suffix.hex}"
    base_instance_name          = "webserver"
    region                      = var.region
    distribution_policy_zones   = data.google_compute_zones.available_zones.names
    target_size                 = var.target_size
    version {
        instance_template = google_compute_instance_template.default.id
    }
    auto_healing_policies {
        health_check      = var.autohealing_health_check
        initial_delay_sec = 120
    }
    update_policy {
        type                    = "PROACTIVE"
        minimal_action          = "REPLACE"
        max_surge_fixed         = length(data.google_compute_zones.available_zones.names)
        max_unavailable_fixed   = 0
        replacement_method      = "SUBSTITUTE"
    }
}

resource "google_compute_region_autoscaler" "default" {
    provider    = google-beta
    name        = "webserver-autoscaler-${var.region}"
    region      = var.region
    target      = google_compute_region_instance_group_manager.default.id

    autoscaling_policy {
        max_replicas    = 3
        min_replicas    = 1
        cooldown_period = 150

        cpu_utilization {
            target = 0.5
        }
    }
}


