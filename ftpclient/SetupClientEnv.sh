#!/bin/bash
set -euo pipefail

# Variables

CLIENT=$1
DOMAIN=$2
DOCUMENT_ROOT="/var/www/$CLIENT"
DB_NAME="${CLIENT}_db"
DB_USER="${CLIENT}_user"

# Demande un mot de passe à l'utilisateur
read -s -p "Mot de passe FTP pour $CLIENT : " FTP_PASSWORD
echo
read -s -p "Confirmez le mot de passe : " FTP_PASSWORD_CONFIRM
echo

if [ "$FTP_PASSWORD" != "$FTP_PASSWORD_CONFIRM" ]; then
    echo "Les mots de passe ne correspondent pas. Abandon."
    exit 1
fi

# Crée l'utilisateur système
sudo useradd -m -s /bin/bash "$CLIENT"

# Crée le dossier web
sudo mkdir -p "$DOCUMENT_ROOT"
sudo chown -R "$CLIENT:$CLIENT" "$DOCUMENT_ROOT"
sudo chmod -R 755 "$DOCUMENT_ROOT"

# Définir le mot de passe système (FTP)
echo "$CLIENT:$FTP_PASSWORD" | sudo chpasswd

# Ajouter à la liste FTP si ce n'est pas déjà fait
grep -q "^$CLIENT$" /etc/vsftpd/user_list || echo "$CLIENT" | sudo tee -a /etc/vsftpd/user_list > /dev/null

# Redéfinir son répertoire FTP
sudo usermod -d "$DOCUMENT_ROOT" "$CLIENT"

# Créer la base de données
sudo mysql -e "CREATE DATABASE $DB_NAME;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$FTP_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "✅ Utilisateur $CLIENT configuré avec succès."
echo "🌐 Domaine web : $DOMAIN"
echo "📁 Dossier web : $DOCUMENT_ROOT"
echo "🗄️ Base de données : $DB_NAME"
echo "👤 Utilisateur DB : $DB_USER"
echo "🔐 Mot de passe (FTP et DB) : $FTP_PASSWORD"
