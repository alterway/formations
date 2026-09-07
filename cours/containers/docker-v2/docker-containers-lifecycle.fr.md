# DOCKER : Gestion & Cycle de Vie des Conteneurs {-}

### La Machine à États du Conteneur

Un conteneur traverse différents états tout au long de sa vie :

```{.center}
                    ┌─────────────┐
                    │  NON EXISTE │
                    └──────┬──────┘
             docker create │   ▲
             ou run        │   │ docker rm
                           ▼   │
┌─────────────────────────► CREATED ◄─────────────────────────┐
│                             │                               │
│                             │ docker start                  │
│                 docker stop │                               │
│                 ou kill     ▼                               │
│              ┌─────────── RUNNING ───────────┐              │
│              │              ▲                │              │
│  Fin du PID 1│  docker      │ docker         │ docker       │
│              │  unpause     │ pause          │ stop/kill    │
│              │              ▼                │              │
│              │           PAUSED              │              │
│              │                               │              │
│              ▼                               ▼              │
└─────────── EXITED ───────────────────────── DEAD ───────────┘
```

### Le Cycle de Vie Quotidien en CLI

Docker utilise désormais la syntaxe unifiée orientée objets (`docker container <action>`) :

```bash
# 1. Créer et démarrer en arrière-plan (detached)
docker container run -d --name web-app -p 8080:80 nginx:alpine

# 2. Inspecter les conteneurs actifs
docker container ls  # ou: docker ps

# 3. Mettre en pause / Réactiver les processus (sans décharger la mémoire)
docker container pause web-app
docker container unpause web-app

# 4. Arrêter proprement (envoi SIGTERM puis SIGKILL après 10s)
docker container stop web-app

# 5. Supprimer le conteneur arrêté
docker container rm web-app
```

### Les Modes d'Exécution : Interactif vs Détaché

```{.center}
        MODE INTERACTIF (-it)                       MODE DÉTACHÉ (-d)
┌──────────────────────────────────┐       ┌──────────────────────────────────┐
│ Terminal attaché au conteneur    │       │ Exécution en arrière-plan        │
│ Idéal pour déboguer, tester      │       │ Idéal pour serveurs web, APIs, DB│
│ Stoppe à la sortie du terminal   │       │ Reste actif tant que PID 1 tourne│
└──────────────────────────────────┘       └──────────────────────────────────┘
```

```bash
# Lancer un shell interactif éphémère (--rm supprime à la sortie)
docker container run -it --rm ubuntu:22.04 bash

# Lancer un serveur web pérenne en tâche de fond
docker container run -d --name api-server -p 3000:3000 node:20-alpine
```

### Exécuter des Commandes dans un Conteneur en Cours d'Exécution

La commande `docker exec` permet d'injecter un nouveau processus dans les namespaces existants d'un conteneur :

```bash
# Ouvrir un shell d'administration dans un conteneur actif
docker container exec -it web-app sh

# Exécuter une commande ponctuelle sans ouvrir de session
docker container exec web-app nginx -t
docker container exec web-app cat /etc/hosts
```

### Analyse des Logs & Débogage en Direct

```bash
# 1. Afficher les 50 dernières lignes de logs
docker container logs --tail 50 web-app

# 2. Suivre les logs en temps réel avec horodatage (Follow + Timestamps)
docker container logs -f -t web-app

# 3. Filtrer par date relative
docker container logs --since 15m web-app
```

### Politiques de Redémarrage Automatique (`--restart`)

En production, un conteneur doit pouvoir se relancer automatiquement après un crash ou un redémarrage de la machine hôte :

```{.center}
┌───────────────────┬────────────────────────────────────────────────────────┐
│ POLITIQUE         │ COMPORTEMENT                                           │
├───────────────────┼────────────────────────────────────────────────────────┤
│ `no`              │ Jamais de redémarrage automatique (par défaut)         │
│ `on-failure[:max]`│ Redémarre uniquement si code retour != 0 (max N fois)  │
│ `always`          │ Redémarre toujours, y compris au reboot de l'hôte      │
│ `unless-stopped`  │ Comme always, sauf si stoppé manuellement par un admin │
└───────────────────┴────────────────────────────────────────────────────────┘
```

```bash
# Exemple recommandé en production :
docker container run -d --name db-prod --restart unless-stopped postgres:16
```

### Le Défi du Processus PID 1 & l'Option `--init`

Dans un conteneur, le processus principal prend le **PID 1** :
- Il doit gérer la réception et propagation des signaux système (`SIGTERM`, `SIGINT`).
- Il doit récolter les processus enfants terminés (*Zombie processes / Init Reaping*).

```bash
# Si votre application (ex: Node.js, Python, Java) gère mal les signaux :
# Utilisez l'option --init (injecte le mini-init 'tini' en PID 1)
docker container run -d --init --name node-app my-node-image:latest
```

### Mini-Défi : Diagnostic d'Arrêt (Exit 137)

**Incident SRE** : Votre conteneur Java ou Node.js s'arrête brutalement avec le statut `Exited (137)`. Quelle en est la cause principale ?

- **A.** L'application a terminé son traitement avec succès (code 0).
- **B.** Le fichier binaire ou la commande spécifiée dans CMD est introuvable.
- **C.** Le conteneur a reçu un signal SIGKILL (128 + 9), déclenché par l'OOM Killer (dépassement du quota RAM).
- **D.** Le port réseau demandé est déjà réservé sur la machine hôte.

### Mini-Défi : Diagnostic d'Arrêt (Exit 137)

**Incident SRE** : Votre conteneur Java ou Node.js s'arrête brutalement avec le statut `Exited (137)`. Quelle en est la cause principale ?

- **A.** L'application a terminé son traitement avec succès (code 0).
- **B.** Le fichier binaire ou la commande spécifiée dans CMD est introuvable.
- **C.** Le conteneur a reçu un signal SIGKILL (128 + 9), déclenché par l'OOM Killer (dépassement du quota RAM).
- **D.** Le port réseau demandé est déjà réservé sur la machine hôte.

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE : C                          │
│  Le code 137 correspond au signal SIGKILL (128 + 9).        │
│  Dans 95% des cas en production, il est émis par l'OOM      │
│  Killer du noyau Linux suite au dépassement de `--memory`.  │
└─────────────────────────────────────────────────────────────┘
```

### Mini-Défi : Surveillance en Temps Réel

**Question** : Quelle commande native permet de suivre en direct la consommation CPU/RAM et les flux I/O de tous vos conteneurs ?

- **A.** `docker inspect --all`
- **B.** `docker top`
- **C.** `docker stats`
- **D.** `docker system monitor`

### Mini-Défi : Surveillance en Temps Réel

**Question** : Quelle commande native permet de suivre en direct la consommation CPU/RAM et les flux I/O de tous vos conteneurs ?

- **A.** `docker inspect --all`
- **B.** `docker top`
- **C.** `docker stats`
- **D.** `docker system monitor`

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE : C                          │
│  `docker stats` affiche un tableau de bord dynamique en     │
│  temps réel (CPU %, RAM consommée / limite, I/O réseau).    │
└─────────────────────────────────────────────────────────────┘
```

