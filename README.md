# Home Server Initialization Playbook

### Set Ansible Vault

Execute `./vault_setup.sh` to start the initial vault setup:

When prompted, enter the sudo password for the target device. 
Insert the password into the 'ansible_password.yaml' file:
`ansible_become_password: sudo_password`
Use the SAME password when prompted to populate `ansible_secret.txt` 

### Initialise Ansible Playbook to target device
On a fresh Deb/Ubuntu server install, execute `./setup.sh` to start the playbook.
