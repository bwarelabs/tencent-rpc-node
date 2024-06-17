################################################################################
# IMAGE VARIABLES
################################################################################

variable "image_id" {
  type        = string
  description = "The RPC node image id, if this is provided then it will override other image parameters below"
  default     = "img-eb30mz89"
}

variable "image_type" {
  type        = list(string)
  description = "The RPC node image type, this parameter and image_name_regex are used only if image_id is set to empty value"
  default     = ["PUBLIC_IMAGE"]
}

variable "image_name_regex" {
  type        = string
  description = "The RPC node image id, if this is provided then it will override other image parameters below"
  default     = "Solana"
}

################################################################################
# INSTANCE VARIABLES
################################################################################

variable "instance_count" {
  type        = number
  description = "The number of RPC nodes to bootstrap"
  default     = 1
}

variable "instance_name" {
  type        = string
  description = "The instace name prefix"
  default     = "solana"
}

variable "instance_project" {
  type        = number
  description = "The project the instance belongs to"
  default     = 0
}

variable "instance_type" {
  type        = string
  description = "The instace type"
  default     = "SA2.MEDIUM8"
}

variable "instance_charge_type" {
  type        = string
  description = "The charge type of instance"
  default     = "POSTPAID_BY_HOUR"
}

variable "instance_charge_type_prepaid_period" {
  type        = number
  description = "The tenancy (time unit is month) of the prepaid instance"
  default     = 1
}

variable "instance_charge_type_prepaid_renew_flag" {
  type        = string
  description = "Auto renewal flag"
  default     = "NOTIFY_AND_MANUAL_RENEW"
}

variable "force_delete" {
  type        = bool
  description = "Indicate whether to force delete the instance"
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "The subnet id for the instance"
  default     = ""
}

variable "availability_zone" {
  type        = string
  default     = "The instance availability zone"
  description = ""
}

variable "instance_tags" {
  type        = map(string)
  description = "Specify one or more tags for the instance"
  default = {
    "network" : "tencent",
    "type" : "rpc",
  }
}

################################################################################
# INSTANCE DISKS
################################################################################

variable "system_disk_type" {
  type        = string
  description = "The instace system disk type"
  default     = "CLOUD_PREMIUM"
}

variable "system_disk_size" {
  type        = number
  description = "The instace system disk size"
  default     = 50
}

variable "data_disk_type" {
  type        = string
  description = "The instace data disk type"
  default     = "CLOUD_PREMIUM"
}

variable "data_disk_size" {
  type        = number
  description = "The instace data disk size"
  default     = 50
}

variable "data_disk_encrypt" {
  type        = bool
  description = "Enable data disk encryption"
  default     = false
}

################################################################################
# SOLANA NODE DETAILS
################################################################################

variable "solana_node_type" {
  type        = string
  description = "Solana node type"
  default     = "validator"
}

variable "solana_ledger_mount_point" {
  type        = string
  description = "Ledger disk mount point"
  default     = "/mnt/ledger"
}

variable "solana_accounts_mount_point" {
  type        = string
  description = "Accounts disk mount point"
  default     = "/mnt/accounts"
}

################################################################################
# SOLANA NETWORK DETAILS
################################################################################

variable "solana_known_validators" {
  type        = list(string)
  description = "Solana known validators ids"
  default = [
    "5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on",
    "dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs",
    "eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ",
    "7XSY3MrYnK8vq693Rju17bbPkCN3Z7KvvfvJx4kdrsSY",
    "Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN",
    "9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv"
  ]
}

variable "solana_genesis_hash" {
  type        = string
  description = "The expected Solana genesis hash"
  default     = "4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY"
}

variable "solana_cli_version" {
  type        = string
  description = "Solana CLI version"
  default     = "v1.18.14"
}

variable "solana_network" {
  type        = string
  description = "The Solana network to use for the node"
  default     = "https://api.testnet.solana.com"
}

variable "solana_cli_directory" {
  type        = string
  description = "The location of the Solana cli"
  default     = "/root/solana"
}

variable "solana_keys_directory" {
  type        = string
  description = "The location of the Solana keys"
  default     = "/root/solana/keys"
}

variable "solana_log_location" {
  type        = string
  description = "The location of the Solana log"
  default     = "/home/sol/solana-rpc.log"
}

variable "solana_full_rpc_api" {
  type        = string
  description = "Enable full RPC API on the node"
  default     = "true"
}

variable "solana_no_voting" {
  type        = string
  description = "Enable no voting flag on the node"
  default     = "true"
}

variable "solana_private_rpc" {
  type        = string
  description = "Enable private rpc flag on the node"
  default     = "true"
}

variable "solana_identity" {
  type        = string
  description = "The Solana node identity"
  default     = "/root/solana/keys/validator-keypair.json"
}
