locals {
    db_name = "pets"
}

resource "random_id" "db_name_suffix" {
    byte_length = 2
}

resource "random_password" "connector_password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

# NOTE:
# Can not create same Cloud SQL name after deleted it
resource "google_sql_database_instance" "master" {
    name             = "idp-sql-instance-${random_id.db_name_suffix.hex}"
    database_version = "MYSQL_8_0"
    region           = var.region
    deletion_protection = false
    settings {
        tier = "db-f1-micro"
    }
}

resource "google_service_account" "cloud_proxy" {
    account_id   = "cloud-proxy-sa"
    display_name = "Cloud Proxy Service Account"
}

resource "google_project_iam_member" "cloudsql_client" {
    role    = "roles/cloudsql.client"
    member  = "serviceAccount:${google_service_account.cloud_proxy.email}"
}

resource "google_sql_database" "pets_db" {
    name     = local.db_name
    instance = google_sql_database_instance.master.name
}

resource "google_sql_user" "connector_user" {
    name     = "connector"
    instance = google_sql_database_instance.master.name
    host     = "%"
    password = random_password.connector_password.result
}

resource "google_secret_manager_secret" "db_credential" {
    provider = google-beta
    secret_id = "db-credential"
    replication {
        automatic = true
    }
}

resource "google_secret_manager_secret_version" "default" {
    provider = google-beta
    secret = google_secret_manager_secret.db_credential.name
    secret_data = jsonencode({
        "CLOUD_SQL_CONNECTION_NAME" = google_sql_database_instance.master.connection_name,
        "DB_NAME": local.db_name,
        "DB_USER": google_sql_user.connector_user.name,
        "DB_PASSWORD": random_password.connector_password.result
    })
}
