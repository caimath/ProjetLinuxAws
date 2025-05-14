#!/bin/bash

# Chemin d'installation correct
INSTALL_DIR="/var/www/tungtungsahur.lan/phpMyAdmin"
TARBALL="phpMyAdmin-latest-all-languages.tar.gz"
DOWNLOAD_URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz"

echo "[*] Installation de wget et tar"
sudo dnf install -y wget tar > /dev/null 2>&1

# Créer le dossier racine s'il n'existe pas
sudo mkdir -p /var/www/tungtungsahur.lan

cd /var/www/tungtungsahur.lan

echo "[*] Téléchargement de phpMyAdmin"
sudo wget "$DOWNLOAD_URL" -O "$TARBALL" > /dev/null 2>&1

echo "[*] Création du dossier $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

echo "[*] Extraction de l'archive"
sudo tar -xvzf "$TARBALL" -C "$INSTALL_DIR" --strip-components=1 > /dev/null 2>&1

echo "[*] Suppression de l'archive $TARBALL"
sudo rm -f "$TARBALL"

echo "[*] Attribution des droits à apache"
sudo chown -R apache:apache "$INSTALL_DIR"

echo "[*] Redémarrage du service Apache"
sudo systemctl restart httpd

echo "phpMyAdmin installé dans $INSTALL_DIR et accessible via https://tungtungsahur.lan/phpMyAdmin"
