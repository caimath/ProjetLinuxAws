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

# Modifier la configuration de named.conf si nécessaire
echo "[*] Vérification de la configuration de named.conf..."

sudo sed -i 's/listen-on port 53 {.*}/listen-on port 53 { any; };/' "$NAMED_CONF"
sudo sed -i 's/allow-query {.*}/allow-query { any; };/' "$NAMED_CONF"

# Supprimer les fichiers de zone existants pour éviter les conflits
for FILE in "$ZONE_FILE" "$REVERSE_ZONE_FILE"; do
  if [ -f "$FILE" ]; then
    echo "Fichier existant détecté : $FILE -> suppression"
    sudo rm -f "$FILE"
  fi
done

# Créer la zone directe
echo "[*] Création de la zone directe..."
sudo tee "$ZONE_FILE" > /dev/null <<'EOF'
$TTL 86400
@   IN  SOA ns1.tungtungsahur.lan. admin.tungtungsahur.lan. (
        2025051301 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Minimum TTL

@       IN  NS  ns1.tungtungsahur.lan.
ns1     IN  A   10.42.0.29
EOF

# Créer la zone reverse
echo "[*] Création de la zone reverse..."
sudo tee "$REVERSE_ZONE_FILE" > /dev/null <<'EOF'
$TTL 86400
@   IN  SOA ns1.tungtungsahur.lan. admin.tungtungsahur.lan. (
        2025051301 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Minimum TTL

@       IN  NS  ns1.tungtungsahur.lan.
29      IN  PTR ns1.tungtungsahur.lan.
EOF

# Donner les bonnes permissions + contexte SELinux
sudo chown named:named "$ZONE_FILE" "$REVERSE_ZONE_FILE"
sudo restorecon "$ZONE_FILE" "$REVERSE_ZONE_FILE"

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
sudo named-checkzone "$DOMAIN" "$ZONE_FILE" || { echo "Erreur dans la zone directe"; exit 1; }
sudo named-checkzone "$REVERSE_ZONE" "$REVERSE_ZONE_FILE" || { echo "Erreur dans la zone reverse"; exit 1; }

# Redémarrer le service BIND
echo "Redémarrage du service named."
sudo systemctl enable --now named
sudo systemctl restart named

echo "✅ Configuration DNS terminée avec succès pour le domaine $DOMAIN"
