#!/usr/bin/env bash

SOLANA_SYSTEM_USER={{solana_system_user}}
SOLANA_NODE_TYPE={{solana_node_type}}
SOLANA_CLI_DIRECTORY={{solana_cli_directory}}
SOLANA_KEYS_DIRECTORY={{solana_keys_directory}}
SOLANA_CLI_VERSION={{solana_cli_version}}
SOLANA_LEDGER_MOUNT_POINT={{solana_ledger_mount_point}}
SOLANA_ACCOUNTS_MOUNT_POINT={{solana_accounts_mount_point}}

case {{solana_network}} in
  mainnet-beta)
    SOLANA_NETWORK="https://api.mainnet-beta.solana.com"
    ;;
  testnet)
    SOLANA_NETWORK="https://api.testnet.solana.com"
    ;;
  devnet)
    SOLANA_NETWORK="https://api.devnet.solana.com"
    ;;
  *)
    echo "unknown network: {{solana_network}}"
    exit 1
    ;;
esac

# COMMON
install_machine_packages() {
    echo "install_machine_packages: installing packages on the node"
    yum install -y jq curl nc bind-utils pkg-config sudo
}

install_solana_cli() {
    if [ ! -f /usr/local/bin/solana-validator ]; then
        echo "install_solana_cli: Solana cli already installed."
        return
    fi

    echo "install_solana_cli: installing the Solana cli in $SOLANA_CLI_DIRECTORY"
    mkdir -p $SOLANA_CLI_DIRECTORY
    cd $SOLANA_CLI_DIRECTORY

    sudo -u $SOLANA_SYSTEM_USER sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_CLI_VERSION/install)"
    export PATH="/home/$SOLANA_SYSTEM_USER/.local/share/solana/install/active_release/bin:$PATH" >> /home/${SOLANA_SYSTEM_USER}/.bash_profile
    export PATH="/home/$SOLANA_SYSTEM_USER/.local/share/solana/install/active_release/bin:$PATH"
    ln -s /home/$SOLANA_SYSTEM_USER/.local/share/solana/install/active_release/bin/solana-validator /usr/local/bin/solana-validator
    chown $SOLANA_SYSTEM_USER:$SOLANA_SYSTEM_USER /usr/local/bin/solana-validator
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
    if [ -f $SOLANA_KEYS_DIRECTORY/validator-keypair.json ]; then
        echo "generate_solana_keys: Solana keys already generated."
        return
    fi

    mkdir -p $SOLANA_KEYS_DIRECTORY
    cd $SOLANA_KEYS_DIRECTORY
    echo "generate_solana_keys: generating Solana keys in: $SOLANA_KEYS_DIRECTORY"
    solana-keygen new -o validator-keypair.json --no-bip39-passphrase
    solana-keygen new -o vote-account-keypair.json --no-bip39-passphrase
    solana-keygen new -o authorized-withdrawer-keypair.json --no-bip39-passphrase
    chown -R $SOLANA_SYSTEM_USER:$SOLANA_SYSTEM_USER $SOLANA_KEYS_DIRECTORY
}

create_vote_account() {
    echo "creating vote account"
}

create_solana_user() {
    if id "$SOLANA_SYSTEM_USER" &>/dev/null; then
        echo "create_solana_user: user $SOLANA_SYSTEM_USER already exists."
        return
    fi

    echo "create_solana_user: creating Solana system user: $SOLANA_SYSTEM_USER"
    adduser -m $SOLANA_SYSTEM_USER

    chown -R $SOLANA_SYSTEM_USER:$SOLANA_SYSTEM_USER $SOLANA_CLI_DIRECTORY

    usermod -aG sudo $SOLANA_SYSTEM_USER
    echo "$SOLANA_SYSTEM_USER ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$SOLANA_SYSTEM_USER
}

configure_ledger_drive() {
    if mountpoint -q "$SOLANA_LEDGER_MOUNT_POINT"; then
        echo "configure_ledger_drive: $SOLANA_LEDGER_MOUNT_POINT is already mounted."
        return
    fi

    echo "configure_ledger_drive: formatting and configuring ledger drive, we assume it is the first data disk vdb"
    mkfs -t ext4 /dev/vdb
    mkdir -p $SOLANA_LEDGER_MOUNT_POINT
    chown -R sol:sol $SOLANA_LEDGER_MOUNT_POINT
    mount /dev/vdb $SOLANA_LEDGER_MOUNT_POINT
    chown -R $SOLANA_SYSTEM_USER:$SOLANA_SYSTEM_USER $SOLANA_LEDGER_MOUNT_POINT
    echo "configure_ledger_drive: $SOLANA_LEDGER_MOUNT_POINT mounted."
}

configure_accountsdb_drive() {
    if mountpoint -q "$SOLANA_ACCOUNTS_MOUNT_POINT"; then
        echo "configure_accountsdb_drive: $SOLANA_ACCOUNTS_MOUNT_POINT is already mounted."
        return
    fi

    echo "configure_accountsdb_drive: formatting and configuring accountsdb drive, we assume it is the second data disk vdc"
    mkfs -t ext4 /dev/vdc
    mkdir -p $SOLANA_ACCOUNTS_MOUNT_POINT
    chown -R sol:sol $SOLANA_ACCOUNTS_MOUNT_POINT
    mount /dev/vdc $SOLANA_ACCOUNTS_MOUNT_POINT
    chown -R $SOLANA_SYSTEM_USER:$SOLANA_SYSTEM_USER $SOLANA_ACCOUNTS_MOUNT_POINT
    echo "configure_accountsdb_drive: $SOLANA_ACCOUNTS_MOUNT_POINT mounted."
}

install_literpc() {
  if [ -f /usr/local/bin/solana-lite-rpc ]; then
    echo "install_literpc: Solana lite rpc already installed."
    return
  fi

  curl -sSfL https://pub-909f63724b1b4aa1bb8797f77fec42db.r2.dev/solana-lite-rpc -o /usr/local/bin/solana-lite-rpc
  chmod +x /usr/local/bin/solana-lite-rpc
}

# RPC NODE
setup_rpc_node() {
    echo "configuring rpc node"
}

# ------------------------------
# main
# ------------------------------
install_machine_packages
create_solana_user

case $SOLANA_NODE_TYPE in
  validator)
    echo "solana node will be of type: validator"
    install_solana_cli
    verify_solana_cli
    generate_solana_keys
    create_vote_account
    configure_ledger_drive
    configure_accountsdb_drive
    ;;
  rpc)
    echo "solana node will be of type: rpc"
    install_solana_cli
    verify_solana_cli
    generate_solana_keys
    setup_rpc_node
    ;;
  literpc)
    echo "solana node will be of type: literpc"
    install_literpc
    ;;
  *)
    echo "unknown node type: $SOLANA_NODE_TYPE"
    exit 1
    ;;
esac
