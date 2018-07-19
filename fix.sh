#!/bin/bash

export DEBIAN_FRONTEND=noninteractive


print_status() {
    echo
    echo "## $1"
    echo
}

systemctl stop zen-secnodetracker
systemctl stop zen-node
sleep 10

# Installation variables
stakeaddr=$(cat /mnt/zen/secnode/stakeaddr)
email=$(cat /mnt/zen/secnode/email)
fqdn=$(cat /mnt/zen/secnode/fqdn)
region=$(cat /mnt/zen/secnode/region)

if [ -f /mnt/zen/secnode/nodeid ]; then
  nodeid=$(cat /mnt/zen/secnode/nodeid)
else
  nodeid="null"
fi

nodetype="secure"

testnet=0
rpcpassword=$(head -c 32 /dev/urandom | base64)

print_status "Upgrading the ZenCash node..."

print_status "Trying to determine public ip addresses..."
publicips=$(dig $fqdn A $fqdn AAAA +short)
echo "#########################"
echo "fqdn: $fqdn"
echo "email: $email"
echo "stakeaddr: $stakeaddr"
echo "nodeid: $nodeid"
echo "region: $region"
echo "publicips: $publicips"
echo "#########################"


print_status "Creating the zen configuration."
cat <<EOF > /mnt/zen/config/zen.conf
rpcport=18231
rpcallowip=127.0.0.1
server=1
# Docker doesn't run as daemon
daemon=0
listen=1
txindex=1
logtimestamps=1
### testnet config
testnet=$testnet
rpcuser=user
rpcpassword=$rpcpassword
tlscertpath=/mnt/zen/certs/$fqdn/$fqdn.cer
tlskeypath=/mnt/zen/certs/$fqdn/$fqdn.key
#
port=9033
EOF

print_status "Trying to determine public ip addresses..."
publicips=$(dig $fqdn A $fqdn AAAA +short)
while read -r line; do
    echo "externalip=$line" >> /mnt/zen/config/zen.conf
done <<< "$publicips"

print_status "Creating the secnode config..."
mkdir -p /mnt/zen/secnode/
cat << EOF > /mnt/zen/secnode/config.json
{
 "active": "$nodetype",
 "$nodetype": {
  "nodetype": "$nodetype",
  "nodeid": $nodeid,
  "servers": [
   "ts2.eu",
   "ts1.eu",
   "ts3.eu",
   "ts4.eu",
   "ts4.na",
   "ts3.na",
   "ts2.na",
   "ts1.na"
  ],
  "stakeaddr": "$stakeaddr",
  "email": "$email",
  "fqdn": "$fqdn",
  "ipv": "4",
  "region": "$region",
  "home": "ts1.$region",
  "category": "none"
 }
}
EOF

systemctl start zen-node
systemctl start zen-secnodetracker
