
#!/bin/bash
#get all variables not declared within file
#check dependencies
source ./env.sh

this_dir=$(pwd)

mkdir temp
cd temp

file_path=$(pwd)"/ubuntu-22.04-minimal-cloudimg-amd64.img"

if [ ! -e "$file_path" ]; then
  wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
fi



cat << EOF > user-data.txt
#cloud-config
password: password
ssh_pwauth: True
chpasswd:
  expire: False
EOF

cat << EOF > meta-data
instance-id: SQL_WORK_HOST
local-hostname: SQL_WORK_HOST

EOF

touch vendor-data

#python -m http.server --directory . & >/dev/null

filename=$(pwd)/$VM_Name-disk.qcow2

# Check if the VM is running and shut it down
if virsh list --all | grep -q "$VM_Name"; then
    virsh shutdown "$VM_Name"
fi

# Undefine (delete) the VM
virsh undefine "$VM_Name"


finished=false
while ! $finished; do
    dl=$(virsh list --all | grep -q "$VM_Name")
    if [[ -z $dl ]]; then
        finished=true
        echo "*********************************"
        echo "  Machine Down: $VM_Name "
        echo "*********************************"
        sleep 1
    else
        finished=false
    fi
done
sleep 1

rm -rf $filename

cloud-localds user-data.img user-data.txt
qemu-img create -b ubuntu-22.04-minimal-cloudimg-amd64.img -F qcow2 -f qcow2 $filename 60G

echo "***************************"
echo "Spinning up local box"
echo "***************************"

my_script="$(pwd)/my_script.sh"

chmod 777 $my_script 

virt-install --name $VM_Name \
  --virt-type kvm --memory 6144 --vcpus 10 \
  --boot hd,menu=off \
  --disk path=$filename,device=disk \
  --disk path=user-data.img,format=raw \
  --init $my_script \
  --graphics none \
  --noautoconsole \
  --check path_in_use=off \
  --os-variant ubuntu22.04 

cd $this_dir




finished=false
while ! $finished; do
    ip_address=$(virsh domifaddr $VM_Name | awk '/ipv4 / {print $4}')
    if [ -n $ip_address ]; then
        ip_address="${ip_address%/24}"  # Remove the /24 subnet part
        if [ ${#ip_address} -ge 7 ]; then
            echo "IP address of $VM_Name: $ip_address"
            break  # Exit the loop if IP address is found        
            echo "*********************************"
            echo "IP address of $VM_Name: $ip_address"
            echo "*********************************"
            finished=true
        fi
    else
        sleep 1
        finished=false
    fi
done

sleep 5
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null  ubuntu@$ip_address
echo "ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null  ubuntu@$ip_address">connect.sh

#virsh console SQL_WORK_VM