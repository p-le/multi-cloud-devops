resource "google_cloudfunctions_function" "randomgen" {
    name        = "randomgen-fn"
    description = "Workflow - Randomgen"
    runtime     = "python39"
    available_memory_mb   = 128
    source_archive_bucket = var.bucket
    source_archive_object = var.randomgen_archive
    trigger_http          = true
    entry_point           = "randomgen"
    # ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
}

resource "google_cloudfunctions_function" "multiply" {
    name        = "multiply-fn"
    description = "Workflow - Multiply"
    runtime     = "python39"
    available_memory_mb   = 128
    source_archive_bucket = var.bucket
    source_archive_object = var.multiply_archive
    trigger_http          = true
    entry_point           = "multiply"
    # ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
}

resource "google_cloudfunctions_function_iam_member" "ramdomgen_invoker" {
    project        = google_cloudfunctions_function.randomgen.project
    region         = google_cloudfunctions_function.randomgen.region
    cloud_function = google_cloudfunctions_function.randomgen.name

    role   = "roles/cloudfunctions.invoker"
    member = "serviceAccount:${var.service_account}"
}

resource "google_cloudfunctions_function_iam_member" "multiply_invoker" {
    project        = google_cloudfunctions_function.multiply.project
    region         = google_cloudfunctions_function.multiply.region
    cloud_function = google_cloudfunctions_function.multiply.name

    role   = "roles/cloudfunctions.invoker"
    member = "serviceAccount:${var.service_account}"
}
