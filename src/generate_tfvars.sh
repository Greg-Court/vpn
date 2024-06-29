#!/bin/bash

# Determine the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the terraform.tfvars file relative to the script directory
TFVARS_FILE="$SCRIPT_DIR/terraform.tfvars"

# Generate the server keys
umask 077
SERVER_PRIVATE_KEY=$(wg genkey)
SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)

# Generate the client keys
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# Create or overwrite the terraform.tfvars file with the generated keys
cat <<EOL > "$TFVARS_FILE"
client_public_key  = "$CLIENT_PUBLIC_KEY"
client_private_key = "$CLIENT_PRIVATE_KEY"
server_public_key  = "$SERVER_PUBLIC_KEY"
server_private_key = "$SERVER_PRIVATE_KEY"
EOL

echo "Keys have been generated and written to $TFVARS_FILE"
