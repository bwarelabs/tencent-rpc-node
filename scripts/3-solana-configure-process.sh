SOLANA_SYSTEM_USER={{solana_system_user}}
SOLANA_FULL_RPC_API={{solana_full_rpc_api}}
SOLANA_NO_VOTING={{solana_no_voting}}
SOLANA_PRIVATE_RPC={{solana_private_rpc}}
SOLANA_IDENTITY={{solana_identity}}
SOLANA_NODE_TYPE={{solana_node_type}}

case {{solana_network}} in
    "mainnet-beta")
        SOLANA_KNOWN_VALIDATORS=(
            "7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2"
            "GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ"
            "DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ"
            "CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S"
        )
        SOLANA_ENTRYPOINTS=(
            "entrypoint.mainnet-beta.solana.com:8001"
            "entrypoint2.mainnet-beta.solana.com:8001"
            "entrypoint3.mainnet-beta.solana.com:8001"
            "entrypoint4.mainnet-beta.solana.com:8001"
            "entrypoint5.mainnet-beta.solana.com:8001"
        )
        SOLANA_GENESIS_HASH="5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d"
        ;;
    "testnet")
        SOLANA_KNOWN_VALIDATORS=(
            "5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on"
            "dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs"
            "Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN"
            "eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ"
            "9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv"
        )
        SOLANA_ENTRYPOINTS=(
            "entrypoint.testnet.solana.com:8001"
            "entrypoint2.testnet.solana.com:8001"
            "entrypoint3.testnet.solana.com:8001"
        )
        SOLANA_GENESIS_HASH="4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY"
        ;;
    "devnet")
        SOLANA_KNOWN_VALIDATORS=(
            "dv1ZAGvdsz5hHLwWXsVnM94hWf1pjbKVau1QVkaMJ92"
            "dv2eQHeP4RFrJZ6UeiZWoc3XTtmtZCUKxxCApCDcRNV"
            "dv4ACNkpYPcE3aKmYDqZm9G5EB3J4MRoeE7WNDRBVJB"
            "dv3qDFk1DTF36Z62bNvrCXe9sKATA6xvVy6A798xxAS"
        )
        SOLANA_ENTRYPOINTS=(
            "entrypoint.devnet.solana.com:8001"
            "entrypoint2.devnet.solana.com:8001"
            "entrypoint3.devnet.solana.com:8001"
            "entrypoint4.devnet.solana.com:8001"
            "entrypoint5.devnet.solana.com:8001"
        )
        SOLANA_GENESIS_HASH="EtWTRABZaYq6iMfeYKouRu166VU2xqa1wcaWoxPkrZBG"
        ;;
    *)
        echo "unknown network: {{solana_network}}"
        exit 1
        ;;
esac

SOLANA_LEDGER_MOUNT_POINT={{solana_ledger_mount_point}}
SOLANA_ACCOUNTS_MOUNT_POINT={{solana_accounts_mount_point}}
SOLANA_LOG_LOCATION={{solana_log_location}}

SOLANA_HBASE_CLUSTER_IP={{solana_hbase_cluster_ip}}

# SYSTEMD UNIT FILE
generate_solana_validator_systemd_unit_file() {
    echo "generate_systemd_unit_file: generating Solana cli"

    cmd="/usr/local/bin/solana-validator \
--identity $SOLANA_IDENTITY \
--ledger $SOLANA_LEDGER_MOUNT_POINT \
--accounts $SOLANA_ACCOUNTS_MOUNT_POINT \
--log $SOLANA_LOG_LOCATION \
--rpc-port 8899 \
--rpc-bind-address 0.0.0.0 \
--dynamic-port-range 8000-8020 \
--expected-genesis-hash $SOLANA_GENESIS_HASH \
--wal-recovery-mode skip_any_corrupted_record \
--limit-ledger-size"

    # VALIDATORS IDS
    for validator_id in "${SOLANA_KNOWN_VALIDATORS[@]}"; do
        cmd+=" --known-validator $validator_id"
    done

    # NETWORK ENDPOINTS
    for network_endpoint in "${SOLANA_ENTRYPOINTS[@]}"; do
        cmd+=" --entrypoint $network_endpoint"
    done

    if [ "$SOLANA_FULL_RPC_API" == "true" ]; then
        cmd+=" --full-rpc-api"
    fi

    if [ "$SOLANA_NO_VOTING" == "true" ]; then
        cmd+=" --no-voting"
    fi

    if [ "$SOLANA_PRIVATE_RPC" == "true" ]; then
        cmd+=" --private-rpc"
    fi

    echo "generate_systemd_unit_file: generating systemd file for Solana process"
    cat <<EOF | sudo tee /etc/systemd/system/solana-validator.service
[Unit]
Description=Solana Validator Service
After=network.target

[Service]
Type=simple
User=$SOLANA_SYSTEM_USER
ExecStart=$cmd
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    echo "generate_systemd_unit_file: Solana process will run with the following arguments: $cmd"
}

generate_solana_literpc_systemd_unit_file() {
    echo "generate_systemd_unit_file: generating Solana cli"

    cmd="/usr/local/bin/solana-lite-rpc --rpc-hbase-address $SOLANA_HBASE_CLUSTER_IP:9090"

    echo "generate_systemd_unit_file: generating systemd file for Solana process"
    cat <<EOF | sudo tee /etc/systemd/system/solana-lite-rpc.service
[Unit]
Description=Solana Lite RPC Service
After=network.target

[Service]
Type=simple
User=$SOLANA_SYSTEM_USER
ExecStart=$cmd
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    echo "generate_systemd_unit_file: Solana process will run with the following arguments: $cmd"
}

start_solana_process() {
    echo "start_solana_process: starting the Solana rpc node process"
    sudo systemctl daemon-reload
    sudo systemctl enable solana-validator
    sudo systemctl start solana-validator
}

start_solana_literpc_process() {
    echo "start_solana_process: starting the Solana rpc node process"
    sudo systemctl daemon-reload
    sudo systemctl enable solana-lite-rpc
    sudo systemctl start solana-lite-rpc
}

case $SOLANA_NODE_TYPE in
  validator)
    generate_solana_validator_systemd_unit_file
    start_solana_process
    ;;
  rpc)
    generate_solana_validator_systemd_unit_file
    start_solana_process
    ;;
  literpc)
    generate_solana_literpc_systemd_unit_file
    start_solana_literpc_process
    ;;
  *)
    echo "unknown node type: $SOLANA_NODE_TYPE"
    exit 1
    ;;


