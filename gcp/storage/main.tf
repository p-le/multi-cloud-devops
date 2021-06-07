data "google_project" "project" {
}

locals {
    region          = "asia-northeast1"
    project_number  = data.google_project.project.number
}

module "artifact_repositories" {
    source      = "./artifact-registry"
    location    = local.region
}

module "gcs_buckets" {
    source      = "./gcs-buckets"
}

module "cloudsql_dbs" {
    source      = "./cloudsql"
    region      = local.region
}

module "pubsub_topics" {
    source      = "./pubsub"
    project_number  = local.project_number
}

module "firestore" {
    source      = "./firestore"
}
