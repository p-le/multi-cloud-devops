variable "istio" {
    description = "Boolean to enable / disable Istio"
    default     = true
}

variable "cloudrun" {
    description = "Boolean to enable / disable CloudRun"
    default     = true
}

variable "dns_cache" {
    type        = bool
    description = "(Beta) The status of the NodeLocal DNSCache addon."
    default     = false
}

variable "gce_pd_csi_driver" {
    type        = bool
    description = "(Beta) Whether this cluster should enable the Google Compute Engine Persistent Disk Container Storage Interface (CSI) Driver."
    default     = false
}

variable "sandbox_enabled" {
    type        = bool
    description = "(Beta) Enable GKE Sandbox (Do not forget to set `image_type` = `COS_CONTAINERD` and `node_version` = `1.12.7-gke.17` or later to use it)."
    default     = false
}

variable "remove_default_node_pool" {
    type        = bool
    description = "Remove default node pool while setting up the cluster"
    default     = false
}

variable "node_pools" {
    type        = list(map(string))
    description = "List of maps containing node pools"

    default = [
        {
            name = "default-node-pool"
        },
    ]
}

variable "database_encryption" {
    description = "Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key."
    type        = list(object({ state = string, key_name = string }))
    default = [{
        state    = "DECRYPTED"
        key_name = ""
    }]
}

variable "enable_binary_authorization" {
    description = "Enable BinAuthZ Admission controller"
    default     = false
}

variable "enable_pod_security_policy" {
    type        = bool
    description = "enabled - Enable the PodSecurityPolicy controller for this cluster. If enabled, pods must be valid under a PodSecurityPolicy to be created."
    default     = false
}

variable "datapath_provider" {
    type        = string
    description = "The desired datapath provider for this cluster. By default, uses the IPTables-based kube-proxy implementation."
    default     = "DATAPATH_PROVIDER_UNSPECIFIED"
}
