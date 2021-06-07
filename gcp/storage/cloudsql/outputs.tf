output "cloudsql_connection_name" {
    value = google_sql_database_instance.master.connection_name
}
output "cloud_proxy_service_account_email" {
    value = google_service_account.cloud_proxy.email
}
output "wordpress_db_credentials_secret_id" {
    value = google_secret_manager_secret.wordpress_db_credential.name
}
output "wordpress_db_credentials_version_id" {
    value = google_secret_manager_secret_version.wordpress_db_credential.name
}

