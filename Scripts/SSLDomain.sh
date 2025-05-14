#!/bin/bash

# Variables
DOMAIN="tungtungsahur.lan"
DOC_ROOT="/var/www/$DOMAIN"
SSL_DIR="/etc/ssl/$DOMAIN"
CONF_FILE="/etc/httpd/conf.d/$DOMAIN.conf"

# Préparation
echo "[INFO] Création du dossier de certificat : $SSL_DIR"
mkdir -p "$SSL_DIR"

echo "[INFO] Génération du certificat auto-signé pour $DOMAIN"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$SSL_DIR/$DOMAIN.key" \
  -out "$SSL_DIR/$DOMAIN.crt" \
  -subj "/C=BE/ST=Hainaut/L=Mons/O=TungSahurCorp/OU=Web/CN=$DOMAIN"

# Création du dossier racine si nécessaire
mkdir -p "$DOC_ROOT"
echo "<h1>Bienvenue sur le domaine $DOMAIN </h1>" > "$DOC_ROOT/index.html"

# Création du fichier de configuration Apache
echo "[INFO] Création du fichier de configuration Apache"
cat <<EOF > "$CONF_FILE"
<VirtualHost *:80>
    ServerName $DOMAIN
    Redirect permanent / https://$DOMAIN/
</VirtualHost>

<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot $DOC_ROOT

    SSLEngine on
    SSLCertificateFile $SSL_DIR/$DOMAIN.crt
    SSLCertificateKeyFile $SSL_DIR/$DOMAIN.key

    <Directory $DOC_ROOT>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Activation des modules nécessaires
echo "[INFO] Activation du module SSL (si nécessaire)"
dnf install -y mod_ssl

# Redémarrage du service Apache
echo "[INFO] Redémarrage d'Apache"
systemctl restart httpd

echo "[INFO] Configuration HTTPS terminée pour $DOMAIN"
