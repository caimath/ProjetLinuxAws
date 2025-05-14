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

# Installer le module SSL pour Apache
sudo dnf install -y mod_ssl

# Demande interactive du nom du client
read -p "Entrez le nom du client (ex: client1) : " CLIENT
# Vérifie que ce n'est pas vide
if [[ -z "$CLIENT" ]]; then
  echo "Erreur : le nom du client est obligatoire."
  exit 1
fi

# Demande un mot de passe à l'utilisateur pour FTP
read -s -p "Mot de passe FTP pour $CLIENT : " FTP_PASSWORD
echo
read -s -p "Confirmez le mot de passe : " FTP_PASSWORD_CONFIRM
echo

# Vérification du mot de passe
if [ "$FTP_PASSWORD" != "$FTP_PASSWORD_CONFIRM" ]; then
    echo "Les mots de passe ne correspondent pas. Abandon."
    exit 1
fi

# Demande un mot de passe à l'utilisateur pour Samba
read -s -p "Mot de passe Samba pour $CLIENT : " SAMBA_PASSWORD
echo
read -s -p "Confirmez le mot de passe : " SAMBA_PASSWORD_CONFIRM
echo


if [ "$SAMBA_PASSWORD" != "$SAMBA_PASSWORD_CONFIRM" ]; then
    echo "Les mots de passe ne correspondent pas. Abandon."
    exit 1
fi

# Demande un mot de passe à l'utilisateur pour Samba
read -s -p "Mot de passe DB pour $CLIENT : " DB_PASSWORD
echo
read -s -p "Confirmez le mot de passe : " DB_PASSWORD_CONFIRM
echo


if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
    echo "Les mots de passe ne correspondent pas. Abandon."
    exit 1
fi



# Variables
DOMAIN="$CLIENT.tungtungsahur.lan"

# Affichage du résumé
echo "Configuration en cours pour le client : $CLIENT avec le domaine : $DOMAIN"

# Rendre les scripts exécutables
sudo chmod +x *.sh


# Appel des modules
sudo ./Environnement.sh "$CLIENT" "$DOMAIN" "$FTP_PASSWORD" "$DB_PASSWORD"
sudo ./FTP.sh "$CLIENT"
sudo ./Samba.sh "$CLIENT" "$SAMBA_PASSWORD"
sudo ./Apache.sh "$CLIENT" "$DOMAIN"
sudo ./DNSClient.sh "$CLIENT"

echo "Configuration terminée pour $CLIENT."
