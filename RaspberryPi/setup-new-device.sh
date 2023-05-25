#!/bin/bash

timedatectl set-timezone Asia/Jerusalem
apt update -y && apt upgrade -y


#force type password on Sudo 
sudo visudo /etc/sudoers.d/010_pi-nopasswd

#Disable IPv6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# log to ram
echo "deb http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
sudo apt update
sudo apt install log2ram

du -sh  /var/hdd.log/ # check size
nano /etc/log2ram.conf # set SIZE to more than that

sudo reboot now
systemctl status log2ram

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker shaked


