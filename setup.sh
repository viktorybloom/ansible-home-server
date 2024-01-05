ansible-playbook -i "192.168.1.101," -u rpi4b -k ./playbook/setup_playbook.yaml \
  -e '@vault/ansible_password.yaml' --vault-password-file=vault/ansible_secret.txt
