resource "tencentcloud_vpc_acl" "acl" {
  vpc_id  = var.vpc_id
  name    = format("%s%s", var.stack, var.acl_name)
  ingress = var.acl_ingress
  egress  = var.acl_egress

  tags = var.acl_tags
}

resource "tencentcloud_vpc_acl_attachment" "attachment" {
  for_each = var.subnets

  acl_id    = tencentcloud_vpc_acl.acl.id
  subnet_id = each.value.id
}
