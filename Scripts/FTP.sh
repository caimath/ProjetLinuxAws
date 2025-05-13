#!/bin/

# Installer vsftpd si pas encore installé
sudo dnf install -y vsftpd

cat > /etc/vsftpd/vsftpd.conf <<EOF
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
listen=YES
listen_ipv6=NO
pam_service_name=vsftpd
EOF

sudo systemctl restart vsftpd