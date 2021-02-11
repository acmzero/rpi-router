#!/bin/bash
# set the routes and ip forwarding

source env.sh

# enable port forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -F
for iface in $isp_interfaces; do
    iptables -t nat -A POSTROUTING -o $iface -j MASQUERADE
    iptables -A FORWARD -i $listen_interface -o $iface -j ACCEPT
    iptables -A FORWARD -i $iface -o $listen_interface -m state --state RELATED,ESTABLISHED -j ACCEPT

    offset_gateway $iface $metrics_starting_offset
done

