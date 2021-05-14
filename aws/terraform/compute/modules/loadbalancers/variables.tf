variable "organization" {
  description = "Organization Name"
  type        = string
}

variable "env" {
  description = "Target Env"
  type        = string
}

variable "vpc_id" {
  description = "Target VPC ID"
  type        = string
}

variable "subnets" {
  description = "Target Subnets"
  type        = list(string)
}

variable "security_groups" {
  description = "Attach Security Groups"
  type        = list(string)
  default     = []
}
