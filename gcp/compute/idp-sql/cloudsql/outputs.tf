output "cloudsql_connection_name" {
    value = google_sql_database_instance.master.connection_name
}
output "db_credentials_secret_id" {
    value = google_secret_manager_secret.db_credential.name
}
output "db_credentials_version_id" {
    value = google_secret_manager_secret_version.default.name
}

