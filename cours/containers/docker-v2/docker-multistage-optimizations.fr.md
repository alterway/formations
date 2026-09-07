# DOCKER : Builds Multi-Étapes & Optimisation des Images {-}

### Le Pattern Multi-Stage Build : L'Élégance Absolue

Pour compiler un programme (Go, Java, Rust, TypeScript, C++), il faut des outils lourds (compilateurs, SDKs, Maven, NPM). Mais **ces outils ne doivent jamais figurer en production** !

Le **Multi-Stage Build** résout ce problème avec plusieurs instructions `FROM` dans un même Dockerfile :

```dockerfile
# ==============================================================================
# ÉTAPE 1 : BUILDER (Lourd, contient le compilateur Go et les outils de build)
# ==============================================================================
FROM golang:1.22-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
# Compilation d'un binaire statique sans dépendance C (CGO_ENABLED=0)
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/server .

# ==============================================================================
# ÉTAPE 2 : RUNTIME (Ultra-léger, contient UNIQUEMENT le binaire final)
# ==============================================================================
FROM alpine:3.19
WORKDIR /app

# Récupération chirurgicale du binaire depuis l'étape 'builder'
COPY --from=builder /app/server /app/server

USER 1000:1000
EXPOSE 8080
CMD ["/app/server"]
```

### Résultats Spectaculaires : Étude de Cas

```{.center}
┌─────────────────────────────────┬──────────────────────┬────────────────────────┐
│ MÉTHODE DE FABRICATION          │ TAILLE DE L'IMAGE    │ VULNÉRABILITÉS (CVE)   │
├─────────────────────────────────┼──────────────────────┼────────────────────────┤
│ Build classique (Mono-stage)    │ 850 Mo (Go SDK + OS) │ 140+ CVEs détectées    │
│ Multi-stage avec Alpine         │ 18 Mo                │ 0 CVE critique         │
│ Multi-stage avec Scratch / Static│ 8 Mo                │ 0 CVE (Surface zéro)   │
└─────────────────────────────────┴──────────────────────┴────────────────────────┘
```

### Choisir la Bonne Image de Base

```{.center}
┌───────────────────────┬───────────┬──────────────────────────────────────────────┐
│ IMAGE DE BASE         │ TAILLE    │ CAS D'USAGE RECOMMANDÉ                       │
├───────────────────────┼───────────┼──────────────────────────────────────────────┤
│ `debian:bookworm-slim`│ ~75 Mo    │ Applications avec dépendances C/glibc lourdes│
│ `alpine:3.19`         │ ~7 Mo     │ Standard léger avec gestionnaire de paquets  │
│ `gcr.io/distroless/*` │ ~20 Mo    │ Sécurité maximale (sans shell, sans package) │
│ `scratch`             │ 0 Mo      │ Binaire statique pur (Go, Rust, C)           │
└───────────────────────┴───────────┴──────────────────────────────────────────────┘
```

### Cibles Multiples (`--target`) pour Dev, Test et Prod

Un seul Dockerfile peut gérer l'ensemble de la chaîne de développement :

```dockerfile
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

FROM base AS development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

FROM base AS test
RUN npm ci
COPY . .
RUN npm test

FROM base AS production
RUN npm ci --only=production
COPY . .
USER node
CMD ["node", "index.js"]
```

```bash
# Lancer l'environnement de développement :
docker build --target development -t myapp:dev .

# Exécuter les tests unitaires en CI/CD :
docker build --target test -t myapp:test .

# Compiler l'image finale de production :
docker build --target production -t myapp:prod .
```

### La Règle d'Or de l'Invalidation du Cache

Docker met en cache chaque couche. Dès qu'une instruction est modifiée, **toutes les instructions suivantes sont recompilées sans cache** :

```{.center}
       MAUVAISE PRATIQUE (CACHE CASSÉ À CHAQUE LIGNE DE CODE)
┌─────────────────────────────────────────────────────────────┐
│ COPY . .                     ── Dès qu'un fichier change    │
│ RUN npm install              ── npm réinstalle TOUT (5 min) │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
        BONNE PRATIQUE (CACHE RÉUTILISÉ À 99%)
┌─────────────────────────────────────────────────────────────┐
│ COPY package*.json ./        ── Mis en cache si package fixe │
│ RUN npm ci                   ── Exécuté UNIQUEMENT si modif │
│ COPY . .                     ── Seul le code source change  │
└─────────────────────────────────────────────────────────────┘
```

### L'Indispensable Fichier `.dockerignore`

Tout comme `.gitignore`, le fichier `.dockerignore` évite d'envoyer des centaines de Mo inutiles ou des données sensibles dans le contexte de build :

```ini
# .dockerignore
.git
.gitignore
node_modules
dist
build
.env*
*.md
Dockerfile*
tests
.coverage
```

- **Accélère l'envoi du contexte** au démon Docker (de 500 Mo à 2 Mo).
- **Évite de fuiter des secrets** locaux (`.env`, clés SSH, certificats).

### Nettoyage des Couches APT dans un Unique `RUN`

```dockerfile
# Mauvaise pratique (3 couches, paquets temporaires conservés dans l'historique) :
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# Bonne pratique (1 seule couche propre et nettoyée) :
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*
```

### Quizz : Optimisation d'Images

**Pourquoi copie-t-on le fichier `package.json` ou `requirements.txt` AVANT le reste du code source ?**

[(X)] Pour profiter du cache Docker lors de l'installation des dépendances et éviter de tout retélécharger à chaque modification de code
[( )] Parce que le Dockerfile refuse de compiler dans un autre ordre
[( )] Pour crypter le mot de passe de la base de données
[( )] Pour réduire la consommation mémoire du conteneur
