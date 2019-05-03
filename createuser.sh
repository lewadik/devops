#!/bin/sh

/usr/sbin/groupadd -g 1001 ansible
/usr/sbin/useradd -u 1001 -g 1001 -c "Ansible Automation Account" -s /bin/bash -m -d /home/ansible ansible
echo "ansible:p23lev43" | /sbin/chpasswd
mkdir -p /home/ansible/.ssh

# setup ssh authorization keys for Ansible access 
echo "setting up ssh authorization keys..."
cat << EOT > /home/ansible/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEthNSEZ+o17SYA77h57C0zB7XWzGBjmIW5dE88eEsYkK1GEJ3XnkbjGNe0w4qWp9sIavmMOunmZcNPF9nxG0PfDKwejbNLvWOVccWb14sd502OYQFrLfCMVkhJILrx3ZMTp0Hdoyh8PfGbp1iDW5kIXI4FTzbbHbobeTRz2lecnk/FlJNylH9o+k5QEc1cltnLdel4L93WNu1zdrXgy+RI4yYXGfm9rBtdb137mwLpXTbH6Ax/KfP7Db2pY1VWhJN90oHouG+2GggAK/aFiw7PjkWwE+eJdLmfL808XxOAkM+hEQseVRau0xN3MzKifKARaDS+gZ6TFlJ49YPKAy7 ansible@mainhost
EOT

chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
# setup sudo access for Ansible
if [ ! -s /etc/sudoers.d/ansible ]
then
echo "User lnxcfg sudoers does not exist.  Will Add..."
cat << EOT > /etc/sudoers.d/ansible
User_Alias ANSIBLE_AUTOMATION = %ansible
ANSIBLE_AUTOMATION ALL=(ALL)      NOPASSWD: ALL
EOT

chmod 400 /etc/sudoers.d/ansible
fi
# disable login for lnxcfg except through 
# ssh keys
cat << EOT >> /etc/ssh/sshd_config
Match User ansible
        PasswordAuthentication no
        AuthenticationMethods publickey
EOT

# restart sshd
systemctl restart sshd
# end of script