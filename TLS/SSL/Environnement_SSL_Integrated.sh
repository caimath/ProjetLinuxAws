#!/bin/bash

# Variables
CLIENT=$1
DOMAIN="$CLIENT.tungtungsahur.lan"
DOCUMENT_ROOT="/var/www/$CLIENT"
VHOST_CONF="/etc/httpd/conf.d/$CLIENT.conf"
CERT_FILE="/etc/pki/tls/certs/$DOMAIN.crt"
KEY_FILE="/etc/pki/tls/private/$DOMAIN.key"

# Créer un fichier de configuration Apache pour le client avec HTTP + HTTPS
sudo bash -c "cat > $VHOST_CONF <<EOF
# Redirection HTTP -> HTTPS
<VirtualHost *:80>
    ServerName $DOMAIN
    Redirect permanent / https://$DOMAIN/
</VirtualHost>

# VirtualHost HTTPS
<VirtualHost *:443>
    ServerAdmin mathias.carsault@std.heh.be
    DocumentRoot $DOCUMENT_ROOT
    ServerName $DOMAIN
    ErrorLog /var/log/httpd/${CLIENT}_error.log
    CustomLog /var/log/httpd/${CLIENT}_access.log combined

    SSLEngine on
    SSLCertificateFile $CERT_FILE
    SSLCertificateKeyFile $KEY_FILE

    <Directory $DOCUMENT_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

# Crée un fichier index.html par défaut
if [ ! -f "$DOCUMENT_ROOT/index.html" ]; then
    echo "<h1>Bienvenue sur votre domaine $CLIENT: $DOMAIN </h1>" | sudo tee "$DOCUMENT_ROOT/index.html" > /dev/null
    sudo chown -R apache:apache "$DOCUMENT_ROOT"
fi

# Redémarrer Apache
sudo systemctl restart httpd
echo "Le site $DOMAIN est configuré avec HTTP → HTTPS"
echo "DocumentRoot : $DOCUMENT_ROOT"
echo "Fichier de configuration : $VHOST_CONF"
