 echo Use target device sudo password?
# Create ansible password
ansible-vault create vault/ansible_password.yaml

# Create text file with password - added to .gitignore
file_path="vault/secret.txt"
read -s -p "Enter the SAME password: " password
echo "$password" > "$file_path"
echo "Password has been written to $file_path"
