#!/usr/bin/env bash

SOLANA_CLI_DIRECTORY={{solana_cli_directory}}
SOLANA_KEYS_DIRECTORY={{solana_keys_directory}}
SOLANA_CLI_VERSION={{solana_cli_version}}
SOLANA_NETWORK={{solana_network}}
SOLANA_NODE_TYPE={{solana_node_type}}
SOLANA_KNOWN_VALIDATORS={{solana_known_validators}}
SOLANA_ENTRYPOINT={{solana_entrypoint}}
SOLANA_FULL_RPC_API={{solana_full_rpc_api}}
SOLANA_NO_VOTING={{solana_no_voting}}
SOLANA_PRIVATE_RPC={{solana_private_rpc}}
SOLANA_IDENTITY={{solana_identity}}

# COMMON
install_machine_packages() {
    echo "install_machine_packages: installing packages on the node"
    yum install -y jq curl nc bind-utils pkg-config  
}

install_solana_cli() {
    echo "install_solana_cli: installing the Solana cli in $SOLANA_CLI_DIRECTORY"
    mkdir -p $SOLANA_CLI_DIRECTORY
    cd $SOLANA_CLI_DIRECTORY

    sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_CLI_VERSION/install)"
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH" >> /root/.bash_profile
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
}

verify_solana_cli() {
    solana_path=$(which solana)
    echo "verify_solana_cli: checking Solana cli: $solana_path"
    solana config set --url $SOLANA_NETWORK
    solana config get
    echo "verify_solana_cli: configured $SOLANA_NETWORK for the Solana network"
}

system_tunning() {
    echo "tunning system"
    cat <<EOF > /etc/sysctl.d/21-solana-validator.conf
# Increase UDP buffer sizes
net.core.rmem_default = 134217728
net.core.rmem_max = 134217728
net.core.wmem_default = 134217728
net.core.wmem_max = 134217728

# Increase memory mapped files limit
vm.max_map_count = 1000000

# Increase number of allowed open file descriptors
fs.nr_open = 1000000
EOF

    sysctl -p /etc/sysctl.d/21-solana-validator.conf
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

configure_ledger_drive() {
    echo "formatting and configuring ledger drive"
}

configure_accountsdb_drive() {
    echo "formatting and configuring accountsdb drive"
}

setup_validator_startup_script() {
    echo "configuring validator startup script"
}

# RPC NODE
setup_rpc_node() {
    echo "configuring rpc node"
}

# SYSTEMD UNIT FILE
generate_systemd_unit_file() {
    echo "generating systemd unit file"
    IFS=' ' read -r -a validators_array <<< "$SOLANA_KNOWN_VALIDATORS"

    known_validators_args=""
    for validator in "${validators_array[@]}"; do
    known_validators_args+="--known-validator $validator "
    done

    IFS=' ' read -r -a entrypoints_array <<< "$SOLANA_ENTRYPOINT"
    entrypoints_args=""
    for entrypoint in "${entrypoints_array[@]}"; do
    entrypoints_args+="--entrypoint $entrypoint "
    done

    cmd="solana-validator \
    --identity $SOLANA_IDENTITY \
    $known_validators_args \
    --ledger $solana_ledger_mount_point \
    --accounts $solana_accounts_mount_point \
    --log $solana_log_location \
    --rpc-port 8899 \
    --rpc-bind-address 0.0.0.0 \
    --dynamic-port-range 8000-8020 \
    $entrypoints_args \
    --expected-genesis-hash $solana_genesis_hash \
    --wal-recovery-mode skip_any_corrupted_record \
    --limit-ledger-size"

    if [ "$SOLANA_FULL_RPC_API" == "true" ]; then
        cmd+=" --full-rpc-api"
    fi

    if [ "$SOLANA_NO_VOTING" == "true" ]; then
        cmd+=" --no-voting"
    fi

    if [ "$SOLANA_PRIVATE_RPC" == "true" ]; then
        cmd+=" --private-rpc"
    fi

    echo "generating systemd file for Solana process"
    cat <<EOF | sudo tee /etc/systemd/system/solana-validator.service
[Unit]
Description=Solana Validator Service
After=network.target

[Service]
Type=simple
User=sol   # Replace with the appropriate user
ExecStart=$cmd
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    
    echo "process will run with the following arguments $cmd"
    sudo systemctl daemon-reload
    sudo systemctl enable solana-validator
    # sudo systemctl start solana-validator
    # sudo systemctl status solana-validator
}

# ------------------------------
# main
# ------------------------------
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
    setup_validator_startup_script
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

system_tunning
generate_systemd_unit_file

#TODOD LOGROTATE