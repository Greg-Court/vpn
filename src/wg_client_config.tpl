[Interface]
PrivateKey = ${client_private_key}
Address = ${client_address}
DNS = 8.8.8.8

[Peer]
PublicKey = ${server_public_key}
Endpoint = ${vm_public_ip}:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
