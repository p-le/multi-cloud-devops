variable "organization" {
  description = "Organization Name"
  type        = string
}

variable "env" {
  description = "Target Env"
  type        = string
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Target Key Pair"
  type        = string
}

variable "security_groups" {
  description = "Attach Security Groups"
  type        = list(string)
  default     = []
}
