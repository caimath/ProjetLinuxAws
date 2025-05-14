#!/bin/bash

# Chemin d'installation
INSTALL_DIR="/var/www/html/phpMyAdmin"
TARBALL="phpMyAdmin-latest-all-languages.tar.gz"
DOWNLOAD_URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz"

# Installation des dépendances si besoin
echo "[*] Installation de wget et tar"
sudo dnf install -y wget tar > /dev/null 2>&1

# Aller dans le dossier /var/www/html
cd /var/www/html

# Télécharger phpMyAdmin
echo "[*] Téléchargement de phpMyAdmin"
sudo wget "$DOWNLOAD_URL" -O "$TARBALL" > /dev/null 2>&1

# Créer le dossier de destination
echo "[*] Création du dossier $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

# Extraire le contenu
echo "[*] Extraction de l'archive"
sudo tar -xvzf "$TARBALL" -C "$INSTALL_DIR" --strip-components=1 > /dev/null 2>&1

# Supprimer l'archive
echo "[*] Suppression de l'archive $TARBALL"
sudo rm -f "$TARBALL"

# Redémarrer Apache
echo "[*] Redémarrage du service Apache"
sudo systemctl restart httpd

echo "phpMyAdmin installé dans $INSTALL_DIR"
