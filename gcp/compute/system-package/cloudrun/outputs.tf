output "service_endpoint" {
    value = google_cloud_run_service.default.status[0].url
}

output "service_account" {
    value = google_service_account.default.email
}
