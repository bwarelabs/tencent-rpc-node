data "tencentcloud_images" "rpc_image" {
  count            = var.image_id != "" ? 0 : 1
  image_type       = var.image_type
  image_name_regex = var.image_name_regex
}

resource "tencentcloud_instance" "rpc_node" {
  count             = var.instance_count
  instance_name     = "${var.instance_name}-${count.index}"
  availability_zone = var.subnet_cidrs != [] ? var.subnet_cidrs[count.index % length(var.subnet_cidrs)].availability_zone : var.availability_zone
  image_id          = var.image_id != "" ? var.image_id : data.tencentcloud_images.rpc_image[0].image_id
  instance_type     = var.instance_type

  system_disk_type = var.system_disk_type
  system_disk_size = var.system_disk_size

  hostname   = "${var.instance_name}-${count.index}"
  project_id = var.instance_project
  vpc_id     = var.create_vpc ? tencentcloud_vpc.vpc[0].id : var.vpc_id
  subnet_id  = var.subnet_cidrs != [] ? values(tencentcloud_subnet.subnet)[count.index % length(values(tencentcloud_subnet.subnet))].id : var.subnet_id

  instance_charge_type                = var.instance_charge_type
  instance_charge_type_prepaid_period = var.instance_charge_type_prepaid_period
  # instance_charge_type_prepaid_renew_flag = var.instance_charge_type_prepaid_renew_flag

  data_disks {
    data_disk_type = var.ledger_disk_type
    data_disk_size = var.ledger_disk_size
    encrypt        = var.ledger_disk_encrypt
  }

  data_disks {
    data_disk_type = var.accounts_disk_type
    data_disk_size = var.accounts_disk_size
    encrypt        = var.accounts_disk_encrypt
  }

  force_delete = var.force_delete
  tags         = var.instance_tags
}
