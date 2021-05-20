
resource "google_project_iam_member" "workflow_invoker" {
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${var.service_account}"
}

resource "google_workflows_workflow" "example" {
    name          = var.name
    region        = var.region
    description   = "Workflow Cloud Run + Cloud Functions"
    service_account = var.service_account_id
    source_contents = templatefile("${path.module}/workflow.yaml", {
        _RANDOMGEN_TRIGGER_URL: var.randomgen_trigger_url,
        _MULTIPLY_TRIGGER_URL: var.multiply_trigger_url,
        _FLOOR_SERVICE_ENDPOINT: var.floor_service_endpoint
    })
}
