#!/bin/bash

echo "Installation de Docker"
sudo dnf install -y docker

echo "Démarrage et activation de Docker"
sudo systemctl enable --now docker

echo "Ajout de ec2-user au groupe docker"
sudo usermod -aG docker ec2-user

echo "Déploiement du conteneur Netdata"
sudo docker run -d --name=netdata \
  -p 19999:19999 \
  -v netdataconfig:/etc/netdata \
  -v netdatalib:/var/lib/netdata \
  -v netdatacache:/var/cache/netdata \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata

echo "Ouverture du port 19999 dans Firewalld si actif"
if systemctl is-active --quiet firewalld; then
  sudo firewall-cmd --permanent --add-port=19999/tcp
  sudo firewall-cmd --reload
else
  echo "Firewalld non actif, tu dois ouvrir le port 19999 dans les règles de sécurité AWS si nécessaire."
fi

echo "Netdata installé. Accès : http://$(hostname -I | awk '{print $1}'):19999"
echo "Déconnecte puis reconnecte ta session SSH pour que ec2-user puisse lancer Docker sans sudo."