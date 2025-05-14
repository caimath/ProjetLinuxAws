#!/bin/bash

echo "[*] Vérification et activation de SELinux si nécessaire..."

# Vérifier si SELinux est installé
if ! command -v getenforce >/dev/null 2>&1; then
    echo "[+] Installation des outils SELinux..."
    sudo dnf install -y policycoreutils selinux-policy selinux-policy-targeted
fi

# Afficher le statut actuel
echo "Statut actuel de SELinux : $(getenforce)"

# Modifier le fichier de configuration si nécessaire
SELINUX_CONF="/etc/selinux/config"
if grep -q "^SELINUX=disabled" "$SELINUX_CONF"; then
    echo "[+] Activation de SELinux en mode enforcing (redémarrage requis)"
    sudo sed -i 's/^SELINUX=disabled/SELINUX=enforcing/' "$SELINUX_CONF"
    setenforce 1 || echo "[!] Redémarre le système pour appliquer le changement."
elif grep -q "^SELINUX=permissive" "$SELINUX_CONF"; then
    echo "[+] Passage en mode enforcing (immédiat)"
    sudo sed -i 's/^SELINUX=permissive/SELINUX=enforcing/' "$SELINUX_CONF"
    setenforce 1
else
    echo "[=] SELinux est déjà actif en mode enforcing."
fi

echo "Statut final: $(getenforce)"


echo "[*] Application des contextes SELinux "

# Vérifier que semanage est installé
if ! command -v semanage &> /dev/null; then
  echo "[+] Installation de semanage..."
  sudo dnf install -y policycoreutils-python-utils
fi

# Apache - contenu dans /var/www
echo "[+] Contexte SELinux pour Apache (/var/www)"
semanage fcontext -m -t httpd_sys_content_t "/var/www(/.*)?"
semanage fcontext -m -t httpd_sys_rw_content_t "/var/www/tungtungsahur.lan/phpMyAdmin(/.*)?"
restorecon -Rv /var/www

# FTP et Samba - contenu dans /var/www/$client
echo "[+] Contexte SELinux pour FTP/Samba (/var/www/<client>)"
semanage fcontext -m -t public_content_rw_t "/var/www/[^/]+(/.*)?"
restorecon -Rv /var/www

# Samba et NFS - /srv/nfs/share
echo "[+] Contexte SELinux pour NFS (/srv/nfs/share)"
semanage fcontext -m -t public_content_rw_t "/srv/nfs/share(/.*)?"
restorecon -Rv /srv/nfs/share

# DNS - BIND
echo "[+] Contexte SELinux pour BIND (/var/named)"
restorecon -Rv /var/named

# Booléens SELinux nécessaires
echo "[+] Activation des booléens SELinux nécessaires"
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_execmem 1
setsebool -P allow_ftpd_full_access 1
setsebool -P samba_enable_home_dirs 1

echo "[*] Configuration SELinux terminée avec succès."
