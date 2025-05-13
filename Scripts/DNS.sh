#!/bin/bash

sudo dnf install -y bind bind-utils

DOMAIN="tungtungsahur.lan"
ZONE_NAME="${DOMAIN}"
ZONE_FILE="/var/named/${ZONE_NAME}.zone"
REVERSE_ZONE_FILE="/var/named/0.42.10.rev"
NAMED_CONF="/etc/named.conf"
DNS_IP="10.42.0.29"  # Adresse IP locale du serveur DNS

# Créer le fichier de zone directe
sudo tee "$ZONE_FILE" > /dev/null <<EOF
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        $(date +%Y%m%d)01 ; Serial
        3600              ; Refresh
        1800              ; Retry
        1209600           ; Expire
        86400 )           ; Minimum TTL

@       IN  NS  ns1.${DOMAIN}.
ns1     IN  A   ${DNS_IP}
EOF

echo "Fichier de zone directe créé : $ZONE_FILE"

# Créer le fichier de zone reverse
sudo tee "$REVERSE_ZONE_FILE" > /dev/null <<EOF
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        $(date +%Y%m%d)01 ; Serial
        3600              ; Refresh
        1800              ; Retry
        1209600           ; Expire
        86400 )           ; Minimum TTL

@       IN  NS  ns1.${DOMAIN}.
29      IN  PTR ns1.${DOMAIN}.
EOF

echo "Fichier de zone reverse créé : $REVERSE_ZONE_FILE"

# Ajouter les zones dans named.conf si elles n'existent pas
if ! grep -q "$DOMAIN" "$NAMED_CONF"; then
  sudo tee -a "$NAMED_CONF" > /dev/null <<EOF

zone "$DOMAIN" IN {
    type master;
    file "$ZONE_FILE";
    allow-update { none; };
};

zone "0.42.10.in-addr.arpa" IN {
    type master;
    file "$REVERSE_ZONE_FILE";
    allow-update { none; };
};
EOF
  echo "Zones $DOMAIN et reverse ajoutées dans $NAMED_CONF"
else
  echo "Zones déjà présentes dans $NAMED_CONF"
fi

# Redémarrer BIND
sudo systemctl restart named && echo "BIND redémarré avec succès"
echo "Configuration DNS terminée"