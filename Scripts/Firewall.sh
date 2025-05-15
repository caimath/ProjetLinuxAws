#!/bin/bash

# Démarrer le service firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Script pour configurer le pare-feu avec firewalld
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=30000-30100/tcp
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --permanent --add-port=19999/tcp
sudo firewall-cmd --reload

