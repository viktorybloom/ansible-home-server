#!/bin/bash

# Variables
vault_file="./vault/secret.txt"
target_password=$(echo "$(cat $vault_file)" | mkpasswd -m sha-512 -s)
target_name=$(grep "target_name:" "./vars.yaml" | awk -F"'" '{print $2}')
os_image=$(grep "os_image:" "./vars.yaml" | awk -F"'" '{print $2}')

lsblk
read -p "Please choose a drive (e.g., sdb, sdc, etc.): " selected_drive
if [[ ! $(ls /dev/sd* | grep -E "/dev/sd[a-z]") =~ /dev/$selected_drive ]]; then
  echo "Invalid drive selection. Exiting..."
  exit 1
fi
sd_card_device="/dev/$selected_drive"  
echo "Selected drive: $sd_card_device"

# Unmount any existing partitions on the drive
sudo umount ${sd_card_device}* 2>/dev/null || true

# Check for and terminate processes using the drive
sudo fuser -k ${sd_card_device}

# Wipe the entire drive
sudo wipefs --all ${sd_card_device}

# Format the selected drive as FAT32
sudo mkfs.fat -F32 ${sd_card_device}

# Extract .xz iso and Make SD Card Bootable with OS ISO
sudo xz -d < ${os_image} | sudo dd bs=4M of=${sd_card_device} conv=fsync status=progress

# Create mounting directory if it doesn't exist
sudo mkdir -p /mnt/${target_name}

# Mount the boot partition
sudo mount ${sd_card_device}1 /mnt/${target_name}

# Enable SSH on Raspberry Pi
sudo touch /mnt/${target_name}/ssh

# Edit netplan to enable eth0 wired connection on RPI with Ubuntu Server ISO.
echo -e "
    network:
    version: 2
    ethernets:
      eth0:
        dhcp4: true
        dhcp4-overrides:
          use-dns: false
        nameservers:
          addresses: [127.0.0.1, 9.9.9.9] # Required for docker pihole dns service
        optional: true
        routes:
          - to: 10.9.8.0/24
            via: 192.168.1.100" | sudo tee /mnt/${target_name}/netplan
	
# Edit user-data to set up initial credentials
echo -e "#cloud-config\n\n\
hostname: ${target_name}\n\
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
  - setupcon -k --force || true" | sudo tee /mnt/${target_name}/user-data

