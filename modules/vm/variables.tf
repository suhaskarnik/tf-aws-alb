variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "iam_instance_profile_id" {
  type = string
}

variable "addl_tags" {
    type = map(string)
    description = "(optional) Additional Tags"
}