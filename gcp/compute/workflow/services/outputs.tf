output "floor_service_endpoint" {
    value = google_cloud_run_service.floor.status[0].url
}
