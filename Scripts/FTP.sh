#!/bin/bash

# Script de configuration du serveur FTP avec vsftpd
# Ce script installe et configure le serveur FTP vsftpd sur un système Linux.
# Il ne crée aucun utilisateur FTP, mais configure le service pour qu'il soit prêt à l'emploi.

set -euo pipefail

# Installer vsftpd si pas encore installé
echo "[*] Installation de vsftpd"
sudo dnf install -y vsftpd

echo "[*] Sauvegarde de l'ancienne configuration"
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak || true

echo "[*] Création du répertoire de sécurité"
sudo mkdir -p /var/run/vsftpd/empty
sudo chown -R root:root /var/run/vsftpd/empty
sudo chmod 755 /var/run/vsftpd/empty

echo "Configuration de vsftpd"
cat > /etc/vsftpd/vsftpd.conf <<EOF
 
ftpd_banner=Welcome to the FTP service, no prohibited access allowed.

xferlog_enable=YES


anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
userlist_enable=YES
userlist_deny=NO

local_umask=022
user_sub_token=\$USER
local_root=/var/www/\$USER
secure_chroot_dir=/var/run/vsftpd/empty


pasv_min_port=30000
pasv_max_port=30100

setproctitle_enable=YES

listen_port=21
listen=YES
listen_ipv6=NO

pam_service_name=vsftpd
EOF

echo "Redémarrage du service FTP"
sudo systemctl restart vsftpd