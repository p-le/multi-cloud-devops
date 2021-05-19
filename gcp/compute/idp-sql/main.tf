locals {
    region      = "asia-northeast1"
}

resource "google_artifact_registry_repository" "idp_sql_docker" {
    provider    = google-beta
    location    = local.region
    format      = "DOCKER"
    repository_id   = "idp-sql"
    description     = "Repository for IDP SQL"
}

# Cloud SQL Admin API Enable Required
module "idp_sql_db" {
    source      = "./cloudsql"
    region      = local.region
}

module "idp_sql_service" {
    source      = "./cloudrun"
    name        = "idp-sql"
    image       = "asia-northeast1-docker.pkg.dev/multicloud-architect-b5e6e149/idp-sql/idp-sql:1.0.2"
    location    = local.region
    cloudsql_connection_name    = module.idp_sql_db.cloudsql_connection_name
    db_credentials_secret_id    = module.idp_sql_db.db_credentials_secret_id
    db_credentials_version_id   = module.idp_sql_db.db_credentials_version_id
}
