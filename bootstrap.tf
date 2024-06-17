locals {
  solana_setup_node_file      = "/scripts/1-solana-setup-node.sh"
  solana_system_configuration = "/scripts/2-solana-system-configuration.sh"
  solana_configure_process    = "/scripts/3-solana-configure-process.sh"
}

resource "tencentcloud_tat_command" "solana-setup-node" {
  command_name      = "1-solana-setup-node"
  content           = file(join("", [path.module, local.solana_setup_node_file]))
  description       = "Install and configure the node"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "solana_node_type" : var.solana_node_type,
    "solana_cli_directory" : var.solana_cli_directory,
    "solana_keys_directory" : var.solana_keys_directory,
    "solana_cli_version" : var.solana_cli_version,
    "solana_network" : var.solana_network,
    "solana_ledger_mount_point" : var.solana_ledger_mount_point,
    "solana_accounts_mount_point" : var.solana_accounts_mount_point,
  })
}

resource "tencentcloud_tat_command" "solana-system-configuration" {
  command_name      = "2-solana-system-configuration"
  content           = file(join("", [path.module, local.solana_system_configuration]))
  description       = "Perform the node system configuration"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
}

resource "tencentcloud_tat_command" "solana-configure-process" {
  command_name      = "3-solana-configure-process"
  content           = file(join("", [path.module, local.solana_configure_process]))
  description       = "Configure the Solana process on the node"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "solana_entrypoint1" : var.solana_entrypoint1,
    "solana_entrypoint2" : var.solana_entrypoint2,
    "solana_entrypoint3" : var.solana_entrypoint3,
    "solana_known_validator1" : var.solana_known_validator1,
    "solana_known_validator2" : var.solana_known_validator2,
    "solana_known_validator3" : var.solana_known_validator3,
    "solana_known_validator4" : var.solana_known_validator4,
    "solana_known_validator5" : var.solana_known_validator5,
    "solana_known_validator6" : var.solana_known_validator6,
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
