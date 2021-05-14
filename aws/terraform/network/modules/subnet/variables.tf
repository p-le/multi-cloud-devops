variable "name_prefix" {
  description = "Prefix Name"
  type        = string
}

variable "env" {
  description = "Target Env"
  type        = string
}

variable "vpc_id" {
  description = "Target VPC"
  type        = string
}

variable "availability_zone" {
  description = "Target Availability Zone"
  type        = string
}

variable "subnet_cidrs" {
  description = "CIDRs for both Public and Private Subnet"
  type        = list(string)
}
