#!/bin/bash
# Main script

echo "Executing $0"


source env.sh

echo "Waiting $loop_start_delay seconds to start loop"
sleep $loop_start_delay
source dhcp_interfaces.sh
source set_routing.sh
source latency_loop.sh

