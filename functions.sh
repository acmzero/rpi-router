#!/bin/bash
# define functions for the other scripts


function get_ping(){
    iface=$1
    ping_result=$(ping -I $iface -4 -c $ping_sample_count $ping_host)
    avg_ping=$(echo "$ping_result" | grep rtt | awk '{ print $4 }' | awk -F/ '{ print $2 }' ) 
    if [ -z "$avg_ping" ]; then
	    avg_ping=99999
    fi
    echo "$avg_ping"
}

function get_current_gateway(){
    current_gateway=$( route -n | grep UG | head -1 | awk '{ print $8 }' )
    echo "$current_gateway"
}

function get_metric(){
    iface=$1
    metric=$(route -n | grep UG | grep "$iface" | awk '{ print $5 }' | head -1)
    echo "$metric"
}
function get_min_latency_interface(){
    current_gateway=$(get_current_gateway)
    current_latency=99999
    min_latency=99999
    min_interface=$current_gateway

    1>&2 echo "Current gateway $current_gateway"
    1>&2 echo "Calculating latency for interfaces $isp_interfaces"
    for iface in $isp_interfaces; do
	1>&2 echo "Calucating latency for $iface"
        latency=$(get_ping $iface)
	1>&2 echo "Got $latency for $iface"
	if (( $(echo "$latency<$min_latency" | bc -l) )); then
            min_latency=$latency
            min_interface=$iface
        fi
        if [ "$iface" == "$current_gateway" ]; then
            current_latency=$latency
        fi
    done

    trigger_latency=$(echo "$current_latency * (1-($ping_tolerance/100))" | bc -l)
    1>&2 echo "Trigger at $trigger_latency"
    if (( $(echo "$trigger_latency>$min_latency" | bc -l) )); then
        1>&2 echo "Trigger met"
        echo "$min_interface"
    else
        echo "$current_gateway"
    fi
}

function get_interface_ip (){
    iface=$1
    iface_ip=$(route -n | grep UG | grep $iface | awk '{ print $2 }' | head -1)
    echo "$iface_ip"
}

# compare current with new, if different assign metric = current_metric-1 otherwise return same metric
function set_new_gateway(){
    current_gateway=$1
    new_gateway=$2
    current_metric=$3
    1>&2 echo "Replacing old gateway $current_gateway with $new_gateway"
    if [ ! "$current_gateway" = "$new_gateway" ]; then
        1>&2 echo "Executing swap"
        current_metric=$((current_metric-1))
        gateway_ip=$(get_interface_ip $new_gateway)
        route add -net default gw $gateway_ip netmask 0.0.0.0 dev $new_gateway metric $current_metric
    else
        1>&2 echo "Execution skipped, same interface"
    fi

    echo "$current_metric"
}

function offset_gateway(){
    iface=$1
    offset=$2
    metric=$(get_metric $iface)
    echo "iface $iface offset $offset metric $metric"
    if [ -n "$metric" ]; then
        echo "Offseting metric at $iface"
        new_metric=$((metric+offset))
	echo "new_metric $new_metric"
        gateway_ip=$(get_interface_ip $iface)
	echo "route add -net default gw $gateway_ip netmask 0.0.0.0 dev $iface metric $new_metric"
        route add -net default gw $gateway_ip netmask 0.0.0.0 dev $iface metric $new_metric
        # delete previous metric
	echo "route del -net default gw $gateway_ip dev $iface metric $metric"
        route del -net default gw $gateway_ip dev $iface metric $metric
    else
        echo "Offsetting metric failed for $iface"
    fi
}
