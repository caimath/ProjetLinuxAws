#!/bin/bash

# Variables
NFS_SHARE_DIR="/srv/nfs/share"
EXPORTS_FILE="/etc/exports"
SAMBA_CONF="/etc/samba/smb.conf"

# Création du répertoire pour le partage NFS
echo "Création du répertoire de partage NFS..."
sudo mkdir -p "$NFS_SHARE_DIR"
sudo chown -R nobody:nobody "$NFS_SHARE_DIR"
sudo chmod -R 777 "$NFS_SHARE_DIR"

# Activation et démarrage des services NFS
echo "Activation et démarrage des services NFS..."
sudo systemctl enable rpcbind --now
sudo systemctl enable nfs-server --now

# Configuration de l'export NFS
echo "Configuration de l'export NFS..."
if ! grep -q "$NFS_SHARE_DIR" "$EXPORTS_FILE"; then
    echo "$NFS_SHARE_DIR *(ro,sync,no_subtree_check)" | sudo tee -a "$EXPORTS_FILE" > /dev/null
fi

sudo exportfs -rav

# Installation de Samba
echo "Installation de Samba..."
sudo dnf install -y samba samba-common

# Configuration de Samba
echo "Configuration de Samba..."
if ! grep -q "map to guest = Bad User" "$SAMBA_CONF"; then
    sudo sed -i '/\[global\]/a map to guest = Bad User' "$SAMBA_CONF"
fi

if ! grep -q "\[share\]" "$SAMBA_CONF"; then
    tee -a "$SAMBA_CONF" > /dev/null <<EOF

[share]
     path = $NFS_SHARE_DIR
     browseable = yes
     writable = no
     read only = yes
     guest ok = yes
     guest only = yes
EOF
fi

# Activation et démarrage des services Samba
echo "Activation et démarrage des services Samba..."
sudo systemctl enable smb --now
sudo systemctl enable nmb --now

echo "Configuration terminée avec succès."
