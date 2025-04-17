<!--
author:   Hervé Leclerc

email:    herve.leclerc@alterway.fr

version:  1.0.0

language: en

narrator: US English Male

comment:  Cours Docker Fundamentals (Slide)

logo: https://assets.alterway.fr/2021/01/strong-mind.png

-->
# **Présentation : Les Fondamentaux de Docker**

Une introduction par la pratique

---

## **Agenda**

1.  Installation
2.  Cycle de Vie des Conteneurs
3.  Création d'Images Docker (Dockerfile)
4.  Gestion des Images (Tags, Registres)
5.  Gestion du Logging
6.  Gestion du Réseau
7.  Orchestration Simple avec Docker Compose
8.  Gestion des Données (Volumes, Bind Mounts)
9.  Exemple Complet : Application de Vote
10. Bonnes Pratiques
11. Conclusion & Prochaines Étapes

---

## **Chapitre 1 : Installation**

### Concepts Clés

*   **Docker :** Plateforme pour construire, déployer et exécuter des applications dans des conteneurs.
*   **Conteneurisation :** Empaqueter une application avec ses dépendances dans une unité isolée.
    *   Légèreté (partage du noyau hôte) vs VMs.
    *   Isolation & Portabilité.
*   **Docker Engine (Linux) :** Le moteur principal (démon `dockerd`, API, CLI `docker`).
*   **Docker Desktop (Win/Mac) :** Application incluant Engine, CLI, Compose, GUI, Kubernetes (optionnel). Utilise WSL2/Hyper-V (Win) ou la virtualisation macOS.

### Commandes Essentielles

*   `docker --version` : Vérifier la version du client/serveur.
*   `docker info` : Informations détaillées sur l'installation.
*   `docker run hello-world` : Le test ultime pour valider l'installation.

### À Retenir

*   Installer Docker selon votre OS.
*   Vérifier que le démon tourne et que `hello-world` fonctionne.

---

## **Chapitre 2 : Cycle de Vie des Conteneurs**

### Concepts Clés

*   **Image vs Conteneur :**
    *   **Image :** Modèle immuable (template, blueprint). En lecture seule.
    *   **Conteneur :** Instance exécutable d'une image. Avec une couche d'écriture. État propre.
*   **États du Cycle de Vie :**
    *   Created -> Running -> Paused / Stopped -> Deleted.
    *   [Diagramme : Cycle de Vie]

### Commandes Essentielles

*   `docker run <image> [cmd]` : Crée ET démarre un conteneur.
    *   Options clés : `-d` (détaché), `-p hôte:conteneur` (port), `--name nom` (nommer), `--rm` (supprimer à la fin).
*   `docker ps` : Lister les conteneurs **en cours**.
*   `docker ps -a` : Lister **tous** les conteneurs (même arrêtés).
*   `docker stop <conteneur>` : Arrêter un conteneur (envoi SIGTERM, puis SIGKILL).
*   `docker start <conteneur>` : Démarrer un conteneur arrêté.
*   `docker restart <conteneur>` : Redémarrer (stop puis start).
*   `docker logs [-f] <conteneur>` : Voir les logs (stdout/stderr). `-f` pour suivre.
*   `docker exec [-it] <conteneur> <cmd>` : Exécuter une commande dans un conteneur **en cours**. `-it` pour un shell interactif (`bash`, `sh`).
*   `docker rm <conteneur>` : Supprimer un conteneur **arrêté**.
*   `docker container prune` : Supprimer tous les conteneurs arrêtés.
*   `docker inspect <conteneur>` : Obtenir des détails complets (JSON).

### À Retenir

*   Différencier image et conteneur.
*   Maîtriser les commandes pour gérer les conteneurs du démarrage à la suppression.

---

## **Chapitre 3 : Création d'Images Docker**

### Concepts Clés

*   **Pourquoi créer ses images ?** Empaqueter SON application, ses dépendances, sa configuration.
*   **Méthodes :**
    *   **`Dockerfile` (Recommandé) :** Fichier texte décrivant les étapes de construction. Reproductible, versionnable, transparent.
    *   `docker commit` (Déconseillé) : Créer une image depuis un conteneur modifié. Opaque, non reproductible.
    *   `docker load` : Charger une image depuis une archive `.tar`.
*   **Dockerfile Instructions Clés :**
    *   `FROM` : Image de base (obligatoire).
    *   `RUN` : Exécuter des commandes pendant le build (installe paquets...). Crée une couche.
    *   `COPY` / `ADD` : Copier des fichiers depuis le contexte vers l'image. `COPY` préféré.
    *   `WORKDIR` : Changer le répertoire de travail pour les instructions suivantes.
    *   `EXPOSE` : Documenter le port d'écoute (ne publie pas !).
    *   `CMD` / `ENTRYPOINT` : Définir la commande par défaut à l'exécution. (`CMD` facile à surcharger, `ENTRYPOINT` pour un "exécutable").
    *   `ENV` : Définir des variables d'environnement.
    *   `USER` : Exécuter en tant qu'utilisateur non-root (sécurité).
    *   `ARG` : Variable de build uniquement.
*   **Contexte de Build :** Dossier envoyé au démon Docker. Utiliser `.dockerignore`.
*   **Couches & Cache :** Chaque instruction (RUN, COPY...) crée une couche. Docker met en cache les couches. Optimiser l'ordre des instructions.
*   **Builds Multi-Étapes :** Séparer build et runtime pour des images finales légères et sécurisées.

### Commandes Essentielles

*   `docker build -t <nom>:<tag> <chemin_contexte>` : Construire une image depuis un Dockerfile.

### À Retenir

*   Le `Dockerfile` est la méthode standard pour créer des images.
*   Optimiser la taille (base, multi-stage, `RUN` groupés) et le cache (ordre).

---

## **Chapitre 4 : Gestion des Images**

### Concepts Clés

*   **Nommage :** `[registry/][user/]<repository>:<tag>`
    *   `tag`: Version (ex: `1.2.3`, `slim`). Éviter `:latest` en prod !
    *   `repository`: Nom de l'image (ex: `nginx`, `mon-app`).
    *   `user/registry`: Espace de nom (Docker Hub ou registre privé).
*   **Registres Docker :** Système de stockage et distribution d'images.
    *   **Docker Hub :** Registre public par défaut. Images officielles et communautaires.
    *   **Registres Cloud :** ECR (AWS), GCR/Artifact Registry (GCP), ACR (Azure)...
    *   **Registres Privés :** Harbor, Nexus, Docker Registry...
*   **Flux :** `build` -> `tag` -> `login` -> `push` (partager) | `pull` (utiliser)

### Commandes Essentielles

*   `docker images` / `docker image ls` : Lister les images locales.
*   `docker tag <image_source> <image_cible>` : Ajouter un alias/tag à une image existante (même ID). Nécessaire avant `push`.
*   `docker pull <image>:<tag>` : Télécharger une image depuis un registre.
*   `docker login [registry]` : S'authentifier auprès d'un registre.
*   `docker push <image>:<tag>` : Envoyer une image locale vers un registre.
*   `docker rmi <image>:<tag>` : Supprimer une image locale (ou un tag). Attention aux images utilisées par des conteneurs.
*   `docker image prune [-a]` : Supprimer les images dangling (sans tag) ou [-a] non utilisées.
*   `docker search <terme>` : Rechercher des images sur Docker Hub (interface web souvent mieux).

### À Retenir

*   Utiliser des tags explicites.
*   Tagger correctement avant de pousser vers le bon registre/utilisateur.
*   Nettoyer les images non utilisées.

---

## **Chapitre 5 : Gestion du Logging**

### Concepts Clés

*   **Importance :** Débogage, Monitoring, Audit.
*   **Mécanisme Docker :** Capture `stdout` / `stderr` du processus principal (PID 1).
*   **Logging Drivers :** Détermine où les logs sont envoyés.
    *   `json-file` (Défaut) : Fichiers JSON sur l'hôte. Utilisé par `docker logs`. **Gérer la rotation !** (`max-size`, `max-file`).
    *   `local` : Format interne optimisé.
    *   `journald`, `syslog` : Intégration systèmes Linux.
    *   `fluentd`, `gelf`, `awslogs`, `gcplogs`... : **Pour la centralisation des logs** (indispensable en production).
    *   `none` : Désactive les logs.
*   **Configuration :** Au niveau du démon (`/etc/docker/daemon.json` ou Docker Desktop settings) ou par conteneur (`--log-driver`, `--log-opt`).

### Commandes Essentielles

*   `docker logs <conteneur>` : Afficher les logs capturés.
    *   Options : `-f` (suivre), `--tail N` (N dernières lignes), `--since TIME` (depuis), `-t` (timestamps Docker).

### À Retenir

*   Les applications doivent logger sur `stdout`/`stderr`.
*   `docker logs` est utile pour le débogage local.
*   Configurer la rotation pour `json-file`.
*   Utiliser des drivers adaptés pour la centralisation en production.

---

## **Chapitre 6 : Gestion du Réseau**

### Concepts Clés

*   **Pourquoi :** Communication inter-conteneurs et avec l'extérieur.
*   **Network Drivers :**
    *   `bridge` : Réseau privé sur l'hôte (défaut). Isole. Nécessite `-p` pour accès externe.
    *   `host` : Partage l'interface réseau de l'hôte. Pas d'isolation. Risque de conflits.
    *   `overlay` : Réseau multi-hôtes (Swarm, Kubernetes).
    *   `macvlan` : Adresse MAC/IP propre sur le réseau local.
    *   `none` : Pas de réseau (sauf loopback).
*   **Réseau `bridge` par défaut vs Défini par l'utilisateur :**
    *   **Défaut :** Pas de résolution DNS par nom de conteneur.
    *   **Utilisateur (`docker network create`) :** **Fortement recommandé.** Fournit une **résolution DNS automatique** entre les conteneurs par leur nom/alias de service. Meilleure isolation.
*   **Publication de Ports :** `docker run -p <port_hôte>:<port_conteneur>` ou `docker run -p <ip_hôte>:<port_hôte>:<port_conteneur>`.

### Commandes Essentielles

*   `docker network ls` : Lister les réseaux.
*   `docker network create <nom_reseau>` : Créer un réseau (bridge par défaut).
*   `docker network inspect <nom_reseau>` : Voir les détails (subnet, conteneurs connectés...).
*   `docker network rm <nom_reseau>` : Supprimer un réseau (doit être inutilisé).
*   `docker network connect <reseau> <conteneur>` : Connecter un conteneur en cours à un réseau.
*   `docker network disconnect <reseau> <conteneur>` : Déconnecter.
*   `docker network prune` : Supprimer les réseaux non utilisés.

### À Retenir

*   Utiliser des réseaux `bridge` **définis par l'utilisateur** pour la communication entre conteneurs.
*   Profiter de la résolution DNS par nom de service.
*   Publier les ports nécessaires pour l'accès externe.

---

## **Chapitre 7 : Orchestration Simple avec Docker Compose**

### Concepts Clés

*   **Pourquoi :** Définir et gérer des applications multi-conteneurs facilement. Évite les longues commandes `docker run`.
*   **Fichier `docker-compose.yml` :** Format YAML décrivant l'application.
    *   `version`: Version du schéma Compose.
    *   `services`: Définit les conteneurs (frontend, backend, db...). Le nom du service est utilisé pour le DNS.
        *   `image` / `build`: Source de l'image.
        *   `ports`: Publication de ports.
        *   `volumes`: Montage de volumes/bind mounts.
        *   `networks`: Connexion aux réseaux définis.
        *   `environment`: Variables d'environnement.
        *   `depends_on`: Ordre de démarrage simple (ne garantit pas que l'app est prête).
    *   `networks`: Définition des réseaux personnalisés.
    *   `volumes`: Définition des volumes nommés.
*   **Fonctionnement :** Compose crée réseau(x) et volume(s) par défaut/définis, puis démarre les services.

### Commandes Essentielles (`docker compose ...`)

*   `docker compose up [-d] [--build]` : Crée et démarre l'application. `-d` détaché, `--build` force la reconstruction.
*   `docker compose down [-v]` : Arrête et supprime les conteneurs/réseaux. `-v` supprime aussi les volumes nommés.
*   `docker compose ps` : Lister les services de l'application.
*   `docker compose logs [-f] [service]` : Voir les logs (d'un service ou tous).
*   `docker compose exec <service> <cmd>` : Exécuter une commande dans un service.
*   `docker compose stop/start/restart [service]` : Gérer l'état des services.
*   `docker compose build [service]` : (Re)construire les images.
*   `docker compose config` : Valider et afficher la configuration fusionnée.

### À Retenir

*   Compose simplifie radicalement la gestion d'applications multi-conteneurs.
*   `docker-compose.yml` est la clé pour une définition déclarative.

---

## **Chapitre 8 : Gestion des Données**

### Concepts Clés

*   **Problème :** Les données dans la couche d'écriture du conteneur sont perdues à la suppression (`rm`).
*   **Solutions (stockage externe) :**
    *   **Volumes (Recommandé pour la persistance) :**
        *   Gérés par Docker (`/var/lib/docker/volumes/...`).
        *   **Nommés** (préféré) ou anonymes.
        *   Portables, faciles à gérer (`docker volume ...`), performants.
        *   Pré-population au premier montage.
        *   Usage : Données de BDD, uploads, état d'application.
    *   **Bind Mounts (Recommandé pour le développement/config) :**
        *   Monte un répertoire/fichier **de l'hôte** dans le conteneur.
        *   Accès direct depuis l'hôte. Idéal pour le code source en dev.
        *   Inconvénients : Dépendance de l'hôte, portabilité, permissions, sécurité.
        *   Masque le contenu de l'image à l'emplacement du montage.
    *   **`tmpfs` Mounts :** Stockage temporaire en RAM. Volatile.

### Commandes / Syntaxe

*   **Volumes :**
    *   `docker volume create/ls/inspect/rm/prune`
    *   `docker run -v mon-volume:/chemin/conteneur ...`
    *   `docker run --mount type=volume,source=mon-volume,target=/chemin/conteneur ...` (plus verbeux)
    *   Compose : sections `volumes:` racine et service.
*   **Bind Mounts :**
    *   `docker run -v /chemin/hote:/chemin/conteneur ...`
    *   `docker run --mount type=bind,source=/chemin/hote,target=/chemin/conteneur ...`
    *   Compose : `volumes: - ./local/path:/container/path`

### À Retenir

*   Utiliser les **Volumes nommés** pour les données que l'application doit persister.
*   Utiliser les **Bind Mounts** pour le code en développement ou l'injection de configurations depuis l'hôte.

---

## **Chapitre 9 : Exemple Complet (App de Vote)**

### Architecture

*   `vote` (Flask) -> `redis` <- `worker` (Python) -> `db` (Postgres) <- `result` (Node.js)
*   [Diagramme : Architecture Vote App]

### Mise en Pratique

*   **Dockerfiles** pour `vote`, `worker`, `result`.
*   **`docker-compose.yml`** définissant les 5 services.
*   **Réseau personnalisé (`voting-net`)** pour la communication inter-services (DNS).
*   **Volume nommé (`db-data`)** pour la persistance des données Postgres.
*   **Variables d'environnement** pour la configuration (hôtes DB/Redis, mots de passe...).
*   **`depends_on`** pour l'ordre de démarrage.
*   Utilisation de `docker compose up --build` et `down -v`.

### À Retenir

*   Combine tous les concepts : Images, Conteneurs, Réseau, Volumes, Compose.
*   Illustre un cas d'usage réaliste (microservices simples).

---

## **Chapitre 10 : Bonnes Pratiques**

### Optimisation & Taille

*   Image de base : `alpine`, `slim`.
*   Builds Multi-Étapes (essentiel !).
*   Minimiser les couches (`RUN` groupés + nettoyage dans la même couche).
*   Optimiser le cache (ordre des instructions).
*   Utiliser `.dockerignore`.

### Sécurité

*   **`USER` : Ne pas exécuter en `root` !**
*   Images Officielles / Vérifiées.
*   Scanner les vulnérabilités (`docker scan`, Trivy...).
*   Minimiser la surface d'attaque (paquets inutiles).
*   **Gestion des Secrets :** PAS dans l'image. Utiliser variables d'env (limitées), Docker secrets, Vault, etc.

### Gestion & Maintenance

*   Tags : Explicites (pas `:latest` en prod). Sémantiques ou Git hash.
*   Nettoyage Régulier (`docker system prune`, `volume prune`...).
*   Versionner les Dockerfiles (Git).
*   Documenter (commentaires `#`).

### Docker Compose

*   Fichiers `.env` pour la configuration externe.
*   `healthchecks` pour des dépendances robustes.

### À Retenir

*   Construire petit, sécurisé et reproductible.
*   Maintenir un environnement propre.

---

## **Chapitre 11 : Conclusion**

### Ce que vous avez appris

*   Installation et gestion du cycle de vie des conteneurs.
*   Création d'images optimisées avec Dockerfile.
*   Gestion et partage d'images via les registres.
*   Configuration du réseau et des logs.
*   Orchestration simple avec Docker Compose.
*   Gestion de la persistance des données (Volumes).
*   Application des bonnes pratiques.

### Bénéfices Clés de Docker

*   Cohérence des environnements (Dev, Test, Prod).
*   Portabilité & Isolation.
*   Efficacité & Densification.
*   Déploiement rapide & Scalabilité.
*   Productivité des développeurs.

### Prochaines Étapes

*   **Orchestration avancée :** Kubernetes, Docker Swarm.
*   **CI/CD :** Intégration avec Jenkins, GitLab CI, GitHub Actions...
*   Réseau / Stockage / Sécurité / Monitoring avancés.
*   Docker dans le Cloud (AWS EKS/ECS, Google GKE, Azure AKS...).
*   **PRATIQUEZ !**

---

## **Questions & Réponses**

**Merci !**
