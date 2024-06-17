locals {
  setup_node_file = "/scripts/setup-node.sh"
}

resource "tencentcloud_tat_command" "setup-node" {
  command_name      = "solana-setup-node"
  content           = file(join("", [path.module, local.setup_node_file]))
  description       = "Install and bootstrap the solana node process"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "solana_cli_version" : var.solana_cli_version,
    "solana_network" : var.solana_network,
    "solana_cli_directory" : var.solana_cli_directory,
    "solana_keys_directory" : var.solana_keys_directory,
    "solana_node_type" : var.solana_node_type,
    "solana_known_validators" : var.solana_known_validators,
    "solana_full_rpc_api" : var.solana_full_rpc_api,
    "solana_no_voting" : var.solana_no_voting,
    "solana_private_rpc" : var.solana_private_rpc,
    "solana_identity" : var.solana_identity,
    "solana_ledger_mount_point" : var.solana_ledger_mount_point,
    "solana_accounts_mount_point" : var.solana_accounts_mount_point,
    "solana_log_location" : var.solana_log_location,
    "solana_genesis_hash" : var.solana_genesis_hash,
  })
}
