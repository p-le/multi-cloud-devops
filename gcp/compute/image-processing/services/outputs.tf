output "image_processing_endpoint" {
    value = google_cloud_run_service.image_processing.status[0].url
}

output "image_processing_service_account" {
    value = google_service_account.image_processing_sa.email
}
