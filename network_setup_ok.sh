#!/bin/bash

export network_setup=1

file_path="/etc/sysctl.d/bridge.conf"

if [ ! -e "$file_path" ]; then
  network_setup=0
fi

if [ "$network_setup" -ne 1 ]; then
    echo "*************************************"
    echo  "We've got to setup the network:"
    echo "*************************************"

    echo "net.bridge.bridge-nf-call-ip6tables=0">$file_path
    echo "net.bridge.bridge-nf-call-iptables=0">>$file_path
    echo "net.bridge.bridge-nf-call-arptables=0">>$file_path
  
fi

cat $file_path


file_path1="/etc/udev/rules.d/99-bridge.rules"

echo file_path1=$file_path1

if [ ! -e "$file_path1" ]; then
  network_setup=0
fi

if [ "$network_setup" -ne 1 ]; then
    echo "*************************************"
    echo  "We've got to setup the network:"
    echo "*************************************"

    echo "ACTION==\"add\", SUBSYSTEM==\"module\", KERNEL==\"br_netfilter\", RUN+=\"/sbin/sysctl -p /etc/sysctl.d/bridge.conf\"">$file_path1


fi

cat $file_path1




# Get a list of local Ethernet adapter names
adapter_names=($(ip -o link show | awk -F': ' '{print $2}'))

# Loop through the adapter names and check their connection status
for adapter in "${adapter_names[@]}"; do
    if [[ "$adapter" == docker* ]]; then
        continue
    fi

    state=$(ip link show dev "$adapter" 2>/dev/null | awk '/state/ {print $9}')
    
    if [[ "$state" == "UP" ]]; then
        mac_address=$(ip link show dev "$adapter" | awk '/link\/ether/ {print $2}')
        echo "Ethernet adapter $adapter is connected with MAC address: $mac_address"
    fi
done
