#!/bin/bash
set -euo pipefail

echo "[*] Installation de vsftpd"
sudo dnf install -y vsftpd

echo "[*] Sauvegarde de l'ancienne configuration"
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak || true

echo "[*] Écriture de la configuration FTP claire"
sudo tee /etc/vsftpd/vsftpd.conf > /dev/null <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES

local_umask=022
user_sub_token=\$USER
local_root=/var/www/\$USER

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30100

xferlog_enable=YES
ftpd_banner=Bienvenue sur le serveur FTP.

secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
userlist_enable=YES
userlist_deny=NO
EOF

echo "[*] Ouverture des ports FTP dans le pare-feu"
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=30000-30100/tcp
sudo firewall-cmd --reload

echo "[*] Activation du service FTP"
sudo systemctl enable --now vsftpd

echo "✅ Serveur FTP configuré avec succès. Utilisez FileZilla sur le port 21."
