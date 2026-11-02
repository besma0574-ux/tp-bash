#!/bin/bash

# Gestion des erreurs
set -Eeuo pipefail

# Récupérer l'URL du dépôt Git
REPO_URL="${1:-}"

# Définir les variables
WORKDIR="ci-workspace"
LOG_FILE="ci.log"

# Vérifier l'URL
if [ -z "$REPO_URL" ]; then
    echo "ERREUR : Vous devez fournir une URL Git."
    echo "Utilisation : ./ci.sh <url_du_depot>"
    exit 1
fi

# Fonction pour enregistrer les messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Fonction de vérification
fonction() {
    log "Début des tests."

    if [ ! -f "$WORKDIR/backup.sh" ]; then
        log "ERREUR : backup.sh introuvable."
        return 1
    fi

    if bash -n "$WORKDIR/backup.sh"; then
        log "TEST REUSSI : backup.sh est correct."
    else
        log "ERREUR : backup.sh contient une erreur."
        return 1
    fi

    if [ ! -f "$WORKDIR/check_disk.sh" ]; then
        log "ERREUR : check_disk.sh introuvable."
        return 1
    fi

    if bash -n "$WORKDIR/check_disk.sh"; then
        log "TEST REUSSI : check_disk.sh est correct."
    else
        log "ERREUR : check_disk.sh contient une erreur."
        return 1
    fi

    log "Tous les tests sont réussis."
    return 0
}

# Démarrage du pipeline
log "===== DEBUT DU PIPELINE CI ====="

# Cloner ou actualiser le dépôt
if [ -d "$WORKDIR/.git" ]; then
    log "Mise à jour du dépôt."
    git -C "$WORKDIR" pull 2>&1 | tee -a "$LOG_FILE"
else
    if [ -e "$WORKDIR" ]; then
        log "ERREUR : Le dossier ci-workspace existe déjà."
        exit 1
    fi

    log "Clonage du dépôt Git."
    git clone "$REPO_URL" "$WORKDIR" 2>&1 | tee -a "$LOG_FILE"
fi

# Lancer les tests
if fonction; then
    log "PIPELINE CI TERMINE AVEC SUCCES."
    exit 0
else
    log "PIPELINE CI TERMINE AVEC ECHEC."
    exit 1
fi
