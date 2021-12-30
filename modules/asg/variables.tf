variable "iam_instance_profile_name" {
  type = string
}

variable "vpc" {
  type = string
}

# variable "azs" {
#   type = list(string)
#   description = "(optional) describe your variable"
# }

variable "subnet_ids" {
  type = list(string)
}


variable "addl_tags" {
  type = map(string)
}