#!/bin/bash

# Variables
CLIENT=$1
DOMAIN="$CLIENT.tungtungsahur.lan"
DOCUMENT_ROOT="/var/www/$CLIENT"
VHOST_CONF="/etc/httpd/conf.d/$CLIENT.conf"

# Créer un fichier de configuration Apache pour le client
sudo bash -c "cat > $VHOST_CONF <<EOF
<VirtualHost *:80>
    ServerAdmin mathias.carsault@std.heh.be
    DocumentRoot $DOCUMENT_ROOT
    ServerName $DOMAIN
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

# Crée un fichier index.html par défaut
if [ ! -f "$DOCUMENT_ROOT/index.html" ]; then
    sudo echo "<h1>Bienvenue sur votre domaine $CLIENT: $DOMAIN </h1>" > $DOCUMENT_ROOT/index.html
    sudo chown -R apache:apache "$DOCUMENT_ROOT"
fi

# Activer le site et recharger Apache
sudo systemctl restart httpd
echo "Le site $DOMAIN est configuré avec succès."
echo "DocumentRoot : $DOCUMENT_ROOT"
echo "Fichier de configuration : $VHOST_CONF"