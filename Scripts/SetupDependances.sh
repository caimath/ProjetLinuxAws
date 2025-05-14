#!/bin/bash



# Installer les dépendances nécessaires pour le serveur
sudo dnf install -y \
  bind bind-utils \
  httpd \
  vsftpd \
  samba samba-client samba-common \
  nfs-utils \
  firewalld \
  net-tools 

# Installer mariadb
sudo tee /etc/yum.repos.d/MariaDB.repo > /dev/null <<EOF
[mariadb]
name = MariaDB
baseurl = https://yum.mariadb.org/10.6/rhel9-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

sudo dnf install -y MariaDB-server MariaDB-client




# Démarrer et activer les services
sudo systemctl enable --now named
sudo systemctl enable --now httpd
sudo systemctl enable --now vsftpd
sudo systemctl enable --now smb
sudo systemctl enable --now fail2ban
sudo systemctl enable --now nfs-server
sudo systemctl enable --now mariadb
sudo systemctl enable --now firewalld

sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=30000-30100/tcp
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --reload

sudo systemctl start mariadb

# Rendre les scripts exécutables
sudo chmod +x *.sh
sudo chmod +x ./*.sh


# Appeler les modules
sudo ./DNS.sh
sudo ./SSH.sh
sudo ./Fail2Ban.sh
sudo ./FTP.sh
sudo ./NFSSamba.sh
sudo ./SSLDomain.sh
sudo ./MySqlSecure.sh
sudo ./DB.sh
sudo ./NTP.sh

echo "Configuration terminée."