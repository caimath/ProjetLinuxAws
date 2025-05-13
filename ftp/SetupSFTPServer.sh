#!/bin/bash
set -euo pipefail

# ----------------- Configuration du serveur SFTP -----------------

echo "[*] Installation de l'environnement SFTP"
sudo dnf install -y openssh-server

echo "[*] Activation du service SSH"
sudo systemctl enable --now sshd

echo "[*] Configuration de base du groupe SFTP"
sudo groupadd -f sftpusers

# Ajout de la section SFTP dans sshd_config si elle n'existe pas déjà
if ! grep -q "Match Group sftpusers" /etc/ssh/sshd_config; then
  sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF

Match Group sftpusers
    ChrootDirectory /var/www/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
EOF
fi

echo "[*] Redémarrage du service SSH"
sudo systemctl restart sshd
