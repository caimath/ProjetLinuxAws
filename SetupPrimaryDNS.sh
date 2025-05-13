#!/bin/bash
set -euo pipefail

# ---------------------- CONFIGURATION ----------------------
DOMAIN="tungtungsahur.lan"
REVERSE_ZONE="0.42.10.in-addr.arpa"
DNS_IP="10.42.0.29"

ZONE_FILE="/var/named/${DOMAIN}.zone"
REVERSE_ZONE_FILE="/var/named/0.42.10.rev"
NAMED_CONF="/etc/named.conf"
SERIAL=$(date +%Y%m%d)01
# -----------------------------------------------------------

echo "[*] Installation de BIND"
sudo dnf install -y bind bind-utils

echo "[*] Suppression des anciennes zones si présentes"
sudo rm -f "$ZONE_FILE" "$REVERSE_ZONE_FILE"

echo "[*] Création de la zone directe"
sudo tee "$ZONE_FILE" > /dev/null <<EOF
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        $SERIAL ; Serial
        3600    ; Refresh
        1800    ; Retry
        1209600 ; Expire
        86400 ) ; Minimum TTL

@       IN  NS  ns1.${DOMAIN}.
ns1     IN  A   ${DNS_IP}
EOF

echo "[*] Création de la zone reverse"
sudo tee "$REVERSE_ZONE_FILE" > /dev/null <<EOF
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        $SERIAL ; Serial
        3600    ; Refresh
        1800    ; Retry
        1209600 ; Expire
        86400 ) ; Minimum TTL

@       IN  NS  ns1.${DOMAIN}.
29      IN  PTR ns1.${DOMAIN}.
EOF

echo "[*] Droits SELinux + permissions"
sudo chown named:named "$ZONE_FILE" "$REVERSE_ZONE_FILE"
sudo restorecon "$ZONE_FILE" "$REVERSE_ZONE_FILE"

echo "[*] Nettoyage et mise à jour de named.conf"
sudo cp "$NAMED_CONF" "${NAMED_CONF}.bak"

sudo awk '
/^options\s*{/,/^};/ {
    if (!done) {
        print "options {"
        print "    listen-on port 53 { any; };"
        print "    listen-on-v6 port 53 { ::1; };"
        print "    directory       \"/var/named\";"
        print "    dump-file       \"/var/named/data/cache_dump.db\";"
        print "    statistics-file \"/var/named/data/named_stats.txt\";"
        print "    memstatistics-file \"/var/named/data/named_mem_stats.txt\";"
        print "    secroots-file   \"/var/named/data/named.secroots\";"
        print "    recursing-file  \"/var/named/data/named.recursing\";"
        print "    allow-query     { any; };"
        print "    recursion yes;"
        print "    dnssec-validation yes;"
        print "    managed-keys-directory \"/var/named/dynamic\";"
        print "    geoip-directory \"/usr/share/GeoIP\";"
        print "    pid-file \"/run/named/named.pid\";"
        print "    session-keyfile \"/run/named/session.key\";"
        print "    include \"/etc/crypto-policies/back-ends/bind.config\";"
        print "};"
        done = 1
    }
    next
}
{ print }
' "$NAMED_CONF" | sudo tee "$NAMED_CONF" > /dev/null

if ! grep -q "$DOMAIN" "$NAMED_CONF"; then
  echo "[*] Ajout des zones dans named.conf"
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
fi

echo "[*] Vérification des fichiers de zone"
sudo named-checkzone "$DOMAIN" "$ZONE_FILE"
sudo named-checkzone "$REVERSE_ZONE" "$REVERSE_ZONE_FILE"

echo "[*] Redémarrage du service named"
sudo systemctl enable --now named
sudo systemctl restart named

echo "DNS principal configuré avec succès pour le domaine $DOMAIN"
