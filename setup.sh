# variables
target_ip=$(grep "target_ip:" "./vars.yaml" | awk -F"'" '{print $2}')
target_name=$(grep "target_name:" "./vars.yaml" | awk -F"'" '{print $2}')

ansible-playbook \
    -i "${target_ip}," \
    -u "${target_name}" \
    -k ./playbook/setup_playbook.yaml \
    -e "target_ip=${target_ip}" \
    -e '@vault/ansible_password.yaml' \
    --vault-password-file=vault/secret.txt

