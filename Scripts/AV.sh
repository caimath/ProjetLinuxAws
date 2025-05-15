#!/bin/bash

# Installer ClamAV + clamd (le démon)
sudo dnf install -y clamav clamav-update clamav-server

echo "ClamAV installé"

# Mettre à jour la base de signatures virales
sudo sed -i 's/^Example/#Example/' /etc/freshclam.conf
sudo freshclam
echo " Base virale mise à jour (freshclam)"

# Configurer clamd pour qu'il fonctionne avec le socket
sudo sed -i 's/^Example/#Example/' /etc/clamd.d/scan.conf
sudo sed -i 's/^#LocalSocket /LocalSocket /' /etc/clamd.d/scan.conf
sudo sed -i 's|^LocalSocket .*|LocalSocket /run/clamd.scan/clamd.sock|' /etc/clamd.d/scan.conf
echo "Configuration du démon clamd prête"

# Activer et démarrer le démon
sudo systemctl enable --now clamd@scan
echo " Service clamd lancé"

# Vérifier que le socket est bien lancé
if [ ! -S /run/clamd.scan/clamd.sock ]; then
  echo "[...] Attente du socket clamd"
  sleep 5
fi

# Créer le dossier des logs si besoin
sudo mkdir -p /var/log/clamav
sudo touch /var/log/clamav/scan.log
echo "Log prêt : /var/log/clamav/scan.log"

# Premier scan de test
echo "Scan initial sur /var/www et /etc"
sudo clamscan --log=/var/log/clamav/scan.log /var/www /etc
echo "Scan initial terminé"

# Configurer un cron pour scanner automatiquement chaque nuit
CRON_FILE="/etc/cron.d/clamav-scan"

sudo mkdir -p /etc/cron.d
sudo tee "$CRON_FILE" > /dev/null <<EOF
0 3 * * * root clamscan --log=/var/log/clamav/scan.log /var/www /etc
EOF

echo " Scan automatique programmé chaque nuit à 3h"
echo "ClamAV est prêt. Tu peux consulter les logs ici : /var/log/clamav/scan.log"