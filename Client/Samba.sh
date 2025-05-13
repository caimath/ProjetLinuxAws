#!/bin/bash

# Variables
CLIENT=$1
DOCUMENT_ROOT="/var/www/$CLIENT"
SAMBA_CONF="/etc/samba/smb.conf"

# Créer un partage Samba pour le client
sudo bash -c "cat >> $SAMBA_CONF <<EOF
[$CLIENT]
   path = $DOCUMENT_ROOT
   browseable = yes
   writable = yes
   valid users = $CLIENT
EOF"

# Redémarrer Samba
sudo systemctl restart smb
echo "Partage Samba configuré pour $CLIENT avec accès au dossier $DOCUMENT_ROOT."
