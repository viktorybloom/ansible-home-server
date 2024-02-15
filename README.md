# (RPi 4b) Home Server Initialization Playbook

### Set target environment variables
Edit `vars.yaml` to suit your target environment. 


### Set Ansible Vault

Execute `./vault_setup.sh` to start the initial vault setup:

When prompted, enter the sudo password for the target device. 
Insert the password into the 'ansible_password.yaml' file:
`ansible_become_password: sudo_password`
Use the SAME password when prompted to populate `ansible_secret.txt` 

### Setup OS
Download latest ubuntu server iso into `/os-images` from (https://ubuntu.com/download/raspberry-pi). 
Execute `./os_setup.sh` to start the os load and configuration. 
Once done load the sd card into the RPi to continue setup. 

### Initialise Ansible Playbook to target device
Once os is loaded execute `./setup.sh` to start the playbook.

### Package requirements
- whois
- xz-utils
- util-linux
- dosfstools
