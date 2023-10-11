#!/bin/bash

export setup_good=1

sudo apt install -y qemu qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager cloud-image-utils libguestfs-tools cpu-checker qemu-system-x86_64

systemctl start libvirtd

if [ $? -ne 0 ]; then
    echo "Not all dependencies installed correctly. ..."
cat ./scr/msgs/deps_fail.txt
echo ""
setup_good=0
export setup_good=$setup_good
else

    output=$(kvm-ok)

    # Run kvm-ok and check its output
    output=$(kvm-ok)

    if [[ $output == *"KVM acceleration can be used"* ]]; then
        echo "KVM acceleration is supported."
    else
        echo "KVM acceleration is not supported."
        setup_good=0
        export setup_good=$setup_good
    fi

fi



