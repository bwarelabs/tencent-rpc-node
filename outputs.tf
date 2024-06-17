output "subnet_ids" {
  value = {
    for key, subnet in tencentcloud_subnet.subnet : key => subnet.id
  }
}

output "vpc_id" {
  value = var.create_vpc ? tencentcloud_vpc.vpc[0].id : null
}
