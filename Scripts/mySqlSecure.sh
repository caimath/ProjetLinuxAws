#!/bin/bash

# Création mdp root 
read -s -p "Entrez le mot de passe root souhaité : " MYSQL_ROOT_PASSWORD
echo
read -s -p "Confirmez le mot de passe root : " MYSQL_ROOT_PASSWORD_CONFIRM
echo

# Vérifie que les deux mots de passe sont identiques
if [ "$MYSQL_ROOT_PASSWORD" != "$MYSQL_ROOT_PASSWORD_CONFIRM" ]; then
    echo "Les mots de passe ne correspondent pas. Abandon."
    exit 1
fi

echo "[*] Configuration sécurisée de MariaDB..."

# Génère les commandes attendues par mysql_secure_installation
sudo mysql_secure_installation <<EOF

y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
y
y
y
y
EOF

echo "[+] mysql_secure_installation terminé avec succès."
