#!/bin/bash

# Variables
ubuntu_server_image="/path/to/ubuntu-server-image.img"
sd_card_device="/dev/sdX"
local_machine_ip="localhost"
rpi_ip="<your-rpi-ip>"
static_ip="<your-static-ip>"
gateway_ip="<your-gateway-ip>"
dns_ip="<your-dns-ip>"

# Make SD Card Bootable with Ubuntu Server ISO
sudo dd bs=4M if=$ubuntu_server_image of=$sd_card_device conv=fsync status=progress

# Edit Netplan to Connect to Router via Eth0
sudo mount $sd_card_device"1" /mnt   # Assuming boot partition is the first partition
echo -e "version: 2\nethernets:\n  eth0:\n    addresses: [$static_ip/24]\n    gateway4: $gateway_ip\n    nameservers:\n      addresses: [$dns_ip]" | sudo tee /mnt/network-config
sudo umount /mnt

# Script to Allow SSH Fingerprint with Local Machine and IP
echo -e "#!/bin/bash\n\n# Add local machine SSH fingerprint\nssh-keyscan -H $local_machine_ip >> ~/.ssh/known_hosts\n\n# Add Raspberry Pi's IP address\nssh-keyscan -H $rpi_ip >> ~/.ssh/known_hosts" > setup_ssh.sh
chmod +x setup_ssh.sh
./setup_ssh.sh

echo "Setup completed successfully."

