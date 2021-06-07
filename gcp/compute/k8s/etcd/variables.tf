variable "region" {
    type = string
}
variable "zones" {
    type = list(string)
}
variable "target_size" {
    type = number
}
variable "service_account_email" {
    type = string
}
