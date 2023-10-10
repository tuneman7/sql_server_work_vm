#!/bin/bash

export setup_good=1

sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager cloud-image-utils libguestfs-tools

if [ $? -ne 0 ]; then
    echo "Not all dependencies installed correctly. ..."
cat ./scr/msgs/deps_fail.txt
echo ""
setup_good=0
export setup_good=$setup_good
else
    echo "All Dependencies Set Up"

fi



