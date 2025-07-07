
variable "network_cidr" {
  description = "CIDR block for this network."
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for this subnet."
  default     = "10.0.0.0/24"
  type        = string
}
