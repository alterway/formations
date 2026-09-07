# DOCKER : Maîtrise du Dockerfile {-}

### Anatomie d'un Dockerfile Moderne

Le **Dockerfile** est le manifeste déclaratif automatisant la fabrication d'une image Docker :

```dockerfile
# 1. Image de base officielle et épurée
FROM node:20-alpine

# 2. Définition du répertoire de travail (créé automatiquement)
WORKDIR /app

# 3. Variables d'environnement d'exécution
ENV NODE_ENV=production
ENV PORT=3000

# 4. Copie des descripteurs de dépendances en premier (Optimisation Cache)
COPY package*.json ./

# 5. Installation des dépendances de production
RUN npm ci --only=production && npm cache clean --force

# 6. Copie du reste du code source applicatif
COPY . .

# 7. Création et bascule sur un utilisateur non-root (Sécurité)
USER node

# 8. Documentation du port d'écoute
EXPOSE 3000

# 9. Sonde de santé intégrée au conteneur
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# 10. Commande d'exécution sous forme Exec
CMD ["node", "server.js"]
```

### Le Guide des Instructions Fondamentales

```{.center}
┌────────────┬─────────────────────────────────────────────────────────────┐
│ INSTRUCTION│ RÔLE ET CAS D'USAGE RECOMMANDÉ                              │
├────────────┼─────────────────────────────────────────────────────────────┤
│ `FROM`     │ Initialise le build et sélectionne l'image de départ        │
│ `WORKDIR`  │ Définit le dossier d'exécution (évite les `cd /chemin &&`)  │
│ `COPY`     │ Copie des fichiers/dossiers locaux vers le conteneur        │
│ `ADD`      │ Comme COPY + extraction automatique de `.tar.gz` ou URLs    │
│ `RUN`      │ Exécute une commande pendant le build et crée une couche    │
│ `ENV`      │ Définit des variables d'environnement persistantes à l'exec │
│ `ARG`      │ Définit des variables temporaires utilisables au build seul │
│ `EXPOSE`   │ Documente les ports d'écoute (informatif, n'ouvre pas l'IP) │
│ `USER`     │ Définit l'UID/GID exécutant les commandes (évite root)      │
└────────────┴─────────────────────────────────────────────────────────────┘
```

### Le Duel Crucial : `ENTRYPOINT` vs `CMD`

```{.center}
┌──────────────────────────────┬─────────────────────────────────────────────────┐
│ `CMD`                        │ Définit la commande ou les arguments par défaut.│
│                              │ Facilement SURCHARGÉ par `docker run <cmd>`.    │
├──────────────────────────────┼─────────────────────────────────────────────────┤
│ `ENTRYPOINT`                 │ Définit le binaire fixe et immuable du conteneur│
│                              │ Transforme le conteneur en exécutable CLI.      │
├──────────────────────────────┼─────────────────────────────────────────────────┤
│ `ENTRYPOINT` + `CMD` combinés│ ENTRYPOINT fixe le binaire, CMD fournit         │
│                              │ les arguments par défaut (surchargeables).      │
└──────────────────────────────┴─────────────────────────────────────────────────┘
```

```dockerfile
# Exemple de synergie puissante :
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

- Si exécuté avec `docker run my-nginx` $\rightarrow$ lance `nginx -g "daemon off;"`
- Si exécuté avec `docker run my-nginx -v` $\rightarrow$ lance `nginx -v` (version)

### Forme Exec vs Forme Shell : Attention aux Signaux !

```{.center}
┌──────────────────────────────────────┬──────────────────────────────────────┐
│ FORME EXEC (Recommandée)             │ FORME SHELL (À éviter)               │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ `CMD ["node", "app.js"]`             │ `CMD node app.js`                    │
│                                      │                                      │
│ - Lance le binaire directement.      │ - Lance en réalité `/bin/sh -c ...`. │
│ - `node` prend le PID 1.             │ - Le shell prend le PID 1.           │
│ - Reçoit directement les SIGTERM.    │ - Les SIGTERM ne sont pas transmis   │
│ - Arrêt propre et instantané.        │   à l'application (arrêt forcé 10s). │
└──────────────────────────────────────┴──────────────────────────────────────┘
```

### Variables de Build (`ARG`) vs Variables d'Environnement (`ENV`)

```{.center}
                    ARG (Build Time)             ENV (Runtime)
┌───────────────────────────────────────┬───────────────────────────────────────┐
│ Accessible pendant `docker build`     │ Présente dans le conteneur en cours   │
│ Ne subsiste PAS dans l'image finale   │ Accessible par `process.env` / `$VAR` │
│ Ex: version d'un paquet, token build  │ Ex: `NODE_ENV=production`, `PORT=80`  │
└───────────────────────────────────────┴───────────────────────────────────────┘
```

```dockerfile
# Déclaration :
ARG APP_VERSION=1.0.0
ENV ENVIRONMENT=production

# Passage lors du build :
# docker build --build-arg APP_VERSION=2.0.0 -t my-app .
```

### La Sonde de Santé Native : `HEALTHCHECK`

Permet à Docker de surveiller si l'application répond réellement (et pas seulement si le processus est vivant) :

```dockerfile
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/api/health || exit 1
```

- Statuts observables via `docker ps` :
  - `(health: starting)` : Période d'initialisation.
  - `(healthy)` : Sonde validée (code retour 0).
  - `(unhealthy)` : Échecs répétés $\rightarrow$ alertes et redémarrage possible via orchestrateur.

### Quizz : Dockerfile

**Pourquoi faut-il toujours privilégier la syntaxe sous forme de tableau JSON `["executable", "param"]` pour ENTRYPOINT et CMD ?**

[(X)] Pour exécuter directement le processus applicatif en PID 1 et lui permettre de recevoir correctement le signal d'arrêt propre SIGTERM
[( )] Parce que JSON est plus joli
[( )] Pour empêcher le conteneur d'accéder au réseau
[( )] Parce que Docker refuse de compiler la forme shell
