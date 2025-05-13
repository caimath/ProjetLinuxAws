#!/bin/bash

# === Script Environnement utilisateur (avec SSL Apache) ===

# Vérifications
if [ $# -ne 3 ]; then
  echo "Usage: $0 <nom_client> <domaine_complet> <mot_de_passe_ftp>"
  exit 1
fi

CLIENT=$1
DOMAIN=$2
FTP_PASSWORD=$3
DOCUMENT_ROOT="/var/www/$CLIENT"
FTP_USER=$CLIENT
DB_NAME="${CLIENT}_db"
DB_USER="${CLIENT}_user"
DB_PASS=$(openssl rand -base64 12)

# === Création de l'utilisateur système ===
sudo useradd -m -s /bin/bash "$CLIENT"

# === Création du dossier web ===
sudo mkdir -p "$DOCUMENT_ROOT"
sudo chown -R "$CLIENT:$CLIENT" "$DOCUMENT_ROOT"
sudo chmod -R 755 "$DOCUMENT_ROOT"

# === Définir le mot de passe système ===
echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd

# === Ajout à la liste FTP si nécessaire ===
grep -q "^$FTP_USER$" /etc/vsftpd/user_list || echo "$FTP_USER" | sudo tee -a /etc/vsftpd/user_list > /dev/null

# === Configuration FTP ===
sudo usermod -d "$DOCUMENT_ROOT" "$FTP_USER"
sudo chown "$FTP_USER:$FTP_USER" "$DOCUMENT_ROOT"

# === Création du fichier index.html si inexistant ===
INDEX_FILE="$DOCUMENT_ROOT/index.html"
if [ ! -f "$INDEX_FILE" ]; then
  echo "<h1>Bienvenue sur votre domaine $CLIENT : $DOMAIN</h1>" | sudo tee "$INDEX_FILE" > /dev/null
  sudo chown "$CLIENT:$CLIENT" "$INDEX_FILE"
fi

# === Configuration de la base de données ===
sudo mysql -e "CREATE DATABASE $DB_NAME;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# === Appel au script de génération SSL pour Apache ===
if [ -x "./SetupApacheSSL.sh" ]; then
  sudo ./SetupApacheSSL.sh "$DOMAIN"
else
  echo "⚠️  SetupApacheSSL.sh est introuvable ou non exécutable dans le répertoire courant."
fi

# === Résumé ===
echo "✅ Utilisateur $CLIENT configuré."
echo "🌐 Domaine : $DOMAIN"
echo "📁 Dossier web : $DOCUMENT_ROOT"
echo "🔐 Utilisateur FTP : $FTP_USER"
echo "🔑 Mot de passe FTP : $FTP_PASSWORD"
echo "🛢️  Base de données : $DB_NAME"
echo "👤 Utilisateur DB : $DB_USER"
echo "🔐 Mot de passe DB : $DB_PASS"
