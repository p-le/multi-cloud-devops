output "ramdomgen_trigger_url" {
    value = google_cloudfunctions_function.randomgen.https_trigger_url
}
output "multiply_trigger_url" {
    value = google_cloudfunctions_function.multiply.https_trigger_url
}
