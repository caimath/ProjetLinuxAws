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
if command -v mysql_secure_installation &> /dev/null; then
    sudo mysql_secure_installation <<EOF

$MARIADB_ROOT_PASSWORD
n
n
Y
Y
Y
Y
EOF
else
    echo "[*] mysql_secure_installation non trouvé, exécution d'un script alternatif pour sécuriser MariaDB..."

    # Supprime les utilisateurs anonymes
    sudo mysql -u root -p"$MARIADB_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User='';"

    # Désactive les connexions root à distance
    sudo mysql -u root -p"$MARIADB_ROOT_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost');"

    # Supprime la base de données de test
    sudo mysql -u root -p"$MARIADB_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS test;"
    sudo mysql -u root -p"$MARIADB_ROOT_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

    # Recharge les tables de privilèges
    sudo mysql -u root -p"$MARIADB_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

    echo "[+] Sécurisation alternative de MariaDB terminée avec succès."
fi

echo "[+] mysql_secure_installation terminé avec succès."
