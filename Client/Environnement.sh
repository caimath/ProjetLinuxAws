#!/bin/bash

# Variables
CLIENT=$1
DOMAIN=$2
DOCUMENT_ROOT="/var/www/$CLIENT"
FTP_USER=$CLIENT
DB_NAME="$CLIENT_db"
DB_USER="$CLIENT_user"
DB_PASS=$(openssl rand -base64 12)

# Créer un utilisateur pour le client
sudo useradd -m -s /bin/bash $CLIENT

# Créer un dossier web
sudo mkdir -p $DOCUMENT_ROOT
sudo chown -R $CLIENT:$CLIENT $DOCUMENT_ROOT
sudo chmod -R 755 $DOCUMENT_ROOT

# Configuration FTP
sudo usermod -d $DOCUMENT_ROOT $FTP_USER
sudo chown $FTP_USER:$FTP_USER $DOCUMENT_ROOT
echo -e "$DB_PASS\n$DB_PASS" | sudo passwd $FTP_USER

# Créer une base de données MySQL/MariaDB
sudo mysql -e "CREATE DATABASE $DB_NAME;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Utilisateur $CLIENT créé avec succès."
echo "Base de données : $DB_NAME"
echo "Utilisateur DB : $DB_USER"
echo "Mot de passe DB : $DB_PASS"
