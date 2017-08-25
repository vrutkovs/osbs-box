#!/bin/bash
set -xeuo pipefail

WORKSTATION_IP=$(/sbin/ip route | awk '/default/ { print $3 }')
sed -i "s/WORKSTATION_IP/${WORKSTATION_IP}/" /etc/kojiweb/web.conf

# Use kojiadmin user by default
mkdir -p /root/.koji
ln -fs /opt/koji-clients/kojiadmin/config /root/.koji/config
