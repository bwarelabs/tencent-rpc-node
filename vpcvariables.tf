################################################################################
# STACK VARIABLES
################################################################################

variable "stack" {
  type        = string
  description = "Specify a stack name that would be prefixed to each resource created with this module"
  default     = "tencent-"
}

################################################################################
# VPC VARIABLES
################################################################################

variable "create_vpc" {
  type        = bool
  description = "Enable the creation of the VPC"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "Specify a VPC id if you want to deploy the RPC nodes within a existing VPC"
  default     = ""
}

variable "vpc_name" {
  type        = string
  description = "Tencent VPC name"
  default     = "tencent_rpc_node"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block that will be used by the VPC"
  default     = "172.16.0.0/16"
}

variable "vpc_is_multicast" {
  type        = bool
  description = "Enable or disable VPC multicast"
  default     = true
}

variable "vpc_dns_servers" {
  type        = set(string)
  description = "Specify one or more DNS servers to be used within the VPC"
  default     = []
}

variable "vpc_tags" {
  type        = map(string)
  description = "Specify one or more tags for the VPC"
  default = {
    "network" : "tencent",
    "type" : "rpc",
  }
}

################################################################################
# ROUTE TABLE VARIABLES
################################################################################

variable "create_route_table" {
  type        = bool
  description = "Enable the creation of the route table"
  default     = true
}

variable "route_table_id" {
  type        = string
  description = "Specify a route table id if you want to reuse an existing route table"
  default     = ""
}

variable "route_table_tags" {
  type        = map(string)
  description = "Specify one or more tags for the route table"
  default = {
    "network" : "tencent",
    "type" : "rpc",
  }
}

################################################################################
# ROUTE TABLE ROUTES VARIABLES
################################################################################

variable "route_entries" {
  type = list(object({
    destination_cidr_block = string
    next_type              = string
    next_hub               = string
  }))
  default = [
    {
      destination_cidr_block = "0.0.0.0/0"
      next_type              = "EIP"
      next_hub               = "0"
    }
  ]
}

################################################################################
# VPC SUBNETS VARIABLES
################################################################################

variable "subnet_ids" {
  type        = list(string)
  description = "Specify existing subnet ids without creating them using this module, if this is specified then subnet_cidrs must NOT be configured"
  default     = []
}

variable "subnet_cidrs" {
  type = list(object({
    name              = string
    cidr_block        = string
    is_multicast      = string
    availability_zone = string
  }))
  description = "Specify one or more subnets to create within the VPC, either use this parameter or subnet_ids but not both"
  default = [
    {
      "name" : "rpc_subnet_1",
      "cidr_block" : "172.16.100.0/24",
      "is_multicast" : true,
      "availability_zone" : "eu-frankfurt-1",
    }
  ]
}

variable "subnets_tags" {
  type        = map(string)
  description = "Specify one or more tags for the subnets"
  default = {
    "network" : "tencent",
    "type" : "rpc",
  }
}

################################################################################
# Network ACL VARIABLES
################################################################################

variable "vpc_acls" {
  type = list(object({
    name    = string
    ingress = list(string)
    egress  = list(string)

  }))
  description = "Specify one or more ACLs to attach to the subnets"
  default = [
    {
      "name" : "egress-acl",
      "ingress" : ["ACCEPT#0.0.0.0/0#ALL#ALL"],
      "egress" : ["ACCEPT#0.0.0.0/0#ALL#ALL"],
    }
  ]
}

variable "vpc_acl_tags" {
  type        = map(string)
  description = "Specify one or more tags for the VPC ACLs"
  default = {
    "network" : "tencent",
    "type" : "rpc",
  }
}
