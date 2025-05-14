#!/bin/bash

# Variables
CLIENT=$1
DOMAIN=$2
DOCUMENT_ROOT="/var/www/$CLIENT"
FTP_USER=$CLIENT
FTP_PASSWORD=$3
DB_NAME="$CLIENT.db"
DB_USER="$CLIENT"
DB_PASS=$4

# Créer un utilisateur pour le client
sudo useradd -m -s /bin/bash $CLIENT

# Créer un dossier web
sudo mkdir -p $DOCUMENT_ROOT
sudo chown -R $CLIENT:$CLIENT $DOCUMENT_ROOT
sudo chmod -R 755 $DOCUMENT_ROOT

# Configuration FTP
# Définir le mot de passe système (FTP)
echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd

# Ajouter à la liste FTP si ce n'est pas déjà fait
grep -q "^$FTP_USER$" /etc/vsftpd/user_list || echo "$FTP_USER" | sudo tee -a /etc/vsftpd/user_list > /dev/null

# Configuration FTP
sudo usermod -d $DOCUMENT_ROOT $FTP_USER
sudo chown $FTP_USER:$FTP_USER $DOCUMENT_ROOT

# Configuration MySQL/MariaDB
# Créer une base de données MySQL/MariaDB
# Créer la base de données et l'utilisateur
sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Afficher les informations de configuration
echo "Utilisateur $CLIENT créé avec succès."
echo "Domaine web : $DOMAIN"
echo "Dossier web : $DOCUMENT_ROOT"
echo "Utilisateur FTP : $FTP_USER"
echo "Mot de passe FTP : $FTP_PASSWORD"
echo "Base de données : $DB_NAME"
echo "Utilisateur DB : $DB_USER"
echo "Mot de passe DB : $DB_PASS"
