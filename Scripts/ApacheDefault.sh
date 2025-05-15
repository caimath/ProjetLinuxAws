#!/bin/bash

# Création du dossier racine

cat > /etc/httpd/conf.d/00-default.conf <<EOF
 
<VirtualHost *:80>
    ServerName tungtungsahur.lan
    DocumentRoot /var/www/tungtungsahur.lan
    Redirect permanent / https://tungtungsahur.lan/
</VirtualHost>

<VirtualHost *:443>
    ServerName tungtungsahur.lan
    DocumentRoot /var/www/tungtungsahur.lan

    SSLEngine on
    SSLCertificateFile /etc/ssl/tungtungsahur.lan/tungtungsahur.lan.crt
    SSLCertificateKeyFile /etc/ssl/tungtungsahur.lan/tungtungsahur.lan.key

    <Directory /var/www/tungtungsahur.lan>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo systemctl restart httpd
