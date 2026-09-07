# DOCKER : BuildKit & Docker Buildx (Fonctionnalités Modernes) {-}

### La Révolution du Moteur de Compilation : BuildKit

Historiquement, le moteur de build Docker exécutait les étapes de manière strictement séquentielle.

Depuis Docker 18.09+ et par défaut en Docker v23+, **BuildKit** est le moteur de compilation de nouvelle génération :

```{.center}
         BUILDER LEGACY (SÉQUENTIEL)                     BUILDKIT (GRAPHE DAG PARALLÈLE)
┌───────────────────────────────────────────┐       ┌───────────────────────────────────────────┐
│ Étape 1 : Base OS                         │       │              ┌──► Étape 2 (Frontend) ──┐  │
│   └── Étape 2 : Dépendances Frontend      │       │ Étape 1 (OS) ┤                         ├──►
│         └── Étape 3 : Compilation Backend │       │              └──► Étape 3 (Backend)  ──┘  │
│               └── Étape 4 : Assemblage    │       │             (Exécutées EN PARALLÈLE !)    │
└───────────────────────────────────────────┘       └───────────────────────────────────────────┘
```

- **Vitesse de compilation multipliée par 2x à 9x**.
- **Graphe acyclique direct (DAG)** : résout et exécute en parallèle toutes les étapes indépendantes.
- **Ignorance des étapes inutilisées** : ne compile pas les étapes non requises par la cible demandée.

### Docker Buildx : L'Outil Professionnel de Build

`buildx` est le plugin CLI officiel qui débloque toute la puissance de BuildKit :

```bash
# 1. Vérifier la présence de buildx
docker buildx version

# 2. Créer une instance de builder dédiée avec support multi-nœuds / conteneurisé
docker buildx create --name mon-builder --driver docker-container --use

# 3. Démarrer et inspecter l'instance
docker buildx inspect --bootstrap
```

### Le Graal : Builds Multi-Architectures Natifs (AMD64 & ARM64)

Avec l'essor des serveurs Cloud Graviton (ARM64) et des puces Apple Silicon (M1/M2/M3), vos images doivent tourner sur **toutes les architectures** :

```{.center}
                                 ┌──► Image Linux AMD64 (Serveurs x86 Intel/AMD)
`docker buildx build` ───────────┼──► Image Linux ARM64 (Apple Silicon, AWS Graviton)
                                 └──► Image Linux ARMv7 (Raspberry Pi, IoT)
                                                 │
                                                 ▼
                                     MANIFESTE UNIQUE UNIFIÉ
                                 (`ghcr.io/org/app:latest`)
```

```bash
# Compiler et publier une image multi-architectures en une seule commande :
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/alterway/multiarch-demo:1.0.0 \
  --push .
```

*Le registre héberge un "Fat Manifest" (Image Index) qui oriente automatiquement chaque machine vers le binaire adapté à son processeur.*

### Montages Avancés : Accélérer les Builds avec `--mount=type=cache`

Ne téléchargez plus jamais vos dépendances (npm, pip, maven, go) lors de chaque `docker build` :

```dockerfile
# syntax=docker/dockerfile:1.7
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./

# Le dossier /root/.npm est persisté hors de l'image entre chaque build !
RUN --mount=type=cache,target=/root/.npm \
    npm ci --prefer-offline

COPY . .
RUN npm run build
```

- **Avantage 1** : Les builds suivants prennent quelques secondes au lieu de plusieurs minutes.
- **Avantage 2** : Les fichiers temporaires du cache npm ne sont **jamais écrits dans les couches de l'image finale** !

### Sécurité Maximale : Injecter des Secrets avec `--mount=type=secret`

Ne risquez plus de fuiter des tokens GitHub, des clés privées ou des mots de passe dans les layers d'une image :

```dockerfile
# syntax=docker/dockerfile:1.7
FROM alpine:3.19

# Le secret est monté temporairement en mémoire vive (RAM) et disparaît après la commande
RUN --mount=type=secret,id=github_token \
    TOKEN=$(cat /run/secrets/github_token) && \
    wget --header="Authorization: Bearer $TOKEN" https://api.internal/package.tar.gz
```

```bash
# Lancement de la compilation avec passage sécurisé du secret hôte :
docker buildx build --secret id=github_token,src=./token.txt -t secure-image .
```

### Authentification Git Sécurisée avec `--mount=type=ssh`

Cloner des dépôts Git privés sans jamais copier votre clé privée SSH dans l'image :

```dockerfile
# syntax=docker/dockerfile:1.7
FROM golang:1.22-alpine
WORKDIR /src

# Utilise la socket de l'agent SSH de l'hôte
RUN --mount=type=ssh \
    git clone git@github.com:my-org/private-repo.git .
```

```bash
# Compilation en transmettant l'agent SSH local de la machine :
docker buildx build --ssh default -t go-app .
```

### Mini-Défi : Secrets de Build avec BuildKit

**Question** : Quel est le bénéfice majeur de `RUN --mount=type=secret` par rapport à l'ancienne méthode `ARG TOKEN=xyz` ?

- **A.** Il crypte le code source avec une clé RSA 4096.
- **B.** Le secret n'est jamais stocké dans les métadonnées de l'image ni dans les couches intermédiaires (0 fuite dans l'historique).
- **C.** Il force l'utilisateur à taper son mot de passe au lancement du conteneur.
- **D.** Il remplace le besoin de variables d'environnement au runtime.

### Mini-Défi : Secrets de Build avec BuildKit

**Question** : Quel est le bénéfice majeur de `RUN --mount=type=secret` par rapport à l'ancienne méthode `ARG TOKEN=xyz` ?

- **A.** Il crypte le code source avec une clé RSA 4096.
- **B.** Le secret n'est jamais stocké dans les métadonnées de l'image ni dans les couches intermédiaires (0 fuite dans l'historique).
- **C.** Il force l'utilisateur à taper son mot de passe au lancement du conteneur.
- **D.** Il remplace le besoin de variables d'environnement au runtime.

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE : B                          │
│  Avec `ARG`, le secret reste visible dans `docker history`  │
│  et dans les métadonnées JSON de l'image. Avec le montage   │
│  `--mount=type=secret`, le secret existe uniquement en RAM  │
│  pendant la commande et n'est JAMAIS persisté.              │
└─────────────────────────────────────────────────────────────┘
```

