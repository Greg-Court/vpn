#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WG_CONF_FILE="$SCRIPT_DIR/src/wg_vpn_fc.conf"

wg-quick down "$WG_CONF_FILE"
terraform -chdir="$SCRIPT_DIR/src" destroy --auto-approve