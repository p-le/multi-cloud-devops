output "kubernetes_endpoint" {
    sensitive = true
    value     = google_container_cluster.primary.endpoint
}

output "client_token" {
    sensitive = true
    value     = base64encode(data.google_client_config.default.access_token)
}

output "ca_certificate" {
    sensitive = true
    value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "service_account" {
    description = "The default service account used for running nodes."
    value       = google_service_account.default.name
}

