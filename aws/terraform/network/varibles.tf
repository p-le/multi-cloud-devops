variable "availability_zones" {
  description = "Target Availability Zones"
  type        = list(string)
  default     = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d"
  ]
}
