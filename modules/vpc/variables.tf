variable "address_space" {
  type = string
}

variable "subnets" {
  description = "A list of subnets in the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "A list of AZs to be used"
  type        = list(string)
  default     = []
}

variable "addl_tags" {
  type = map(string)
  default = {}
}