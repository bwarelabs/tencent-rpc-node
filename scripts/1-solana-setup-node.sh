#!/usr/bin/env bash

SOLANA_SYSTEM_USER={{solana_system_user}}
SOLANA_NODE_TYPE={{solana_node_type}}
SOLANA_CLI_DIRECTORY={{solana_cli_directory}}
SOLANA_KEYS_DIRECTORY={{solana_keys_directory}}
SOLANA_CLI_VERSION={{solana_cli_version}}
SOLANA_NETWORK={{solana_network}}
SOLANA_LEDGER_MOUNT_POINT={{solana_ledger_mount_point}}
SOLANA_ACCOUNTS_MOUNT_POINT={{solana_accounts_mount_point}}

# COMMON
install_machine_packages() {
    echo "install_machine_packages: installing packages on the node"
    yum install -y jq curl nc bind-utils pkg-config  
}

install_solana_cli() {
    echo "install_solana_cli: installing the Solana cli in $SOLANA_CLI_DIRECTORY"
    mkdir -p $SOLANA_CLI_DIRECTORY
    cd $SOLANA_CLI_DIRECTORY

    sudo -u $SOLANA_SYSTEM_USER sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_CLI_VERSION/install)"
    export PATH="/home/$SOLANA_SYSTEM_USER/.local/share/solana/install/active_release/bin:$PATH" >> /home/${SOLANA_SYSTEM_USER}/.bash_profile
    export PATH="/home/$SOLANA_SYSTEM_USER/.local/share/solana/install/active_release/bin:$PATH"
}

verify_solana_cli() {
    solana_path=$(which solana)
    echo "verify_solana_cli: checking Solana cli: $solana_path"
    solana config set --url $SOLANA_NETWORK
    solana config get
    echo "verify_solana_cli: configured $SOLANA_NETWORK for the Solana network"
}

# VALIDATOR
generate_solana_keys() {
    mkdir -p $SOLANA_KEYS_DIRECTORY
    cd $SOLANA_KEYS_DIRECTORY
    echo "generate_solana_keys: generating Solana keys in: $SOLANA_KEYS_DIRECTORY"
    solana-keygen new -o validator-keypair.json --no-bip39-passphrase
    solana-keygen new -o vote-account-keypair.json --no-bip39-passphrase
    solana-keygen new -o authorized-withdrawer-keypair.json --no-bip39-passphrase
}

create_vote_account() {
    echo "creating vote account"
}

create_solana_user() {
    echo "create_solana_user: creating Solana system user: $SOLANA_SYSTEM_USER"

    if id "$SOLANA_SYSTEM_USER" &>/dev/null; then
        echo "create_solana_user: user $SOLANA_SYSTEM_USER already exists."
    else
        adduser -m $SOLANA_SYSTEM_USER
        
        chown -R $SOLANA_SYSTEM_USER:$SOLANA_SYSTEM_USER $SOLANA_CLI_DIRECTORY

        sudo usermod -aG sudo $SOLANA_SYSTEM_USER
        echo "$SOLANA_SYSTEM_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$SOLANA_SYSTEM_USER
    fi
}

configure_ledger_drive() {
    echo "configure_ledger_drive: formatting and configuring ledger drive, we assume it is the first data disk vdb"
    if mountpoint -q "$SOLANA_LEDGER_MOUNT_POINT"; then
        echo "configure_ledger_drive: $SOLANA_LEDGER_MOUNT_POINT is already mounted."
    else
        mkfs -t ext4 /dev/vdb
        mkdir -p $SOLANA_LEDGER_MOUNT_POINT
        chown -R sol:sol $SOLANA_LEDGER_MOUNT_POINT
        mount /dev/vdb $SOLANA_LEDGER_MOUNT_POINT
        echo "configure_ledger_drive: $SOLANA_LEDGER_MOUNT_POINT mounted."
    fi
}

configure_accountsdb_drive() {
    echo "configure_accountsdb_drive: formatting and configuring accountsdb drive, we assume it is the second data disk vdc"
    if mountpoint -q "$SOLANA_ACCOUNTS_MOUNT_POINT"; then
        echo "configure_accountsdb_drive: $SOLANA_ACCOUNTS_MOUNT_POINT is already mounted."
    else
        mkfs -t ext4 /dev/vdc
        mkdir -p $SOLANA_ACCOUNTS_MOUNT_POINT
        chown -R sol:sol $SOLANA_ACCOUNTS_MOUNT_POINT
        mount /dev/vdc $SOLANA_ACCOUNTS_MOUNT_POINT
        echo "configure_accountsdb_drive: $SOLANA_ACCOUNTS_MOUNT_POINT mounted."
    fi
}

# RPC NODE
setup_rpc_node() {
    echo "configuring rpc node"
}

# ------------------------------
# main
# ------------------------------
create_solana_user
install_machine_packages
install_solana_cli
verify_solana_cli
generate_solana_keys

case $SOLANA_NODE_TYPE in
  validator)
    echo "solana node will be of type: validator"
    create_vote_account
    configure_ledger_drive
    configure_accountsdb_drive
    ;;
  rpc)
    echo "solana node will be of type: rpc"
    setup_rpc_node
    ;;
  *)
    echo "unknown node type: $SOLANA_NODE_TYPE"
    exit 1
    ;;
esac
