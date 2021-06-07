variable "location" {
  type = string
}
variable "image" {
  type = string
}
variable "secret_name" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "labels" {
  type = map(string)
}
variable "service_account_name" {
  type = string
}

