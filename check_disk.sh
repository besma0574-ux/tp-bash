
#!/bin/bash

# Définir le seuil : 80% par défaut
SEUIL=${1:-80}

# Récupérer le pourcentage d'espace disque utilisé
UTILISATION=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

# Afficher les informations
echo "Espace disque utilisé : ${UTILISATION}%"
echo "Seuil fixé : ${SEUIL}%"

# Comparer l'utilisation avec le seuil
if [ "$UTILISATION" -ge "$SEUIL" ]; then
    echo "ALERTE : L'espace disque utilisé dépasse ou atteint le seuil !"
    exit 1
else
    echo "OK : L'espace disque est suffisant."
    exit 0
fi
