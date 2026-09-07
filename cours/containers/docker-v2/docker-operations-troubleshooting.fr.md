# DOCKER : Exploitation, Monitoring & Dépannage {-}

### Méthodologie Systématique de Diagnostic d'un Incident

Quand un conteneur refuse de fonctionner, suivez cet arbre d'investigation :

```{.center}
┌─────────────────────────────────────────────────────────────┐
│ 1. ÉTAT DU CONTENEUR : `docker ps -a`                       │
│    └── Le conteneur tourne-t-il ou est-il arrêté (Exited) ? │
├─────────────────────────────────────────────────────────────┤
│ 2. CODE DE SORTIE : `docker inspect <id> --format '{{...}}'`│
│    ├── Exit 0   : Fin normale du script                     │
│    ├── Exit 1   : Erreur applicative interne                │
│    ├── Exit 127 : Commande ou binaire introuvable           │
│    ├── Exit 137 : Tué par OOM Killer (Manque de RAM)        │
│    └── Exit 139 : Segmentation Fault                        │
├─────────────────────────────────────────────────────────────┤
│ 3. JOURNAUX D'ERREURS : `docker logs --tail 100 <id>`       │
│    └── Traceback, exceptions, port déjà réservé             │
├─────────────────────────────────────────────────────────────┤
│ 4. SONDES DE SANTÉ : `docker inspect <id>`                  │
│    └── Le HEALTHCHECK échoue-t-il ? (Statut unhealthy)      │
└─────────────────────────────────────────────────────────────┘
```

### Requêtes Expertes avec `docker inspect` & Go Templates

Ne parcourez plus des fichiers JSON de 500 lignes :

```bash
# 1. Extraire l'adresse IP d'un conteneur
docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web-app

# 2. Vérifier le code d'erreur et la raison de l'arrêt
docker inspect --format 'ExitCode: {{.State.ExitCode}} | OOMKilled: {{.State.OOMKilled}}' web-app

# 3. Extraire les points de montage réels sur le disque hôte
docker inspect --format '{{range .Mounts}}{{.Source}} -> {{.Destination}} ({{.Type}}){{"\n"}}{{end}}' web-app

# 4. Formater en JSON élégant avec jq
docker inspect web-app | jq '.[0].State'
```

### Gestion & Rotation des Logs de Conteneurs

Par défaut, le pilote `json-file` stocke les logs indéfiniment sur le disque hôte jusqu'à saturation (`/var/lib/docker/containers/*/*-json.log`).

Configurez une politique globale de rotation dans `/etc/docker/daemon.json` :

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "5"
  }
}
```

```bash
# Recharger la configuration à chaud sans couper les conteneurs :
sudo systemctl reload docker
```

### Maintenance du Disque : Éviter le "Disk Full"

```bash
# 1. Analyser l'espace disque consommé par catégorie (Images, Containers, Volumes, Cache)
docker system df -v

# 2. Nettoyer les ressources non utilisées (conteneurs arrêtés, réseaux orphelins)
docker system prune

# 3. Nettoyage TOTAL (Images non utilisées + Build cache + Volumes orphelins)
docker system prune -a --volumes -f
```

### Surveillance des Performances en Temps Réel (`docker stats`)

```bash
# Tableau de bord live de la consommation CPU, RAM, I/O Disque et Réseau :
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
```

```
NAME        CPU %     MEM USAGE / LIMIT     NET I/O       BLOCK I/O
api-server  0.45%     128.4MiB / 1.952GiB   1.2MB / 450KB 0B / 12KB
postgres-db 1.20%     240.1MiB / 1.952GiB   850KB / 2.1MB 4.1MB / 80MB
redis       0.05%     14.2MiB / 512MiB      320KB / 120KB 0B / 0B
```

### Export des Métriques Docker vers Prometheus

Activez le point d'accès natif aux métriques dans `/etc/docker/daemon.json` :

```json
{
  "metrics-addr": "127.0.0.1:9323",
  "experimental": true
}
```

Prometheus peut désormais moissonner (`scrape`) les compteurs de conteneurs, les allocations mémoires et les temps de réponse du moteur Docker !

### Mini-Défi : Diagnostic d'un Crash Éclair

**Question** : Votre conteneur démarre et s'arrête instantanément avec un code `Exit 137`. Quel est le réflexe de diagnostic immédiat ?

- **A.** Réinstaller le moteur Docker depuis zéro.
- **B.** Vérifier `docker inspect <nom>` pour vérifier si la propriété `OOMKilled` est à `true` (dépassement du quota de mémoire RAM).
- **C.** Changer le nom du conteneur avec `--name`.
- **D.** Purger la totalité des volumes de l'hôte.

### Mini-Défi : Diagnostic d'un Crash Éclair

**Question** : Votre conteneur démarre et s'arrête instantanément avec un code `Exit 137`. Quel est le réflexe de diagnostic immédiat ?

- **A.** Réinstaller le moteur Docker depuis zéro.
- **B.** Vérifier `docker inspect <nom>` pour vérifier si la propriété `OOMKilled` est à `true` (dépassement du quota de mémoire RAM).
- **C.** Changer le nom du conteneur avec `--name`.
- **D.** Purger la totalité des volumes de l'hôte.

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE : B                          │
│  La commande `docker inspect --format '{{.State.OOMKilled}}'│
│  <nom>` permet de confirmer instantanément si le noyau Linux│
│  a tué le processus suite à une saturation de la RAM.       │
└─────────────────────────────────────────────────────────────┘
```

