#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <nom_utilisateur> <nom_domaine>"
    exit 1
fi

CLIENT=$1
DOMAIN=$2
DOCUMENT_ROOT="/var/www/$CLIENT"

echo "[*] Création de l'utilisateur $CLIENT pour le domaine $DOMAIN"
sudo useradd -m -s /sbin/nologin -G sftpusers $CLIENT

echo "[*] Création de l'arborescence de dossier"
sudo mkdir -p $DOCUMENT_ROOT/home/$CLIENT
sudo chown root:root $DOCUMENT_ROOT
sudo chmod 755 $DOCUMENT_ROOT
sudo chown $CLIENT:$CLIENT $DOCUMENT_ROOT/home/$CLIENT

echo "[*] Définir le mot de passe pour $CLIENT"
sudo passwd $CLIENT

echo "[*] Configuration SFTP prête pour $CLIENT dans $DOCUMENT_ROOT"
