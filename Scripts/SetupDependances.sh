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


sudo systemctl start mariadb

# Rendre les scripts exécutables
sudo chmod +x *.sh
sudo chmod +x ./*.sh


# Appeler les modules

sudo ./DNS.sh
sudo ./ApacheDefault.sh
sudo ./SSH.sh
sudo ./Fail2Ban.sh
sudo ./FTP.sh
sudo ./NFSSamba.sh
sudo ./SSLDomain.sh
sudo ./MySqlSecure.sh
sudo ./DB.sh
sudo ./NTP.sh
sudo ./SELinux.sh
sudo ./NetData.sh
sudo ./Firewall.sh
sudo ./AV.sh


# Démarrer et activer les services
sudo systemctl enable --now named
sudo systemctl enable --now httpd
sudo systemctl enable --now vsftpd
sudo systemctl enable --now smb
sudo systemctl enable --now fail2ban
sudo systemctl enable --now nfs-server
sudo systemctl enable --now mariadb
sudo systemctl enable --now firewalld

echo "Configuration terminée."