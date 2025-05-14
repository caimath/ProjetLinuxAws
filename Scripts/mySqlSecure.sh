#!/bin/bash

# Choix mdp root MariaDB
read -s -p "Entrez le mot de passe root que vous désirez : " MARIADB_ROOT_PASSWORD
echo
read -s -p "Confirmez le mot de passe root : " MARIADB_ROOT_PASSWORD_CONFIRM
echo

# Vérifie que les deux mots de passe sont identiques
if [ "$MARIADB_ROOT_PASSWORD" != "$MARIADB_ROOT_PASSWORD_CONFIRM" ]; then
    echo "Les mots de passe ne correspondent pas. Abandon."
    exit 1
fi

# Création mdp root dans MariaDB
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD'; FLUSH PRIVILEGES;"


echo "[*] Configuration sécurisée de MariaDB..."

# Génère les commandes attendues par mysql_secure_installation
sudo mysql_secure_installation <<EOF

$MARIADB_ROOT_PASSWORD
n
n
Y
Y
Y
Y
EOF

echo "[+] mysql_secure_installation terminé avec succès."
