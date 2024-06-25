################################################################################
# VPC
################################################################################

resource "tencentcloud_vpc" "vpc" {
  count        = var.create_vpc ? 1 : 0
  name         = format("%s%s", var.stack, var.vpc_name)
  cidr_block   = var.vpc_cidr
  is_multicast = var.vpc_is_multicast
  dns_servers  = length(var.vpc_dns_servers) > 0 ? var.vpc_dns_servers : null
  tags         = var.vpc_tags
}

resource "tencentcloud_route_table" "route_table" {
  count  = var.create_route_table ? 1 : 0
  name   = format("%s%s", var.stack, "route_table")
  vpc_id = var.vpc_id != "" ? var.vpc_id : tencentcloud_vpc.vpc[0].id
  tags   = var.route_table_tags
}

resource "tencentcloud_subnet" "subnet" {
  for_each = { for subnet in var.subnet_cidrs : subnet.name => subnet }

  name              = format("%s%s", var.stack, each.value.name)
  vpc_id            = var.vpc_id != "" ? var.vpc_id : tencentcloud_vpc.vpc[0].id
  cidr_block        = each.value.cidr_block
  is_multicast      = each.value.is_multicast
  availability_zone = each.value.availability_zone
  route_table_id    = var.route_table_id != "" ? var.route_table_id : var.create_route_table ? tencentcloud_route_table.route_table[0].id : null
  tags              = var.subnets_tags
}

resource "tencentcloud_route_table_entry" "route_entry" {
  for_each = { for idx, entry in var.route_entries : idx => entry }

  route_table_id         = var.route_table_id != "" ? var.route_table_id : var.create_route_table ? tencentcloud_route_table.route_table[0].id : null
  destination_cidr_block = each.value.destination_cidr_block
  next_type              = each.value.next_type
  next_hub               = each.value.next_hub
}

################################################################################
# Network ACL
################################################################################

module "acls" {
  source = "./modules/vpc_acl"

  for_each = { for acl in var.vpc_acls : acl.name => acl }

  stack       = var.stack
  vpc_id      = var.vpc_id != "" ? var.vpc_id : tencentcloud_vpc.vpc[0].id
  acl_name    = each.key
  acl_egress  = each.value.egress
  acl_ingress = each.value.ingress
  acl_tags    = var.vpc_acl_tags
  subnets     = tencentcloud_subnet.subnet

  depends_on = [tencentcloud_subnet.subnet]
}
