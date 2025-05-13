#!/bin/bash

CLIENT=$1
DOMAIN="tungtungsahur.lan"
ZONE_FILE="/var/named/${DOMAIN}.zone"
DNS_IP="10.42.0.29"

if [[ -z "$CLIENT" ]]; then
  echo "Usage: $0 <nom_du_client>"
  exit 1
fi

# Vérifie si le sous-domaine existe déjà
if grep -q "^$CLIENT\s" "$ZONE_FILE"; then
  echo "Le sous-domaine $CLIENT.$DOMAIN existe déjà."
  exit 0
fi

# Ajouter l'entrée A
echo "$CLIENT    IN    A    $DNS_IP" | sudo tee -a "$ZONE_FILE"

# Incrémenter automatiquement le Serial
# Génère une nouvelle date + numéro (ex: 2025051302)
NEW_SERIAL=$(date +%Y%m%d)02

# Remplace l'ancien Serial (ligne contenant SOA)
sudo sed -i -E "s/([0-9]{10}) ; Serial/${NEW_SERIAL} ; Serial/" "$ZONE_FILE"


# Redémarrer BIND
sudo systemctl restart named && echo "Sous-domaine $CLIENT.$DOMAIN ajouté et BIND rechargé"
