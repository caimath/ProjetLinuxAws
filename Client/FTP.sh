#!/bin/bash

# Variables
CLIENT=$1
DOCUMENT_ROOT="/var/www/$CLIENT"

# Installer vsftpd si nécessaire
sudo dnf install -y vsftpd

# Ajouter un utilisateur FTP
echo "$CLIENT" | sudo tee -a /etc/vsftpd/user_list
sudo usermod -d $DOCUMENT_ROOT $CLIENT

# Configurer les permissions d'accès
sudo chmod 755 $DOCUMENT_ROOT
sudo chown $CLIENT:$CLIENT $DOCUMENT_ROOT

# Redémarrer vsftpd
sudo systemctl restart vsftpd
echo "FTP configuré pour $CLIENT avec accès au dossier $DOCUMENT_ROOT."

