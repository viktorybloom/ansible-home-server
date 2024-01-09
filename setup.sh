ansible-playbook -i "192.168.1.100," -u rpi4b -k ./playbook/setup_playbook.yaml \
  -e '@vault/ansible_password.yaml' --vault-password-file=vault/secret.txt
