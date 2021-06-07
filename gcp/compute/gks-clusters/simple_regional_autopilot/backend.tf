terraform {
    backend "gcs" {
        bucket  = "multicloud-architect-terraform"
        prefix  = "gks-clusters/simple-regional-autopilot"
    }
}
