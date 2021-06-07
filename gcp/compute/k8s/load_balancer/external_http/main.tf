resource "google_compute_backend_service" "default" {
    provider    = google-beta
    name        = "${var.name}-backend"
    protocol    = "HTTP"
    load_balancing_scheme = "EXTERNAL"
    dynamic "backend" {
        for_each = var.backends
        content {
            group = backend.value["igm"]
            balancing_mode = backend.value["balancing_mode"]
        }
    }
    timeout_sec                     = 10
    connection_draining_timeout_sec = 10
    health_checks = [
        var.loadbalancing_healthcheck
    ]
}

resource "google_compute_url_map" "urlmap" {
    name        = "${var.name}-urlmap"
    description = "${title(var.name)} URL Map"
    default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
    name    = "${var.name}-http-proxy"
    url_map = google_compute_url_map.urlmap.id
}

resource "google_compute_global_forwarding_rule" "default" {
    name       = "${var.name}-forwarding-rule"
    target     = google_compute_target_http_proxy.default.id
    port_range = var.port_range
}
