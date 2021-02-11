#!/bin/sh

# This is the main look that we check with ping the best provider

source env.sh

gateway=$(get_current_gateway)
metric=$metrics_gateway_start

while true; do
    min_latency_interface=$(get_min_latency_interface)
    echo "Interface with min latency '$min_latency_interface'"
    metric=$(set_new_gateway $gateway $min_latency_interface $metric)
    gateway=$min_latency_interface
    echo "Setting with new metric $metric"
    echo "sleep $ping_sleep"
    sleep $ping_sleep
done
