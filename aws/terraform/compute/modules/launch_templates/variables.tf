variable "organization" {
  description = "Organization Name"
  type        = string
}

variable "env" {
  description = "Target Env"
  type        = string
}

variable "key_name" {
  description = "Target Key Pair"
  type        = string
}

variable "subnets" {
  description = "Target Subnets"
  type        = list(string)
}
