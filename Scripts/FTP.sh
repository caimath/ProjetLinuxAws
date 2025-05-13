#!/bin/bash

# Installer vsftpd si pas encore installé
sudo dnf install -y vsftpd

cat > /etc/vsftpd/vsftpd.conf <<EOF

dirmessage_enable=YES 
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


pasv_min_port=30000
pasv_max_port=30100

setproctitle_enable=YES

listen_port=22
listen=YES
listen_ipv6=NO

pam_service_name=vsftpd
EOF

sudo systemctl restart vsftpd