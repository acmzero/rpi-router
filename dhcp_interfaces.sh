# Bring configured isp interfaces up and assign IP
# only to be done once

source env.sh

if [ "$dhcp_isp_interfaces" == "yes" ]; then
	echo "Executing dhcp to isp interfaces"
	for iface in $isp_interfaces; do
	    echo "Setting up dhcp $iface"
	    dhclient -r $iface
	done
else
	echo "Skipping dhcp to isp interfaces"
fi

echo "Setting $server_ip ip to $listen_interface"
ip addr flush $listen_interface
ip addr add $server_ip/24 dev $listen_interface
ip link set dev $listen_interface up
