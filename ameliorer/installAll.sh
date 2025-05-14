#!/bin/bash

# Script maître pour exécuter tous les scripts serveur et client

echo "[INFO] Lancement de l'installation complète des services..."

# Partie serveur
./Scripts/SetupDependances.sh
./Scripts/NFSSamba.sh
./Scripts/DNS.sh
./Scripts/FTP.sh
./Scripts/DB.sh
./Scripts/MySqlSecure.sh
./Scripts/SSH.sh
./Scripts/Fail2Ban.sh

# Partie client
./Client/Environnement.sh
./Client/DNSClient.sh
./Client/Apache.sh
./Client/Samba.sh
./Client/FTP.sh
./Client/SetupClient.sh

echo "[INFO] Installation complète terminée."
