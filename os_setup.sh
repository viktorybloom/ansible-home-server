#!/bin/bash

# Variables
os_image="./os-images/ubuntu-23.10-preinstalled-server-arm64+raspi.img.xz"
sd_card_device="/dev/sdc"
vault_file="./vault/secret.txt"
rpi_password=$(echo "$(cat $vault_file)" | mkpasswd -m sha-512 -s)
rpi_hostname="rpi4b"

# Make SD Card Bootable with os ISO
sudo dd bs=4M if="${os_image%.xz}" of=$sd_card_device conv=fsync status=progress

# Mount the boot partition
sudo mount $sd_card_device"1" /mnt   # Assuming boot partition is the first partition

# Enable SSH on Raspberry Pi
sudo touch /mnt/ssh

# Edit user-data to setup initial credentials
echo -e "#cloud-config\n\n\
hostname: $rpi_hostname\n\
manage_etc_hosts: true\n\
packages:\n\
  - avahi-daemon\n\
apt:\n\
  conf: |\n\
    Acquire {\n\
      Check-Date \"false\";\n\
    };\n\n\
users:\n\
  - name: $rpi_hostname\n\
    groups: users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo\n\
    shell: /bin/bash\n\
    lock_passwd: false\n\
    passwd: $rpi_password\n\n\
ssh_pwauth: true\n\
timezone: Australia/Brisbane\n\
runcmd:\n\
  - sed -i 's/^s*REGDOMAIN=S*/REGDOMAIN=AU/' /etc/default/crda || true\n\
  - localectl set-x11-keymap \"us\" pc105\n\
  - setupcon -k --force || true" | sudo tee /mnt/user-data