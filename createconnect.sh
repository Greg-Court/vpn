#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WG_CONF_FILE="$SCRIPT_DIR/src/wg_vpn_fc.conf"
GEN_TFVARS_FILE="$SCRIPT_DIR/src/generate_tfvars.sh"

"$GEN_TFVARS_FILE"
terraform -chdir="$SCRIPT_DIR/src" apply --auto-approve
wg-quick up "$WG_CONF_FILE"
