SOLANA_NODE_TYPE={{solana_node_type}}
SOLANA_FULL_RPC_API={{solana_full_rpc_api}}
SOLANA_NO_VOTING={{solana_no_voting}}
SOLANA_PRIVATE_RPC={{solana_private_rpc}}
SOLANA_IDENTITY={{solana_identity}}

SOLANA_KNOWN_VALIDATOR1={{solana_known_validator1}}
SOLANA_KNOWN_VALIDATOR2={{solana_known_validator2}}
SOLANA_KNOWN_VALIDATOR3={{solana_known_validator3}}
SOLANA_KNOWN_VALIDATOR4={{solana_known_validator4}}
SOLANA_KNOWN_VALIDATOR5={{solana_known_validator5}}
SOLANA_KNOWN_VALIDATOR6={{solana_known_validator6}}

SOLANA_ENTRYPOINT1={{solana_entrypoint1}}
SOLANA_ENTRYPOINT2={{solana_entrypoint2}}
SOLANA_ENTRYPOINT3={{solana_entrypoint3}}

SOLANA_LEDGER_MOUNT_POINT={{solana_ledger_mount_point}}
SOLANA_ACCOUNTS_MOUNT_POINT={{solana_accounts_mount_point}}
SOLANA_LOG_LOCATION={{solana_log_location}}

SOLANA_GENESIS_HASH={{solana_genesis_hash}}

# SYSTEMD UNIT FILE
generate_systemd_unit_file() {
    echo "generating systemd unit file"

    cmd="solana-validator \
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
    if [ "$SOLANA_KNOWN_VALIDATOR1" != "" ]; then
        cmd+=" --known-validator $SOLANA_KNOWN_VALIDATOR1"
    fi
    if [ "$SOLANA_KNOWN_VALIDATOR2" != "" ]; then
        cmd+=" --known-validator $SOLANA_KNOWN_VALIDATOR2"
    fi
    if [ "$SOLANA_KNOWN_VALIDATOR3" != "" ]; then
        cmd+=" --known-validator $SOLANA_KNOWN_VALIDATOR3"
    fi
    if [ "$SOLANA_KNOWN_VALIDATOR4" != "" ]; then
        cmd+=" --known-validator $SOLANA_KNOWN_VALIDATOR4"
    fi
    if [ "$SOLANA_KNOWN_VALIDATOR5" != "" ]; then
        cmd+=" --known-validator $SOLANA_KNOWN_VALIDATOR5"
    fi
    if [ "$SOLANA_KNOWN_VALIDATOR6" != "" ]; then
        cmd+=" --known-validator $SOLANA_KNOWN_VALIDATOR6"
    fi

    # NETWORK ENDPOINTS
    if [ "$SOLANA_ENTRYPOINT1" != "" ]; then
        cmd+=" --entrypoint $SOLANA_ENTRYPOINT1"
    fi
    if [ "$SOLANA_ENTRYPOINT2" != "" ]; then
        cmd+=" --entrypoint $SOLANA_ENTRYPOINT2"
    fi
    if [ "$SOLANA_ENTRYPOINT3" != "" ]; then
        cmd+=" --entrypoint $SOLANA_ENTRYPOINT3"
    fi    

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

generate_systemd_unit_file