# DOCKER : Fondamentaux des Images & Registries {-}

### Qu'est-ce qu'une Image Docker ?

Une image est un **modèle immuable et en lecture seule** contenant tout le nécessaire pour exécuter une application :

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                    ANATOMIE D'UNE IMAGE OCI                 │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │ 1. MANIFESTE JSON (Métadonnées, Architecture, OS)   │   │
│   ├─────────────────────────────────────────────────────┤   │
│   │ 2. CONFIG JSON (Variables ENV, ENTRYPOINT, Ports)   │   │
│   ├─────────────────────────────────────────────────────┤   │
│   │ 3. COUCHE 3 : Code source applicatif (/app)         │   │
│   ├─────────────────────────────────────────────────────┤   │
│   │ 2. COUCHE 2 : Dépendances et bibliothèques (pip/npm)│   │
│   ├─────────────────────────────────────────────────────┤   │
│   │ 1. COUCHE 1 : Système de base minimal (Debian/Alpine)│  │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

- Chaque couche correspond à une empreinte cryptographique unique (**SHA256 Content Addressable**).
- Si deux images partagent la même couche de base, elle n'est **téléchargée et stockée qu'une seule fois**.

### Le Partage des Couches (Layer Sharing)

```{.center}
       IMAGE 1 (PYTHON APP)                       IMAGE 2 (NGINX APP)
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│ Layer 3 : app.py                │       │ Layer 3 : nginx.conf + html     │
├─────────────────────────────────┤       ├─────────────────────────────────┤
│ Layer 2 : python3 + pip         │       │ Layer 2 : nginx binary          │
├─────────────────────────────────┴───────┴─────────────────────────────────┤
│          Layer 1 PARTAGÉ : debian:12-slim (sha256:8a4b...)                │
│             (Téléchargé 1 seule fois, 0 Mo dupliqué !)                    │
└───────────────────────────────────────────────────────────────────────────┘
```

- **Économie drastique d'espace disque** sur l'hôte et sur le registre.
- **Téléchargements quasi-instantanés** lors des déploiements successifs.

### Espaces de Noms (Namespaces) et Structure des Tags

Une image est identifiée selon sa portée dans les registres :

```{.center}
┌────────────────────────────┬──────────────────────────────────┬─────────────────────────────────┐
│ 1. ESPACE ROOT (Officiel)  │ 2. ORGANISATION / UTILISATEUR    │ 3. REGISTRE PRIVÉ COMPLET (FQDN)│
├────────────────────────────┼──────────────────────────────────┼─────────────────────────────────┤
│ `nginx:1.25-alpine`        │ `alterway/api-gateway:2.4.0`     │ `ghcr.io/alterway/auth:v1.0`    │
│ `postgres:16`              │ `herveleclerc/demo:latest`       │ `registry.gitlab.com/grp/app:1` │
│ `ubuntu:22.04`             │                                  │ `12345.dkr.ecr.eu-west-3...`    │
└────────────────────────────┴──────────────────────────────────┴─────────────────────────────────┘
```

### Le Piège du Tag `latest` vs les Digests SHA256

> ⚠️ **IMPORTANT : Le tag `latest` n'est PAS une version figée !**
> `latest` est simplement le tag appliqué par défaut lorsqu'aucun tag n'est spécifié. Il peut pointer vers une version différente d'un jour à l'autre.

```bash
# Mauvaise pratique en production (imprévisible / non reproductible) :
docker run -d my-app:latest

# Bonne pratique (Tag sémantique immuable) :
docker run -d my-app:1.4.2

# Pratique ultra-sécurisée (Digest cryptographique garanti infalsifiable) :
docker run -d my-app@sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

### Commandes Clés de Manipulation des Images

```bash
# 1. Télécharger une image depuis un registre
docker image pull nginx:alpine

# 2. Lister les images locales et inspecter leur taille réelle
docker image ls

# 3. Créer un nouveau tag (alias) pour préparer la publication
docker image tag my-app:1.0 ghcr.io/my-org/my-app:1.0

# 4. Authentification et publication sur un registre distant
docker login ghcr.io -u <username>
docker image push ghcr.io/my-org/my-app:1.0

# 5. Inspecter l'historique et les couches d'une image
docker image history nginx:alpine
```

### Sauvegarde & Transfert Hors-Ligne (`save` & `load`)

Pour les environnements déconnectés d'Internet (*Air-Gapped / Datacenter sécurisé*) :

```bash
# 1. Exporter une ou plusieurs images dans une archive tar
docker image save -o images-bundle.tar nginx:alpine postgres:16

# 2. Transférer le fichier tar vers le serveur cible (via SCP, clé USB sécurisée)
scp images-bundle.tar user@serveur-prod:/tmp/

# 3. Réimporter l'image dans le moteur Docker cible
docker image load -i /tmp/images-bundle.tar
```

### Quizz : Images & Tags

**Que se passe-t-il lorsque l'on supprime une image avec `docker image rm my-app:1.0` qui partage des couches avec `my-app:2.0` ?**

[(X)] Seul le tag `1.0` et ses couches spécifiques non partagées sont supprimés ; les couches communes restent préservées
[( )] Toutes les images du système sont supprimées
[( )] La commande échoue avec une interdiction stricte
[( )] Le disque dur est formaté
