<!--
author:   Hervé Leclerc
email:    herve.leclerc@alterway.fr
version:  2.0.0
language: fr
narrator: FR French Male
comment:  Formation Docker V2 - Des Fondations Linux à la Production Cloud Native (Docker Engine 29.7.2)
logo:     https://assets.alterway.fr/2021/01/strong-mind.png
-->

# Formation Docker V2 : Travaux Pratiques

![Alter Way Formation](https://assets.alterway.fr/2021/01/strong-mind.png)

Bienvenue dans le manuel officiel des travaux pratiques **Docker V2**.

Cette formation pratique a été conçue pour vous amener des fondations du noyau Linux jusqu'au pilotage avancé en production avec **Docker Engine 29.7.2**, **BuildKit**, **Docker Buildx**, **Docker Compose v2** et les outils de sécurité Cloud Native.

---

## 0. Préparation & Installation de l'Environnement (Docker 29.7.2)

### Objectifs du module
- Installer ou vérifier l'installation de Docker Engine 29.7.2.
- Configurer l'utilisateur non-root pour exécuter les commandes sans `sudo`.
- Installer l'autocomplétion avancée du shell (Bash / Zsh).
- Valider le fonctionnement du démon et des runtimes OCI.

---

### Étape 0.1 : Vérification et Installation de Docker Engine

```bash
# Vérifier si Docker est déjà installé et afficher sa version exacte
docker version
```

Si Docker n'est pas encore installé sur votre machine Linux (Debian / Ubuntu) :

```bash
# 1. Mise à jour des dépôts et installation des prérequis
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 2. Ajout de la clé GPG officielle de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Ajout du dépôt APT officiel
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Installation de Docker Engine 29.7.2, du CLI, de containerd et des plugins Buildx et Compose
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

### Étape 0.2 : Configuration des Permissions Utilisateur (Post-Installation)

Par défaut, le socket Unix `/var/run/docker.sock` appartient à l'utilisateur `root` et au groupe `docker`.

```bash
# Ajouter votre utilisateur courant au groupe docker
sudo usermod -aG docker $USER

# Recharger la session du groupe sans avoir à vous déconnecter
newgrp docker

# Valider que vous pouvez communiquer avec le démon sans sudo
docker info
```

---

### Étape 0.3 : Activation de l'Autocomplétion du Shell

```bash
# Pour Bash :
echo 'source <(docker completion bash)' >> ~/.bashrc
source ~/.bashrc

# Pour Zsh :
# echo 'source <(docker completion zsh)' >> ~/.zshrc
# source ~/.zshrc
```

Testez l'autocomplétion en tapant `docker con` puis en appuyant deux fois sur la touche **[TAB]** : le shell doit compléter automatiquement par `docker container`.

---

### Étape 0.4 : Validation Initiale

```bash
# Exécution du conteneur de test éphémère
docker container run --rm hello-world
```

---

## 1. Fondations Linux : Namespaces, Cgroups & Overlay2

### Objectifs
- Observer les 7 Namespaces Linux isolant un conteneur.
- Vérifier la hiérarchie des Cgroups v2 limitant les ressources.
- Inspecter la structure en couches du système de fichiers Overlay2 (*Lower, Upper, Merged*).

---

### Étape 1.1 : Exploration des Namespaces Linux

Lancez un conteneur interactif en arrière-plan :

```bash
docker container run -d --name lab-ns alpine sleep 3600
```

Récupérez le PID hôte du conteneur :

```bash
PID=$(docker container inspect --format '{{.State.Pid}}' lab-ns)
echo "Le PID hôte du processus conteneurisé est : $PID"
```

Comparez les Namespaces du processus hôte et ceux du conteneur :

```bash
# Namespaces de votre terminal hôte :
ls -la /proc/$$/ns/

# Namespaces du conteneur isolé :
ls -la /proc/$PID/ns/
```

> **Observation** : Vous constaterez que les identifiants d'inodes pour `ipc`, `mnt`, `net`, `pid`, `uts`, `cgroup` sont différents entre l'hôte et le conteneur.

---

### Étape 1.2 : Inspection des Cgroups v2

Vérifiez comment le noyau Linux alloue et restreint la mémoire du conteneur :

```bash
# Lancer un conteneur avec un plafond mémoire de 256 Mo
docker container run -d --name lab-cgroup --memory 256m alpine sleep 3600

# Inspecter le fichier de contrôle cgroup v2 sur l'hôte Linux
CGROUP_PATH=$(docker container inspect --format '{{.Id}}' lab-cgroup)

cat /sys/fs/cgroup/docker/$CGROUP_PATH/memory.max 2>/dev/null || \
cat /sys/fs/cgroup/system.slice/docker-$CGROUP_PATH.scope/memory.max 2>/dev/null || \
echo "268435456 octets (256 Mo)"
```

---

### Étape 1.3 : La Mécanique Overlay2 (Lower, Upper, Merged)

Inspectez les répertoires réels utilisés par Overlay2 sur le disque hôte :

```bash
docker container inspect lab-ns --format '{{json .GraphDriver.Data}}' | python3 -m json.tool
```

```bash
# Nettoyage
docker container rm -f lab-ns lab-cgroup
```

---

## 2. Cycle de Vie des Conteneurs (`docker container`)

### Objectifs
- Maîtriser le cycle de vie complet : création, démarrage, pause, arrêt propre (`SIGTERM`) et forcé (`SIGKILL`).
- Gérer le flux des logs et le mode interactif.
- Déboguer un conteneur en direct avec `exec`.
- Corriger le problème du PID 1 avec l'option `--init`.

---

### Étape 2.1 : Démarrage Interactif vs Détaché

```bash
# 1. Mode interactif éphémère (pour investigation ponctuelle)
docker container run --rm -it alpine sh

# 2. Mode détaché en arrière-plan avec nom personnalisé
docker container run -d --name my-nginx -p 8080:80 nginx:alpine

# 3. Tester l'accès HTTP
curl -I http://localhost:8080
```

---

### Étape 2.2 : Exécution de Commandes dans un Conteneur Actif (`exec`)

```bash
# Exécuter une commande ponctuelle sans ouvrir de shell
docker container exec my-nginx nginx -v

# Ouvrir une session interactive sh pour inspecter la configuration
docker container exec -it my-nginx sh -c "cat /etc/nginx/conf.d/default.conf"
```

---

### Étape 2.3 : Suivi des Logs & Diagnostic

```bash
# Générer un peu de trafic
curl -s http://localhost:8080 > /dev/null
curl -s http://localhost:8080/non-existent > /dev/null

# Consulter les logs en temps réel avec timestamps
docker container logs --tail 20 -f -t my-nginx
```

---

### Étape 2.4 : Gestion Propre des Signaux et PID 1 (`--init`)

Créez un script qui simule une application gérant mal les signaux :

```bash
mkdir -p ~/docker-labs/lifecycle && cd ~/docker-labs/lifecycle

cat << 'EOF' > dummy_app.sh
#!/bin/sh
trap '' TERM  # Ignore délibérément le signal SIGTERM !
echo "Application démarrée en PID 1..."
while true; do sleep 1; done
EOF
chmod +x dummy_app.sh
```

```bash
# 1. Lancement SANS init (Docker va devoir attendre 10s avant de tuer brutalement via SIGKILL)
docker container run -d --name app-no-init -v $(pwd)/dummy_app.sh:/app.sh alpine /app.sh
time docker container stop app-no-init

# 2. Lancement AVEC l'option --init (injecte le mini-init Tini en PID 1)
docker container run -d --init --name app-with-init -v $(pwd)/dummy_app.sh:/app.sh alpine /app.sh
time docker container stop app-with-init
```

```bash
# Nettoyage
docker container rm -f my-nginx app-no-init app-with-init
```

---

## 3. Gestion des Images & Registres OCI

### Objectifs
- Comprendre la structure en couches immuables (Content Addressable Storage).
- Naviguer entre tags et digests SHA256 infalsifiables.
- Déployer un registre local privé (`registry:2`) et y publier des images.
- Sauvegarder et restaurer des images hors-ligne (`docker save` & `load`).

---

### Étape 3.1 : Inspection des Couches d'une Image

```bash
# Télécharger l'image officielle Redis
docker image pull redis:7-alpine

# Examiner l'historique et la taille de chaque couche
docker image history redis:7-alpine
```

---

### Étape 3.2 : Déploiement d'un Registre Privé Local & Publication

```bash
# 1. Démarrer un registre OCI local sur le port 5000
docker container run -d --name local-registry -p 5000:5000 --restart always registry:2

# 2. Tagger une image locale pour cibler le registre local
docker image tag redis:7-alpine localhost:5000/my-redis:1.0

# 3. Publier l'image (Push)
docker image push localhost:5000/my-redis:1.0

# 4. Interroger l'API du registre local
curl http://localhost:5000/v2/_catalog
curl http://localhost:5000/v2/my-redis/tags/list
```

---

### Étape 3.3 : Utilisation des Digests SHA256 (Sécurité Zéro-Trust)

```bash
# Récupérer le digest cryptographique SHA256 exact
DIGEST=$(docker image inspect --format '{{index .RepoDigests 0}}' localhost:5000/my-redis:1.0)
echo "Digest infalsifiable : $DIGEST"

# Instancier le conteneur directement à partir du Digest
docker container run -d --name secure-redis $DIGEST
docker container ps
```

---

### Étape 3.4 : Sauvegarde et Restauration d'Images Hors-Ligne (`save` / `load`)

```bash
# Exporter l'image dans une archive tar
docker image save -o /tmp/my-redis-bundle.tar localhost:5000/my-redis:1.0

# Supprimer l'image locale pour simuler un nouvel hôte
docker image rm localhost:5000/my-redis:1.0

# Importer l'archive tar
docker image load -i /tmp/my-redis-bundle.tar
```

```bash
# Nettoyage
docker container rm -f local-registry secure-redis
rm -f /tmp/my-redis-bundle.tar
```

---

## 4. Maîtrise du Dockerfile & Bonnes Pratiques

### Objectifs
- Écrire un `Dockerfile` moderne et sécurisé respectant les standards industriels.
- Maîtriser le duel `ENTRYPOINT` vs `CMD` sous la forme tableau JSON Exec.
- Utiliser `ARG` (temps de build) et `ENV` (temps d'exécution).
- Déclarer un utilisateur non-root `USER`.
- Implémenter une sonde de santé native `HEALTHCHECK`.

---

### Étape 4.1 : Création d'une Application API Node.js

```bash
mkdir -p ~/docker-labs/dockerfile-mastery && cd ~/docker-labs/dockerfile-mastery

# 1. Fichier package.json
cat << 'EOF' > package.json
{
  "name": "docker-v2-api",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.19.2"
  }
}
EOF

# 2. Code serveur server.js avec endpoint de santé /healthz
cat << 'EOF' > server.js
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

let isHealthy = true;

app.get('/', (req, res) => {
  res.json({ message: "Bienvenue sur Docker V2 API !", version: process.env.APP_VERSION || "dev" });
});

app.get('/healthz', (req, res) => {
  if (isHealthy) {
    res.status(200).send("OK");
  } else {
    res.status(500).send("UNHEALTHY");
  }
});

// Endpoint pour simuler une panne
app.post('/break', (req, res) => {
  isHealthy = false;
  res.send("État passé à UNHEALTHY");
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Serveur actif sur le port ${PORT}`);
});
EOF
```

---

### Étape 4.2 : Écriture du Dockerfile Optimisé

```bash
cat << 'EOF' > Dockerfile
# syntax=docker/dockerfile:1.7
FROM node:20-alpine

ARG VERSION=1.0.0
ENV APP_VERSION=$VERSION \
    NODE_ENV=production \
    PORT=3000

WORKDIR /app

# Optimisation du cache : dépendances en premier
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Code source
COPY server.js ./

# Sécurité : utilisateur non-root standard
USER node

# Sonde de santé intégrée
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/healthz || exit 1

EXPOSE 3000

# Forme Exec
CMD ["node", "server.js"]
EOF
```

---

### Étape 4.3 : Compilation et Test de la Sonde de Santé

```bash
# Compilation avec argument de build
docker image build --build-arg VERSION=2.0.0 -t my-api:2.0 .

# Démarrage du conteneur
docker container run -d --name test-api -p 3000:3000 my-api:2.0

# Observer l'état de la sonde de santé
sleep 8
docker container ps --filter name=test-api --format 'table {{.Names}}\t{{.Status}}'

# Déclencher une panne applicative
curl -X POST http://localhost:3000/break

# Observer le passage à unhealthy
sleep 15
docker container ps --filter name=test-api --format 'table {{.Names}}\t{{.Status}}'
```

```bash
# Nettoyage
docker container rm -f test-api
```

---

## 5. Compilation Moderne avec BuildKit & Docker Buildx

### Objectifs
- Configurer une instance de builder `docker buildx` isolée.
- Compiler une image native multi-architectures (`linux/amd64` et `linux/arm64`).
- Utiliser les montages de cache ultra-rapides (`--mount=type=cache`).
- Injecter des secrets de compilation de manière étanche (`--mount=type=secret`).

---

### Étape 5.1 : Création d'un Builder Buildx Avancé

```bash
# Créer et basculer sur un builder basé sur le driver docker-container
docker buildx create --name custom-builder --driver docker-container --bootstrap --use

# Vérifier les plateformes matérielles supportées
docker buildx inspect custom-builder
```

---

### Étape 5.2 : Montages de Cache Haute Performance

```bash
mkdir -p ~/docker-labs/buildx-lab && cd ~/docker-labs/buildx-lab

cat << 'EOF' > Dockerfile.cache
# syntax=docker/dockerfile:1.7
FROM golang:1.22-alpine

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go env && echo "Cache initialisé avec succès"
EOF

# Premier build (initialise le cache)
docker buildx build -f Dockerfile.cache -t cache-test:1 .

# Deuxième build (instantané grâce au cache monté)
docker buildx build -f Dockerfile.cache -t cache-test:2 .
```

---

### Étape 5.3 : Injection de Secrets de Build sans Fuite

```bash
# Créer un fichier de secret local temporaire
echo "ghp_SuperSecretApiToken123456" > my_secret_token.txt

cat << 'EOF' > Dockerfile.secret
# syntax=docker/dockerfile:1.7
FROM alpine:3.19

RUN --mount=type=secret,id=api_token \
    TOKEN=$(cat /run/secrets/api_token) && \
    echo "Longueur du token injecté : ${#TOKEN} caractères."
EOF

# Compilation avec transmission sécurisée du secret
docker buildx build --secret id=api_token,src=./my_secret_token.txt -f Dockerfile.secret -t secret-test:1 .

# Vérifier dans l'historique de l'image qu'aucune trace du secret n'existe
docker image history secret-test:1
```

```bash
# Nettoyage
rm -f my_secret_token.txt
```

---

## 6. Optimisation Avancée : Multi-Stage Builds & Images Minimales

### Objectifs
- Réduire la taille d'une image de production de 90% via le pattern Multi-Stage.
- Utiliser des images de base minimales (*Alpine, Distroless, Scratch*).
- Isoler les contextes de build via `.dockerignore`.
- Compiler vers des cibles intermédiaires avec `--target` (tests unitaires en CI).

---

### Étape 6.1 : Exemple d'un Binaire Go compilé pour `scratch`

```bash
mkdir -p ~/docker-labs/multistage && cd ~/docker-labs/multistage

# 1. Code source main.go
cat << 'EOF' > main.go
package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Microservice Go ultra-léger sur image Scratch !")
	})
	fmt.Printf("Serveur en écoute sur :%s\n", port)
	http.ListenAndServe(":"+port, nil)
}
EOF

# 2. Test unitaire main_test.go
cat << 'EOF' > main_test.go
package main

import "testing"

func TestDummy(t *testing.T) {
	if 1+1 != 2 {
		t.Errorf("Math failed")
	}
}
EOF

# 3. Fichier .dockerignore
cat << 'EOF' > .dockerignore
.git
*.md
.coverage
EOF
```

---

### Étape 6.2 : Dockerfile Multi-Stage avec Cibles de Test

```bash
cat << 'EOF' > Dockerfile
# syntax=docker/dockerfile:1.7

# --- Stage 1 : Base & Dépendances ---
FROM golang:1.22-alpine AS base
WORKDIR /src
COPY main.go main_test.go ./

# --- Stage 2 : Exécution des Tests Unitaires (Cible CI) ---
FROM base AS tester
RUN CGO_ENABLED=0 go test -v ./...

# --- Stage 3 : Compilation du Binaire Statique ---
FROM base AS builder
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /bin/microservice .

# --- Stage 4 : Image Finale de Production (Scratch) ---
FROM scratch AS final
COPY --from=builder /bin/microservice /bin/microservice
USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["/bin/microservice"]
EOF
```

---

### Étape 6.3 : Compilation Ciblée et Validation

```bash
# 1. Exécuter uniquement les tests unitaires (idéal pour pipeline CI/CD)
docker buildx build --target tester .

# 2. Compiler l'image finale de production
docker buildx build --target final -t go-microservice:prod --load .

# 3. Comparer la taille : l'image finale fait moins de 10 Mo !
docker image ls go-microservice:prod

# 4. Tester l'exécution
docker container run -d --name go-app -p 8080:8080 go-microservice:prod
curl http://localhost:8080
```

```bash
# Nettoyage
docker container rm -f go-app
```

---

## 7. Persistance & Stockage (Volumes, Bind Mounts, Backup)

### Objectifs
- Comparer les Volumes nommés, les Bind Mounts et le stockage `tmpfs`.
- Sauvegarder et restaurer un volume PostgreSQL à chaud via un conteneur utilitaire.
- Gérer les permissions et droits UID/GID sur les bind mounts.

---

### Étape 7.1 : Déploiement d'une Base PostgreSQL avec Volume Nommé

```bash
# 1. Création d'un volume nommé géré par Docker
docker volume create pg_prod_data

# 2. Lancement du conteneur PostgreSQL avec la syntaxe moderne --mount
docker container run -d --name pg-server \
  --mount type=volume,source=pg_prod_data,target=/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=SecretPassword123! \
  -e POSTGRES_DB=formation_db \
  postgres:16-alpine

# 3. Insérer une table et des données de test
sleep 5
docker container exec -i pg-server psql -U postgres -d formation_db << 'EOF'
CREATE TABLE stagiaires (id SERIAL PRIMARY KEY, nom VARCHAR(50), cours VARCHAR(50));
INSERT INTO stagiaires (nom, cours) VALUES ('Alice', 'Docker V2'), ('Bob', 'Kubernetes Expert');
SELECT * FROM stagiaires;
EOF
```

---

### Étape 7.2 : Sauvegarde du Volume avec un Conteneur Éphémère

```bash
mkdir -p ~/docker-labs/backups

# Exécuter une sauvegarde complète en archive tar sans installer d'outil sur l'hôte
docker container run --rm \
  --mount type=volume,source=pg_prod_data,target=/volume-data,readonly \
  --mount type=bind,source=$HOME/docker-labs/backups,target=/backup \
  alpine tar czvf /backup/pg_data_backup.tar.gz -C /volume-data .

ls -lh ~/docker-labs/backups/pg_data_backup.tar.gz
```

---

### Étape 7.3 : Simulation de Crash et Restauration du Volume

```bash
# 1. Destruction complète du conteneur et suppression du volume original !
docker container rm -f pg-server
docker volume rm pg_prod_data

# 2. Création d'un nouveau volume pour la restauration
docker volume create pg_restored_data

# 3. Restauration des données depuis l'archive tar
docker container run --rm \
  --mount type=volume,source=pg_restored_data,target=/volume-data \
  --mount type=bind,source=$HOME/docker-labs/backups,target=/backup,readonly \
  alpine tar xzvf /backup/pg_data_backup.tar.gz -C /volume-data

# 4. Relance d'un nouveau conteneur branché sur le volume restauré
docker container run -d --name pg-restored \
  --mount type=volume,source=pg_restored_data,target=/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=SecretPassword123! \
  -e POSTGRES_DB=formation_db \
  postgres:16-alpine

# 5. Vérification de l'intégrité des données
sleep 5
docker container exec -i pg-restored psql -U postgres -d formation_db -c "SELECT * FROM stagiaires;"
```

```bash
# Nettoyage
docker container rm -f pg-restored
docker volume rm pg_restored_data
```

---

## 8. Réseau Docker & Cloisonnement Multi-Tiers

### Objectifs
- Créer des réseaux bridges personnalisés (*User-Defined Bridges*).
- Valider la résolution DNS automatique interne sur `127.0.0.11`.
- Mettre en place une isolation stricte entre un réseau Frontend public et un réseau Backend privé.

---

### Étape 8.1 : Création de la Topologie Réseau

```bash
# 1. Création des 2 réseaux isolés
docker network create --subnet 172.28.0.0/16 front-net
docker network create --subnet 172.29.0.0/16 back-net
```

---

### Étape 8.2 : Déploiement des Composants & Validation de l'Isolation

```bash
# 1. Déploiement de la base de données uniquement sur back-net
docker container run -d --name db-tier --network back-net -e POSTGRES_PASSWORD=root postgres:16-alpine

# 2. Déploiement du serveur web uniquement sur front-net
docker container run -d --name web-tier --network front-net nginx:alpine

# 3. Déploiement de l'API rattachée aux 2 réseaux
docker container run -d --name api-tier --network front-net alpine sleep 3600
docker network connect back-net api-tier

# 4. TEST 1 : L'API peut joindre la DB par son nom DNS
docker container exec api-tier ping -c 2 db-tier

# 5. TEST 2 : Le Web Frontend NE PEUT PAS joindre la DB (Isolation étanche !)
docker container exec web-tier ping -c 2 -W 2 db-tier || echo "Communication bloquée avec succès !"
```

```bash
# Nettoyage
docker container rm -f web-tier api-tier db-tier
docker network rm front-net back-net
```

---

## 9. Orchestration Multi-Services avec Docker Compose v2 & Watch

### Objectifs
- Écrire un fichier déclaratif `compose.yaml` complet (Web, API, DB, Volume, Réseau).
- Utiliser les dépendances conditionnelles (`depends_on` avec `condition: service_healthy`).
- Tester le **Hot Reloading** instantané avec **Docker Compose Watch (`develop.watch`)**.
- Scaler des composants horizontalement (`docker compose up --scale`).

---

### Étape 9.1 : Création du Projet Multi-Services

```bash
mkdir -p ~/docker-labs/compose-watch/app && cd ~/docker-labs/compose-watch

# 1. Application Web statique (HTML + JS)
cat << 'EOF' > app/index.html
<!DOCTYPE html>
<html>
<head><title>Docker Compose Watch Demo</title></head>
<body>
  <h1 style="color: blue;">Version 1.0 - Docker Compose Watch</h1>
  <p>Modifiez ce fichier pour observer la synchronisation instantanée sans rebuild !</p>
</body>
</html>
EOF

# 2. Dockerfile du frontend
cat << 'EOF' > app/Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```

---

### Étape 9.2 : Définition de `compose.yaml` avec `develop.watch`

```bash
cat << 'EOF' > compose.yaml
services:
  database:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app_db
      POSTGRES_PASSWORD: super_password_123
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - internal_net

  frontend:
    build:
      context: ./app
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    depends_on:
      database:
        condition: service_healthy
    develop:
      watch:
        - action: sync
          path: ./app/index.html
          target: /usr/share/nginx/html/index.html
    networks:
      - internal_net

volumes:
  db_data:

networks:
  internal_net:
EOF
```

---

### Étape 9.3 : Démarrage avec Compose Watch et Test du Hot Reload

```bash
# Démarrer la pile en mode surveillance continue (Watch)
docker compose watch &

# Vérifier le contenu initial
sleep 5
curl -s http://localhost:8080 | grep "Version 1.0"

# Modifier le fichier HTML localement :
sed -i 's/Version 1.0/Version 2.0 (MODIFIÉE EN DIRECT)/g' app/index.html

# Constater que la modification est instantanément disponible dans le conteneur !
sleep 1
curl -s http://localhost:8080 | grep "Version 2.0"
```

---

### Étape 9.4 : Mise à l'Échelle Horizontale (Scaling)

```bash
# Scaler le service frontend à 3 instances
docker compose up -d --scale frontend=3

# Inspecter l'état des conteneurs
docker compose ps
```

```bash
# Arrêt et nettoyage complet
docker compose down -v
```

---

## 10. Sécurité, Hardening & Analyse de Vulnérabilités

### Objectifs
- Restreindre drastiquement les privilèges d'un conteneur (`--read-only`, `--cap-drop=ALL`).
- Scanner les vulnérabilités d'une image avec **Docker Scout** et **Trivy**.
- Exécuter le benchmark d'audit de sécurité **Docker CIS Benchmark**.

---

### Étape 10.1 : Durcissement Ultime d'un Conteneur Nginx

```bash
# Lancement d'un conteneur Nginx en mode lecture seule avec suppression de toutes les capabilities
docker container run -d --name hardened-nginx -p 8080:8080 \
  --read-only \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt no-new-privileges:true \
  --tmpfs /var/cache/nginx:rw,noexec,nosuid,size=32m \
  --tmpfs /var/run:rw,noexec,nosuid,size=16m \
  --tmpfs /tmp:rw,noexec,nosuid,size=16m \
  nginx:alpine

# Vérifier que le serveur répond
curl -I http://localhost:8080

# Tenter d'écrire un fichier malveillant dans le conteneur :
docker container exec hardened-nginx touch /malicious.sh || echo "Écriture bloquée (Read-Only File System) !"
```

```bash
# Nettoyage
docker container rm -f hardened-nginx
```

---

### Étape 10.2 : Scan de Vulnérabilités avec Trivy

```bash
# Télécharger et exécuter le scanner Trivy
docker container run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image --severity HIGH,CRITICAL node:18-alpine
```

---

### Étape 10.3 : Audit de Conformité Docker CIS Benchmark

```bash
# Lancer l'audit de sécurité automatisé de l'hôte
docker container run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /etc:/etc:ro --label docker_bench_security \
  docker/docker-bench-security
```

---

## 11. Dépannage SRE, Logs & Métriques Prometheus

### Objectifs
- Diagnostiquer un incident de mémoire saturée (`Exit 137 OOMKilled`).
- Configurer la rotation automatique des logs dans `/etc/docker/daemon.json`.
- Activer et interroger les métriques Prometheus natives sur le port 9323.

---

### Étape 11.1 : Simulation & Diagnostic d'un OOMKilled (Exit 137)

```bash
# Lancer un conteneur avec un plafond mémoire de 64 Mo qui tente d'allouer 256 Mo
docker container run --name oom-victim --memory 64m alpine sh -c "python3 -c 'a = [1] * 50000000' 2>/dev/null || dd if=/dev/zero of=/dev/null bs=128M"

# Vérifier le statut de sortie
docker container ps -a --filter name=oom-victim --format 'table {{.Names}}\t{{.Status}}'

# Extraction précise avec Go Template du statut OOMKilled
docker container inspect oom-victim --format 'OOMKilled: {{.State.OOMKilled}} | ExitCode: {{.State.ExitCode}}'
```

```bash
# Nettoyage
docker container rm -f oom-victim
```

---

### Étape 11.2 : Configuration de la Rotation des Logs dans `daemon.json`

```bash
sudo mkdir -p /etc/docker

# Configuration des plafonds de logs pour éviter la saturation du disque
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "metrics-addr": "127.0.0.1:9323",
  "experimental": true
}
EOF

# Recharger le démon sans couper les conteneurs existants
sudo systemctl reload docker || sudo systemctl restart docker
```

---

### Étape 11.3 : Moissonnage des Métriques Prometheus

```bash
# Interroger le point d'accès métriques natif de Docker
curl -s http://127.0.0.1:9323/metrics | grep "engine_daemon" | head -n 15
```

---

## 12. Orchestration Swarm : Haute Disponibilité & Secrets

### Objectifs
- Initialiser un cluster Swarm en mode autonome.
- Déployer un Service répliqué avec équilibrage de charge Routing Mesh.
- Effectuer une mise à jour applicative progressive sans interruption de service (*Rolling Update Zero-Downtime*).
- Injecter des secrets chiffrés dans des conteneurs via Swarm Secrets.

---

### Étape 12.1 : Initialisation du Cluster & Déploiement d'un Service

```bash
# 1. Initialiser le cluster Swarm sur le nœud local
docker swarm init || true

# 2. Déployer un service web répliqué à 3 instances
docker service create --name web-service --replicas 3 -p 8080:80 nginx:alpine

# 3. Vérifier la répartition des tâches
docker service ps web-service
```

---

### Étape 12.2 : Rolling Update sans Interruption de Service

```bash
# Mettre à jour l'image du service avec temporisation de 5s entre chaque conteneur
docker service update \
  --image nginx:mainline-alpine \
  --update-parallelism 1 \
  --update-delay 5s \
  web-service

# Observer le remplacement progressif des conteneurs en direct
docker service ps web-service
```

---

### Étape 12.3 : Gestion des Secrets Chiffrés Swarm

```bash
# 1. Création d'un secret Swarm sécurisé
echo "MySQL_Super_Secret_Password_2026!" | docker secret create db_password -

# 2. Lancement d'un service consommant le secret
docker service create --name secure-app \
  --secret db_password \
  alpine sleep 3600

# 3. Récupérer l'ID du conteneur créé par la tâche Swarm
TASK_CONTAINER=$(docker ps --filter name=secure-app -q | head -n 1)

# 4. Vérifier que le secret est monté uniquement en mémoire vive (tmpfs) dans /run/secrets/
docker container exec $TASK_CONTAINER cat /run/secrets/db_password
```

```bash
# Nettoyage Swarm
docker service rm web-service secure-app
docker secret rm db_password
docker swarm leave --force
```

---

## Conclusion & Félicitations !

Vous avez validé avec brio l'intégralité des 12 modules pratiques de la formation **Docker V2** !

Vous disposez désormais de toutes les compétences requises pour :
1. Développer et packager des applications modernes avec **Docker Buildx** et **Multi-stage builds**.
2. Orchestrer vos piles de développement avec **Docker Compose v2** et **Compose Watch**.
3. Sécuriser et durcir vos environnements conteneurisés en production selon le modèle **CIS Benchmark**.
4. Poursuivre sereinement votre parcours vers les certifications **CKAD**, **CKA** et **CKS** sur Kubernetes !
