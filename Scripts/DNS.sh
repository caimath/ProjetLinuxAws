#!/bin/bash
set -euo pipefail

# ---------------------- CONFIGURATION ----------------------
DOMAIN="tungtungsahur.lan"
REVERSE_ZONE="0.42.10.in-addr.arpa"
DNS_IP="10.42.0.29"  # IP du serveur DNS

ZONE_FILE="/var/named/${DOMAIN}.zone"
REVERSE_ZONE_FILE="/var/named/0.42.10.rev"
NAMED_CONF="/etc/named.conf"

SERIAL=$(date +%Y%m%d)01
# -----------------------------------------------------------

echo "Installation de BIND si nécessaire"
sudo dnf install -y bind bind-utils

# Supprimer les fichiers de zone existants pour éviter les conflits
for FILE in "$ZONE_FILE" "$REVERSE_ZONE_FILE"; do
  if [ -f "$FILE" ]; then
    echo "Fichier existant détecté : $FILE -> suppression"
    sudo rm -f "$FILE"
  fi
done

# Créer la zone directe
echo "[*] Création de la zone directe..."
sudo tee "$ZONE_FILE" > /dev/null <<EOF
$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        $SERIAL ; Serial
        3600    ; Refresh
        1800    ; Retry
        1209600 ; Expire
        86400 ) ; Minimum TTL

@       IN  NS  ns1.${DOMAIN}.
ns1     IN  A   ${DNS_IP}
EOF

# Créer la zone reverse
echo "[*] Création de la zone reverse..."
sudo tee "$REVERSE_ZONE_FILE" > /dev/null <<EOF
$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        $SERIAL ; Serial
        3600    ; Refresh
        1800    ; Retry
        1209600 ; Expire
        86400 ) ; Minimum TTL

@       IN  NS  ns1.${DOMAIN}.
29      IN  PTR ns1.${DOMAIN}.
EOF


# Ajouter les zones dans named.conf si elles ne sont pas déjà présentes
if ! grep -q "$DOMAIN" "$NAMED_CONF"; then
  echo "Ajout des zones dans $NAMED_CONF"
  sudo tee -a "$NAMED_CONF" > /dev/null <<EOF

zone "$DOMAIN" IN {
    type master;
    file "$ZONE_FILE";
    allow-update { none; };
};

zone "$REVERSE_ZONE" IN {
    type master;
    file "$REVERSE_ZONE_FILE";
    allow-update { none; };
};
EOF
else
  echo "Les zones sont déjà présentes dans $NAMED_CONF"
fi

# Vérification des fichiers de zone
echo "Vérification des fichiers de zone"
sudo named-checkzone "$DOMAIN" "$ZONE_FILE"
sudo named-checkzone "$REVERSE_ZONE" "$REVERSE_ZONE_FILE"

# Redémarrer le service BIND
echo "Redémarrage du service named."
sudo systemctl enable --now named
sudo systemctl restart named

echo "Configuration DNS terminée avec succès pour le domaine $DOMAIN"
