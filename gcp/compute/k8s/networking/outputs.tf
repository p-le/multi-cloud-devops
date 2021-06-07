output "network_name" {
    value = google_compute_network.custom.name
}

output "subnetwork_names" {
    value = {
        for subnet in google_compute_subnetwork.custom:
        subnet.region => subnet.name
    }
}
