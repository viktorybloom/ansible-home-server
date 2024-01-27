#!/bin/bash

# Variables
sd_card_device=$(ls /dev/sd* | grep -E "/dev/sd[b-z]" | head -n 1) # from b-z since sdcard reader itself takes sd'a'
vault_file="./vault/secret.txt"
target_password=$(echo "$(cat $vault_file)" | mkpasswd -m sha-512 -s)
target_name=$(grep "target_name:" "./vars.yaml" | awk -F"'" '{print $2}')
os_image=$(grep "os_image:" "./vars.yaml" | awk -F"'" '{print $2}')

# Make SD Card Bootable with os ISO
sudo dd bs=4M if="${os_image%.xz}" of=${sd_card_device} conv=fsync status=progress

# Mount the boot partition
sudo mount ${sd_card_device}"1" /mnt   # Assuming boot partition is the first partition

# Enable SSH on Raspberry Pi
sudo touch /mnt/ssh

# Edit netplan to enable eth0 wired connection on RPI with ubuntu server iso. 
echo -e "
    version: 2
    ethernets:
      eth0:
        dhcp4: true
        dhcp4-overrides:
          use-dns: false
        nameservers:
          addresses: [127.0.0.1, 9.9.9.9] # Required for docker pihole dns service
        optional: true" | sudo tee /mnt/netplan
	
# Edit user-data to setup initial credentials
echo -e "#cloud-config\n\n\
hostname: ${target_name}n\
manage_etc_hosts: true\n\
packages:\n\
  - avahi-daemon\n\
apt:\n\
  conf: |\n\
    Acquire {\n\
      Check-Date \"false\";\n\
    };\n\n\
users:\n\
  - name: ${target_name}\n\
    groups: users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo\n\
    shell: /bin/bash\n\
    lock_passwd: false\n\
    passwd: ${target_password}\n\n\
ssh_pwauth: true\n\
timezone: Australia/Brisbane\n\
runcmd:\n\
  - sed -i 's/^s*REGDOMAIN=S*/REGDOMAIN=AU/' /etc/default/crda || true\n\
  - localectl set-x11-keymap \"us\" pc105\n\
  - setupcon -k --force || true" | sudo tee /mnt/user-data