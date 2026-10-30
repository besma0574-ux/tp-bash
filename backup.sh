
#!/bin/bash

# Activer la gestion stricte des erreurs
set -Eeuo pipefail

# Récupérer le dossier à sauvegarder
DOSSIER="${1:-data}"

# Définir le dossier de destination des sauvegardes
DESTINATION="backups"

# Vérifier que le dossier existe
if [ ! -d "$DOSSIER" ]; then
    echo "ERREUR : Le dossier $DOSSIER n'existe pas." >&2
    exit 1
fi

# Créer le dossier de sauvegarde
mkdir -p "$DESTINATION"

# Générer la date et l'heure
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Définir le nom de l'archive
ARCHIVE="$DESTINATION/backup_$DATE.tar.gz"

# Créer l'archive compressée
tar -czf "$ARCHIVE" "$DOSSIER"

echo "Sauvegarde créée avec succès : $ARCHIVE"

# Supprimer les anciennes sauvegardes de plus de 7 jours
for fichier in "$DESTINATION"/*.tar.gz; do

    # Vérifier qu'un fichier correspondant existe
    [ -f "$fichier" ] || continue

    # Vérifier si le fichier a plus de 7 jours
    if find "$fichier" -mtime +7 -print -quit | grep -q .; then
        echo "Suppression de l'ancienne sauvegarde : $fichier"
        rm -- "$fichier"
    fi

done

echo "Nettoyage terminé."
exit 0
