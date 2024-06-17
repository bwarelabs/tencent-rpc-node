variable "stack" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = map(any)
}

variable "acl_name" {
  type = string
}

variable "acl_ingress" {
  type = list(string)
}

variable "acl_egress" {
  type = list(string)
}

variable "acl_tags" {
  type = map(string)
}
