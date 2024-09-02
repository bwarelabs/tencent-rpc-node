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

# LEDGER DISK
variable "ledger_disk_type" {
  type        = string
  description = "The instace ledger disk type"
  default     = "CLOUD_PREMIUM"
}

variable "ledger_disk_size" {
  type        = number
  description = "The instace ledger disk size"
  default     = 50
}

variable "ledger_disk_encrypt" {
  type        = bool
  description = "Enable ledger disk encryption"
  default     = false
}

# ACCOUNTS DISK
variable "accounts_disk_type" {
  type        = string
  description = "The instace accounts disk type"
  default     = "CLOUD_PREMIUM"
}

variable "accounts_disk_size" {
  type        = number
  description = "The instace accounts disk size"
  default     = 50
}

variable "accounts_disk_encrypt" {
  type        = bool
  description = "Enable accounts disk encryption"
  default     = false
}

################################################################################
# SOLANA NODE DETAILS
################################################################################

variable "solana_node_type" {
  type        = string
  description = "Solana node type"
  default     = "validator"

  validation {
    condition = contains(["validator", "rpc", "literpc"], var.solana_node_type)
    error_message = "The Solana node type must be either validator, rpc, or literpc"
  }
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

variable "solana_cli_version" {
  type        = string
  description = "Solana CLI version"
  default     = "v1.18.22"
}

variable "solana_network" {
  type        = string
  description = "The Solana network to use for the node"
  default     = "mainnet-beta"

  validation {
    condition = contains(["devnet", "testnet", "mainnet-beta"], var.solana_network)
    error_message = "The Solana network must be either devnet, testnet, or mainnet-beta"
  }
}

variable "solana_system_user" {
  type        = string
  description = "The Solana system user"
  default     = "sol"
}

variable "solana_cli_directory" {
  type        = string
  description = "The location of the Solana cli"
  default     = "/home/sol/solana"
}

variable "solana_keys_directory" {
  type        = string
  description = "The location of the Solana keys"
  default     = "/home/sol/solana/keys"
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
  default     = "/home/sol/solana/keys/validator-keypair.json"
}

variable "solana_hbase_cluster_ip" {
  type        = string
  description = "The HBase cluster IP"
  default     = ""

  validation {
    condition = solana_node_type == "literpc" && var.solana_hbase_cluster_ip != ""
    error_message = "The HBase cluster IP must be provided for literpc nodes"
  }
}
