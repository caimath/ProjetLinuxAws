#!/bin/bash
set -euo pipefail

# ---------------------- CONFIGURATION ----------------------
DOMAIN="tungtungsahur.lan"
REVERSE_ZONE="0.42.10.in-addr.arpa"
DNS_IP="10.42.0.34"

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
@       IN  A   ${DNS_IP}
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
34      IN  PTR ns1.${DOMAIN}.
EOF

echo "[*] Droits SELinux + permissions"
sudo chown named:named "$ZONE_FILE" "$REVERSE_ZONE_FILE"
sudo restorecon "$ZONE_FILE" "$REVERSE_ZONE_FILE"

echo "[*] Écriture complète du fichier named.conf avec cat <<EOF"
sudo cp "$NAMED_CONF" "${NAMED_CONF}.bak"

sudo cat <<EOF > "$NAMED_CONF"
options {
    listen-on port 53 { 127.0.0.1; $DNS_IP; }; ### DNS principal ###*
    listen-on-v6 { none; };
    directory     "/var/named";
    dump-file     "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query { localhost; any; }; ### Clients VPN ###
    recursion yes;
    dnssec-validation yes;
    bindkeys-file "/etc/named.iscdlv.key";
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";

    forwarders {
        1.1.1.1;
        8.8.8.8;
    };
};


logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};

zone "." IN {
    type hint;
    file "named.ca";
};

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

echo "[*] Vérification des fichiers de zone"
sudo named-checkzone "$DOMAIN" "$ZONE_FILE"
sudo named-checkzone "$REVERSE_ZONE" "$REVERSE_ZONE_FILE"

echo "[*] Redémarrage du service named"
sudo systemctl enable --now named
sudo systemctl restart named

echo "DNS principal configuré avec succès pour le domaine $DOMAIN"