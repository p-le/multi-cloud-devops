variable "name" {
    type = string
}
variable "backends" {
    type = list(map(string))
}
variable "loadbalancing_healthcheck" {
    type = string
}
variable "port_range" {
    type = string
}
