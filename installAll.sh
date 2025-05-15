#!/bin/bash

# Script maître pour exécuter tous les scripts serveur et client

echo "[INFO] Lancement de l'installation complète des services..."

# Partie serveur
echo "[INFO] Installation des dépendances et configuration des services..."
sudo chmod +x ./Scripts/*.sh

cd ./Scripts
SetupDependances.sh

# Partie client
echo "[INFO] Configuration du client..."
cd ../Client
sudo chmod +x ./Client/*.sh
./Client/SetupClient.sh

echo "[INFO] Installation complète terminée."
