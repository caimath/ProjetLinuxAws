#!/bin/bash

# Variables
NFS_SHARE_DIR="/srv/nfs/share"
EXPORTS_FILE="/etc/exports"
SAMBA_CONF="/etc/samba/smb.conf"

# Creating the directory for NFS share
echo "Creating the NFS share directory..."
sudo mkdir -p "$NFS_SHARE_DIR"
sudo chown -R nobody:nobody "$NFS_SHARE_DIR"
sudo chmod -R 777 "$NFS_SHARE_DIR"

# Enabling and starting NFS services
echo "Enabling and starting NFS services..."
sudo systemctl enable rpcbind --now
sudo systemctl enable nfs-server --now

# Configuring NFS export
echo "Configuring NFS export..."
if ! grep -q "$NFS_SHARE_DIR" "$EXPORTS_FILE"; then
    echo "$NFS_SHARE_DIR *(ro,sync,no_subtree_check)" | sudo tee -a "$EXPORTS_FILE" > /dev/null
fi

sudo exportfs -rav

# Installing Samba
echo "Installing Samba..."
sudo dnf install -y samba samba-common

# Configuring Samba
echo "Configuring Samba..."
if ! grep -q "map to guest = Bad User" "$SAMBA_CONF"; then
    sudo sed -i '/\[global\]/a map to guest = Bad User' "$SAMBA_CONF"
fi

if ! grep -q "\[share\]" "$SAMBA_CONF"; then
    o tee -a "$SAMBA_CONF" > /dev/null <<EOF

[share]
     path = $NFS_SHARE_DIR
     browseable = yes
     writable = no
     read only = yes
     guest ok = yes
     guest only = yes
EOF
fi

# Enabling and starting Samba services
echo "Enabling and starting Samba services..."
sudo systemctl enable smb --now
sudo systemctl enable nmb --now

echo "Configuration completed successfully."
