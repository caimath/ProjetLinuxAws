#!/bin/bash

# Variables
CLIENT=$1
SAMBA_PWD=$2
DOCUMENT_ROOT="/var/www/$CLIENT"
SAMBA_CONF="/etc/samba/smb.conf"

# Créer l'utilisateur Samba s'il n'existe pas
if ! id "$CLIENT" &>/dev/null; then
    sudo useradd -M -s /sbin/nologin "$CLIENT"
    echo "Utilisateur UNIX $CLIENT créé."
fi

# Définir un mot de passe Samba (invite l'admin)
echo "Définir un mot de passe Samba pour l'utilisateur $CLIENT :"
echo -e "$SAMBA_PWD\n$SAMBA_PWD" | sudo smbpasswd -s -a "$CLIENT"

# Donner les droits sur le dossier
sudo mkdir -p "$DOCUMENT_ROOT"
sudo chown -R "$CLIENT":"$CLIENT" "$DOCUMENT_ROOT"
sudo chmod -R 770 "$DOCUMENT_ROOT"

# Ajouter le partage Samba si non existant
if ! grep -q "^\[$CLIENT\]$" "$SAMBA_CONF"; then
    sudo bash -c "cat >> $SAMBA_CONF <<EOF

[$CLIENT]
   path = $DOCUMENT_ROOT
   browseable = yes
   writable = yes
   valid users = $CLIENT
   create mask = 0770
   directory mask = 0770
EOF"
    echo "Partage ajouté pour $CLIENT"
else
    echo "Le partage $CLIENT existe déjà dans smb.conf"
fi

# Redémarrer Samba
sudo systemctl restart smb

echo "Partage Samba prêt pour $CLIENT dans $DOCUMENT_ROOT"
