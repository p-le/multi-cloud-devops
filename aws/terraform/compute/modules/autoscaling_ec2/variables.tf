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

variable "availability_zones" {
  description = "Target Availability Zones"
  type        = list(string)
}

variable "subnets" {
  description = "Target Subnets"
  type        = list(string)
}

variable "launch_template" {
  description = "Target Launch Template"
  type        = string
}

variable "launch_configuration" {
  description = "Target Launch Configuration"
  type        = string
}

variable "frontend_target_arn" {
  description = "Frontend Target ARN"
  type        = string
}
