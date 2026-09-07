# DOCKER : Orchestration Multi-Conteneurs avec Docker Compose v2 {-}

### Pourquoi Docker Compose ?

Lancer une architecture moderne (Frontend + API + Base de Données + Redis) avec la CLI `docker run` devient vite ingérable :
- Ordre de démarrage manuel des conteneurs.
- Commandes verbeuses avec des dizaines d'arguments `--network`, `-v`, `-p`, `-e`.
- Risque d'oubli ou d'incohérence entre les postes de l'équipe.

> **Docker Compose** permet de décrire l'intégralité d'une pile applicative multi-conteneurs dans un unique fichier déclaratif **`compose.yaml`** et de piloter son cycle de vie en **une seule commande**.

### La Spécification Compose v2 Moderne

Historiquement appelé `docker-compose` (en Python), Compose a été entièrement réécrit en Go et s'intègre nativement dans la CLI standard : **`docker compose`** (sans tiret).

```yaml
# compose.yaml (La clé 'version:' est désormais obsolète et facultative !)
services:
  frontend:
    build:
      context: ./frontend
      target: production
    ports:
      - "80:80"
    depends_on:
      api:
        condition: service_healthy
    networks:
      - app-net

  api:
    build: ./backend
    environment:
      - DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - REDIS_HOST=redis
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 3s
      retries: 3

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secret}
      POSTGRES_DB: ${DB_NAME:-appdb}
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks:
      - app-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres}"]
      interval: 5s
      timeout: 3s
      retries: 5

networks:
  app-net:
    driver: bridge

volumes:
  pgdata:
```

### Dépendances Conditionnelles Avancées (`depends_on`)

Compose permet de synchroniser le démarrage réel en fonction de la disponibilité applicative :

```{.center}
┌─────────────────────────────────┬─────────────────────────────────────────────────┐
│ CONDITION                       │ COMPORTEMENT DU DÉMARRAGE                      │
├─────────────────────────────────┼─────────────────────────────────────────────────┤
│ `service_started`               │ Attend que le conteneur soit démarré (basique)  │
│ `service_healthy`               │ Attend que le `HEALTHCHECK` passe au vert       │
│ `service_completed_successfully`│ Attend qu'un conteneur de migration/init termine│
└─────────────────────────────────┴─────────────────────────────────────────────────┘
```

### Gestion des Variables d'Environnement & Fichier `.env`

Compose charge automatiquement le fichier `.env` situé dans le même répertoire :

```ini
# .env
DB_USER=appuser
DB_PASSWORD=SuperSecr3tPassword!
DB_NAME=production_db
APP_PORT=8080
```

Dans `compose.yaml`, vous pouvez injecter avec des valeurs par défaut de secours :
`PORT: ${APP_PORT:-3000}`.

### Les Commandes Quotidiennes Compose v2

```bash
# 1. Démarrer toute l'infrastructure en arrière-plan (avec rebuild si nécessaire)
docker compose up -d --build

# 2. Inspecter l'état des services et sondes de santé
docker compose ps

# 3. Suivre les logs de tous les services ou d'un service spécifique
docker compose logs -f api

# 4. Exécuter une commande dans un service actif
docker compose exec db psql -U appuser -d appdb

# 5. Mettre à l'échelle un composant sans modifier le YAML
docker compose up -d --scale api=3

# 6. Stopper et détruire les conteneurs et réseaux (ajouter -v pour purger les volumes)
docker compose down -v
```

### La Nouveauté Phare : Compose Watch (`develop.watch`)

Compose v2 intègre le synchronisme automatique de fichiers à chaud en cours de développement (*Hot Reload*) :

```yaml
services:
  web:
    build: .
    develop:
      watch:
        # Synchronise le code HTML/JS instantanément sans redémarrer le conteneur
        - action: sync
          path: ./src
          target: /app/src
        # Reconstruit l'image et redémarre si package.json est modifié
        - action: rebuild
          path: ./package.json
```

```bash
# Lancer Compose en mode surveillance continue :
docker compose watch
```

### Quizz : Docker Compose

**Quelle est la différence fondamentale entre `docker compose stop` et `docker compose down` ?**

[(X)] `stop` arrête simplement les conteneurs sans les détruire ; `down` supprime les conteneurs, les réseaux virtuels et les liens créés
[( )] `stop` supprime les volumes du disque dur
[( )] `down` réinstalle le système d'exploitation
[( )] Aucune, ce sont deux alias strictement identiques
