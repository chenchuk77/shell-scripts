#!/bin/bash

netstat -rn > /tmp/routes-before
PPP_GW=$(netstat -rn | grep ppp0 | awk '{ print $2 }')
if [[ -z $PPP_GW ]]; then
  echo "cannot find the ppp interface, make sure VPN is connected..."
  exit 99
fi

echo "adding private routes (RFC-1918) via the ppp0 vpn interface ..."
sudo route add -net 10.0.0.0    gw ${PPP_GW} netmask 255.0.0.0   dev ppp0
sudo route add -net 192.168.0.0 gw ${PPP_GW} netmask 255.255.0.0 dev ppp0
sudo route add -net 172.16.0.0  gw ${PPP_GW} netmask 255.240.0.0 dev ppp0

echo "deleting default gateway from ppp0..."
sudo route delete -net 0.0.0.0  gw ${PPP_GW} netmask 0.0.0.0     dev ppp0

netstat -rn > /tmp/routes-after

diff -d /tmp/routes-before /tmp/routes-after | colordiff


