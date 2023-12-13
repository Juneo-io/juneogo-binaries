#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Create a new user and add it to the sudo group
if ! id -u juneogo > /dev/null 2>&1; then
  adduser --gecos "" juneogo
  usermod -aG sudo juneogo
fi

# Ask if the user wants to add an SSH key
read -p "Do you want to add an SSH key for user juneogo? (y/n) " add_ssh_key
if [ "$add_ssh_key" = "y" ]; then
  mkdir -p /home/juneogo/.ssh
  echo "Please enter the SSH public key (beginning with ssh-rsa or ssh-ed25519):"
  read user_ssh_key
  echo "$user_ssh_key" >> /home/juneogo/.ssh/authorized_keys
  chmod 700 /home/juneogo/.ssh
  chmod 644 /home/juneogo/.ssh/authorized_keys
  chown -R juneogo:juneogo /home/juneogo/.ssh
  echo "SSH key added successfully."
fi

# Update sshd_config to disable root login
sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config

# Update PasswordAuthentication to no
echo "Changing PasswordAuthentication to no"
sudo sed -i 's/#\?PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl reload sshd

# Install fail2ban & systemd (for timedatectl)
sudo apt update
sudo apt install -y fail2ban systemd

# start & enable fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Prompt user to reboot the machine
read -p "Do you want to reboot the machine now? (y/n) " reboot_choice
if [ "$reboot_choice" = "y" ]; then
  echo "Rebooting the machine..."
  sudo reboot
else
  echo "Reboot skipped. Remember to reboot the machine manually later."
fi

# Warning message about logging out and reconnecting
echo "WARNING: Please log out and reconnect using the 'juneogo' user with the SSH key."
