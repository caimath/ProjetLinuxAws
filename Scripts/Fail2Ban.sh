#!/bin/bash

# Variables
IP_SRV="$(hostname -I | awk '{print $1}')"
IP_ADMIN="192.168.42.2"

echo "Installation de Fail2Ban..."

# Vérifie si Fail2Ban est déjà installé
if ! command -v fail2ban-server &> /dev/null; then
    sudo dnf install -y fail2ban || { echo "Échec de l'installation de Fail2Ban. Abandon."; exit 1; }
else
    echo "Fail2Ban est déjà installé."
fi

# Crée le dossier de configuration si nécessaire
sudo mkdir -p /etc/fail2ban/jail.d

# Configure Fail2Ban pour protéger le service SSH
cat <<EOF | sudo tee /etc/fail2ban/jail.d/sshd.local > /dev/null
[sshd]
enabled = true
port = 22
action = %(action_mwl)s
logpath = %(sshd_log)s
maxretry = 3
bantime = 600
findtime = 600
ignoreip = $IP_ADMIN
EOF

# Configure Fail2Ban pour protéger le service FTP
cat <<EOF | sudo tee /etc/fail2ban/jail.d/vsftpd.local > /dev/null
[vsftpd]
enabled = true
port = 21
action = %(action_mwl)s
logpath = /var/log/vsftpd.log
maxretry = 3
bantime = 600
findtime = 600
ignoreip = $IP_ADMIN
EOF

# Active et démarre le service Fail2Ban
sudo systemctl enable fail2ban || { echo "Échec de l'activation de Fail2Ban. Abandon."; exit 1; }
sudo systemctl start fail2ban || { echo "Échec du démarrage de Fail2Ban. Abandon."; exit 1; }

echo "Fail2Ban installé et configuré avec succès."
