locals {
    wordpress_db_name   = "wordpress"
    pools_db_name       = "polls"
}

resource "random_id" "db_name_suffix" {
    byte_length = 2
}

resource "random_password" "connector_password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

# Can not create same Cloud SQL name after deleted it in 1 month
# Need to add random suffix
resource "google_sql_database_instance" "master" {
    name             = "cloud-native-${random_id.db_name_suffix.hex}"
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

resource "google_sql_database" "wordpress_db" {
    name     = local.wordpress_db_name
    instance = google_sql_database_instance.master.name
}

resource "google_sql_database" "polls_db" {
    name     = local.pools_db_name
    instance = google_sql_database_instance.master.name
}

resource "google_sql_user" "connector_user" {
    name     = "connector"
    instance = google_sql_database_instance.master.name
    host     = "%"
    password = random_password.connector_password.result
}

resource "google_secret_manager_secret" "wordpress_db_credential" {
    provider = google-beta
    secret_id = "wordpress-db-credential"
    replication {
        automatic = true
    }
}

resource "google_secret_manager_secret" "wordpress_user_password_credential" {
    provider = google-beta
    secret_id = "wordpress-user-password-credential"
    replication {
        automatic = true
    }
}


resource "google_secret_manager_secret" "wordpress_db_connection_credential" {
    provider = google-beta
    secret_id = "wordpress-db-connection-credential"
    replication {
        automatic = true
    }
}


resource "google_secret_manager_secret_version" "wordpress_db_credential" {
    provider = google-beta
    secret = google_secret_manager_secret.wordpress_db_credential.name
    secret_data = jsonencode({
        "CLOUD_SQL_CONNECTION_NAME" = google_sql_database_instance.master.connection_name,
        "DB_NAME": local.wordpress_db_name,
        "DB_USER": google_sql_user.connector_user.name,
        "DB_PASSWORD": random_password.connector_password.result
    })
}

resource "google_secret_manager_secret_version" "wordpress_user_password_credential" {
    provider = google-beta
    secret = google_secret_manager_secret.wordpress_user_password_credential.name
    secret_data = random_password.connector_password.result
}

resource "google_secret_manager_secret_version" "wordpress_db_connection_credential" {
    provider = google-beta
    secret = google_secret_manager_secret.wordpress_db_connection_credential.name
    secret_data = google_sql_database_instance.master.connection_name
}
