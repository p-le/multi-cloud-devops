locals {
    project_id  = "viet-ocr-stage-8650711b"
    location    = "asia-northeast1"
    viet_ocr_image = "asia-northeast1-docker.pkg.dev/viet-ocr-stage-8650711b/viet-ocr-stage-repository/viet-ocr"
    viet_ocr_image_version = "1.0.0"
    viet_ocr_backend_image = "asia-northeast1-docker.pkg.dev/viet-ocr-stage-8650711b/viet-ocr-stage-repository/viet-ocr-backend"
    viet_ocr_backend_image_version = "1.0.0"
    viet_ocr_espv2_image            = "asia-northeast1-docker.pkg.dev/viet-ocr-stage-8650711b/viet-ocr-stage-repository/viet-ocr-espv2"
    viet_ocr_espv2_image_version    = "1.0.1"
    viet_ocr_api_gateway_image            = "asia-northeast1-docker.pkg.dev/viet-ocr-stage-8650711b/viet-ocr-stage-repository/viet-ocr-api-gateway"
    viet_ocr_api_gateway_image_version    = "viet-ocr-espv2-srv-6122-7oocugmkoq-an.a.run.app-2021-05-18r0"
}

resource "google_artifact_registry_repository" "viet_ocr_docker_repository" {
    provider = google-beta
    location = local.location
    repository_id   = "viet-ocr-stage-repository"
    description     = "Repository for Viet OCR"
    project = local.project_id
    format  = "DOCKER"
}

resource "google_service_account" "viet_ocr_cloudrun_revision" {
    account_id   = "viet-ocr-cloudrun-revision-sa"
    display_name = "Viet OCR Cloud run Revision Service Account"
}

resource "google_project_iam_member" "viet_ocr_cloudrun_serviceaccount_user" {
    role    = "roles/iam.serviceAccountUser"
    member  = "serviceAccount:${google_service_account.viet_ocr_cloudrun_revision.email}"
}

resource "google_project_iam_member" "viet_ocr_cloudrun_runadmin" {
    role    = "roles/run.admin"
    member  = "serviceAccount:${google_service_account.viet_ocr_cloudrun_revision.email}"
}

resource "google_project_iam_member" "viet_ocr_cloudrun_artifactregistry_reader" {
    role    = "roles/artifactregistry.reader"
    member  = "serviceAccount:${google_service_account.viet_ocr_cloudrun_revision.email}"
}


# module "viet_ocr_backend" {
#     source      = "./cloudrun/services/viet-ocr-backend"
#     name        = "viet-ocr-backend-srv"
#     image       = "${local.viet_ocr_backend_image}:${local.viet_ocr_backend_image_version}"
#     location    = local.location
#     labels      = {
#         role = "viet-ocr-backend"
#     }
#     service_account_name = google_service_account.viet_ocr_cloudrun_revision.email
# }

# resource "random_id" "viet_ocr_espv2_cloudrun_service" {
#   byte_length = 2
# }

# module "viet_ocr_espv2" {
#     source      = "./cloudrun/services/viet-ocr-espv2"
#     name        = "viet-ocr-espv2-srv-${random_id.viet_ocr_espv2_cloudrun_service.hex}"
#     image       = "${local.viet_ocr_espv2_image}:${local.viet_ocr_espv2_image_version}"
#     location    = local.location
#     labels      = {
#         role = "viet-ocr-espv2"
#     }
#     service_account_name = google_service_account.viet_ocr_cloudrun_revision.email
# }

# module "viet_ocr_api_gateway" {
#     source      = "./cloudrun/services/viet-ocr-api-gateway"
#     name        = "viet-ocr-api-gateway-srv"
#     image       = "${local.viet_ocr_api_gateway_image}:${local.viet_ocr_api_gateway_image_version}"
#     location    = local.location
#     labels      = {
#         role = "viet-ocr-api-gateway"
#     }
# }
