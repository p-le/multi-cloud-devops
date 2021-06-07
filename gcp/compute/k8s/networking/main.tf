locals {
    newbits = 4
    netnum  = 2
}
resource "google_compute_network" "custom" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom" {
    for_each        = toset(var.regions)
    name            = "${var.name}-${each.value}-subnet"
    ip_cidr_range   = cidrsubnet(var.cidr_range, local.newbits, local.netnum + index(var.regions, each.value))
    region          = each.value
    network         = google_compute_network.custom.id
}

resource "google_compute_firewall" "default" {
    name    = "${var.name}-allow-fw"
    network = google_compute_network.custom.name
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports    = ["22", "80"]
    }
    target_tags = [var.name]
}

resource "google_compute_firewall" "allow_healthcheck" {
    name    = "${var.name}-healthcheck-fw"
    network = google_compute_network.custom.name
    allow {
        protocol = "tcp"
        ports    = ["80"]
    }
    source_ranges = [
        "130.211.0.0/22",
        "35.191.0.0/16"
    ]
}
