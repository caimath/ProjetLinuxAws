#!/bin/bash

echo "Configuration du serveur NTP avec chrony..."

# Sauvegarde de la configuration existante
sudo cp /etc/chrony.conf /etc/chrony.conf.bak

# Nettoyage des anciennes lignes 'pool'
sudo sed -i '/^pool /d' /etc/chrony.conf

# Ajout de serveurs publics et autorisation pour le réseau local
cat <<EOF | sudo tee -a /etc/chrony.conf

# Serveurs de temps publics
server 0.europe.pool.ntp.org iburst
server 1.europe.pool.ntp.org iburst
server 2.europe.pool.ntp.org iburst

# Autoriser tous les clients du réseau
allow 0.0.0.0/0
local stratum 10
EOF

# Redémarrer le service chronyd
sudo systemctl restart chronyd

# Ouvrir le port NTP si firewalld est actif
if systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --add-service=ntp
  sudo firewall-cmd --reload
else
  echo "Firewalld non actif. Vérifie l'ouverture du port UDP 123 si nécessaire."
fi

echo "Configuration du serveur NTP terminée. Vérifie avec : chronyc tracking"