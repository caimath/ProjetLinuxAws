#!/bin/bash

# Installer les dépendances nécessaires pour le serveur
sudo dnf install -y \
  bind bind-utils \
  httpd \
  vsftpd \
  samba samba-client samba-common \
  nfs-utils \
  mariadb-server mariadb \
  firewalld \
  net-tools \
  php php-mysqlnd


# Demande interactive du nom du client
read -p "Entrez le nom du client (ex: client1) : " CLIENT
# Vérifie que ce n'est pas vide
if [[ -z "$CLIENT" ]]; then
  echo "Erreur : le nom du client est obligatoire."
  exit 1
fi

# Variables
DOMAIN="$CLIENT.tungtungsahur.lan"

# Affichage du résumé
echo "Configuration en cours pour le client : $CLIENT avec le domaine : $DOMAIN"

# Appel des modules
./Environnement.sh "$CLIENT" "$DOMAIN"
./Apache.sh "$CLIENT" "$DOMAIN"
./FTP.sh "$CLIENT"
./Samba.sh "$CLIENT"
./DNSClient.sh "$CLIENT"

echo "Configuration terminée pour $CLIENT."
