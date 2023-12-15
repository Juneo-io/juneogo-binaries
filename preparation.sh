#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Create a new user and add to sudo group
if ! id -u juneogo > /dev/null 2>&1; then
  adduser --gecos "" juneogo
  usermod -aG sudo juneogo
fi

# SSH Key Configuration
read -p "Do you want to add an SSH key for user juneogo? (y/n) " add_ssh_key
if [ "$add_ssh_key" = "y" ]; then
  mkdir -p /home/juneogo/.ssh
  echo "Please enter the SSH public key:"
  read user_ssh_key
  echo "$user_ssh_key" >> /home/juneogo/.ssh/authorized_keys
  chmod 700 /home/juneogo/.ssh
  chmod 644 /home/juneogo/.ssh/authorized_keys
  chown -R juneogo:juneogo /home/juneogo/.ssh
  echo "SSH key added successfully."
fi

# Warning before disabling root login or password authentication
echo "CAUTION - make sure you understand the implications of disabling root login and password authentication to avoid unexpected errors and security issues."
read -p "Do you wish to continue? (y/n) " proceed
if [ "$proceed" != "y" ]; then
  echo "Operation canceled. Exiting script."
  exit
fi

# SSH Configuration
read -p "Do you want to disable root login? (default is no) (y/n) " disable_root_login
read -p "Do you want to disable password authentication? (default is no) (y/n) " update_pass_auth
config_changed=false

if [ "$disable_root_login" = "y" ]; then
  sed -i '/^PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config
  echo "Root login disabled."
  config_changed=true
fi

if [ "$update_pass_auth" = "y" ]; then
  sed -i 's/#\?PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  echo "PasswordAuthentication set to no."
  config_changed=true
fi

if [ "$config_changed" = true ]; then
  systemctl reload sshd
  echo "SSH service reloaded to apply changes."
fi

# Package Installation
sudo apt update && sudo apt install -y fail2ban systemd

# Fail2ban Configuration
sudo systemctl enable --now fail2ban

# System Reboot Prompt
read -p "Do you want to reboot the machine now? (y/n) " reboot_choice
if [ "$reboot_choice" = "y" ]; then
  echo "Rebooting the machine..."
  sudo reboot
else
  echo "Reboot skipped. Remember to reboot the machine manually later."
fi

echo "WARNING: Please log out and reconnect using the 'juneogo' user with the SSH key."
