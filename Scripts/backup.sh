#!/bin/bash

# Script de sauvegarde automatisée
# Sauvegarde les dossiers /etc, /var/www, /home et les bases de données MySQL

BACKUP_DIR="/backup/$(date +%Y-%m-%d_%H-%M-%S)"
MYSQL_USER="root"

echo -n "Entrez le mot de passe MySQL : "
read -s MYSQL_PASSWORD
echo

echo "[INFO] Création du dossier de sauvegarde : $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

echo "[INFO] Sauvegarde des fichiers de configuration système (/etc)"
tar czf "$BACKUP_DIR/etc.tar.gz" /etc

echo "[INFO] Sauvegarde des fichiers web (/var/www)"
tar czf "$BACKUP_DIR/www.tar.gz" /var/www

echo "[INFO] Sauvegarde des répertoires utilisateurs (/home)"
tar czf "$BACKUP_DIR/home.tar.gz" /home

echo "[INFO] Sauvegarde des bases de données MySQL"
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD --all-databases > "$BACKUP_DIR/all_databases.sql"

sudo 0 3 * * * /home/ec2-user/Scripts/backup.sh >> /var/log/backup_full.log 2>&1

echo "[INFO] Sauvegarde terminée avec succès."
