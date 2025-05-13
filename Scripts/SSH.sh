#!/bin/bash

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté avec les privilèges root." >&2
    exit 1
fi

echo "Début de la configuration SSH"

# Sauvegarde du fichier de configuration existant
CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak"

if [[ ! -f $BACKUP_FILE ]]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Sauvegarde du fichier de configuration existant effectuée : $BACKUP_FILE"
else
    echo "Une sauvegarde existe déjà : $BACKUP_FILE"
fi

# Ajout des configurations si elles n'existent pas déjà
declare -A CONFIGS=(
    ["Protocol"]="2"
    ["PermitRootLogin"]="no"
    ["PasswordAuthentication"]="no"
    ["PubkeyAuthentication"]="yes"
    ["ChallengeResponseAuthentication"]="no"
    ["AllowAgentForwarding"]="no"
    ["PermitTunnel"]="yes"
    ["X11Forwarding"]="no"
    ["MaxAuthTries"]="3"
    ["UsePAM"]="yes"
    ["ClientAliveInterval"]="300"
    ["ClientAliveCountMax"]="2"
    ["LoginGraceTime"]="300"
    ["LogLevel"]="VERBOSE"
)

for KEY in "${!CONFIGS[@]}"; do
    VALUE="${CONFIGS[$KEY]}"
    if grep -q "^$KEY" "$CONFIG_FILE"; then
        sed -i "s/^$KEY.*/$KEY $VALUE/" "$CONFIG_FILE"
    else
        echo "$KEY $VALUE" >> "$CONFIG_FILE"
    fi
done

# Redémarrage du service SSH
sudo systemctl restart sshd
echo "Service SSH redémarré avec succès"
echo "Configuration SSH terminée"
