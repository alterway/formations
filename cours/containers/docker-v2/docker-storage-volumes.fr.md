# DOCKER : Gestion du Stockage Persistant & Volumes {-}

### L'Éphémérité des Conteneurs par Défaut

Par défaut, tout fichier créé à l'intérieur d'un conteneur est écrit dans sa couche supérieure en lecture/écriture (*Upper Layer*).

> ⚠️ **Conséquence critique :**
> - Lorsque le conteneur est supprimé (`docker rm`), **toutes ses données sont définitivement perdues**.
> - Les performances d'écriture sur l'UnionFS (Overlay2) sont moins rapides qu'un accès direct au disque.
> - Impossible de partager simplement des données entre plusieurs conteneurs.

### Les 3 Types de Montages Docker

```{.center}
┌──────────────────────────────┬──────────────────────────────┬──────────────────────────────┐
│ 1. VOLUMES NOMMÉS (Docker)   │ 2. BIND MOUNTS (Hôte direct) │ 3. TMPFS MOUNTS (RAM)        │
├──────────────────────────────┼──────────────────────────────┼──────────────────────────────┤
│ Stockés dans l'espace géré   │ Montent un dossier ou fichier│ Stockés uniquement en        │
│ `/var/lib/docker/volumes/`   │ spécifique de votre machine  │ mémoire vive (RAM) de l'hôte │
│                              │                              │                              │
│ ✔ Haute performance         │ ✔ Idéal pour le code source  │ ✔ Ultra-rapide               │
│ ✔ Indépendants du conteneur  │   en développement (live-edit│ ✔ Données sensibles (jamais  │
│ ✔ Sauvegarde et migration    │ ✘ Dépendant de l'OS hôte     │   écrites sur le disque)     │
└──────────────────────────────┴──────────────────────────────┴──────────────────────────────┘
```

### Syntaxe Moderne `--mount` vs Syntaxe Historique `-v`

Docker recommande la syntaxe explicite `--mount` (plus claire, plus stricte et standardisée avec Swarm) :

```bash
# 1. Montage d'un Volume Nommé (Production / Bases de données)
docker run -d --name db-postgres \
  --mount type=volume,source=pg_data,target=/var/lib/postgresql/data \
  postgres:16

# 2. Montage d'un Dossier Local / Bind Mount (Développement à chaud)
docker run -d --name dev-server -p 3000:3000 \
  --mount type=bind,source="$(pwd)/src",target=/app/src,readonly=false \
  node:20-alpine

# 3. Montage Temporaire en RAM (tmpfs)
docker run -d --name session-cache \
  --mount type=tmpfs,target=/tmp/cache,tmpfs-size=100m \
  redis:alpine
```

### Cycle de Vie & Commandes des Volumes

```bash
# 1. Créer manuellement un volume
docker volume create db-prod-vol

# 2. Lister tous les volumes existants
docker volume ls

# 3. Inspecter le point de montage exact sur le système de fichiers hôte
docker volume inspect db-prod-vol

# 4. Supprimer un volume inutilisé
docker volume rm db-prod-vol

# 5. Nettoyer tous les volumes orphelins (libérer l'espace disque)
docker volume prune -f
```

### Inspection d'un Volume : Trouver les Fichiers sur l'Hôte

```bash
docker volume inspect db-prod-vol
```

```json
[
  {
    "CreatedAt": "2024-05-10T14:30:00Z",
    "Driver": "local",
    "Labels": {},
    "Mountpoint": "/var/lib/docker/volumes/db-prod-vol/_data",
    "Name": "db-prod-vol",
    "Options": {},
    "Scope": "local"
  }
]
```

### Sauvegarde & Restauration d'un Volume via un Conteneur Utilitaire

Comment sauvegarder le contenu d'un volume sans arrêter Docker ? En utilisant un conteneur temporaire éphémère :

```bash
# 1. SAUVEGARDE : Archiver le volume 'pg_data' dans 'backup.tar.gz'
docker run --rm \
  --mount type=volume,source=pg_data,target=/volume-data,readonly \
  --mount type=bind,source="$(pwd)",target=/backup \
  alpine tar czvf /backup/pg_data_backup.tar.gz -C /volume-data .

# 2. RESTAURATION : Restaurer l'archive dans un nouveau volume 'pg_data_restored'
docker volume create pg_data_restored
docker run --rm \
  --mount type=volume,source=pg_data_restored,target=/volume-data \
  --mount type=bind,source="$(pwd)",target=/backup,readonly \
  alpine tar xzvf /backup/pg_data_backup.tar.gz -C /volume-data
```

### Problématiques de Droits & Permissions (UID/GID) avec les Bind Mounts

Lors d'un bind mount entre l'hôte et le conteneur, les permissions de fichiers Linux s'appliquent selon l'UID numérique :
- Si l'utilisateur du conteneur est `node (UID 1000)` et que le dossier hôte appartient à `root (UID 0)`, le conteneur recevra une erreur `Permission Denied` lors d'une écriture.

```bash
# Solution : Spécifier explicitement l'UID/GID lors de l'exécution
docker run -d --user "$(id -u):$(id -g)" \
  --mount type=bind,source="$(pwd)",target=/app \
  my-app:dev
```

### Quizz : Volumes & Stockage

**Si vous supprimez un conteneur avec `docker rm -f my-db`, qu'advient-il de son volume nommé monté ?**

[(X)] Le volume nommé reste intact sur le disque et peut être réattaché immédiatement à un nouveau conteneur
[( )] Le volume est automatiquement et définitivement détruit
[( )] Le volume est vidé de toutes ses données mais conservé vide
[( )] Le système d'exploitation plante
