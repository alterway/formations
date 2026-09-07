# DOCKER : Réseau & Communication Inter-Conteneurs {-}

### Le Modèle Réseau des Conteneurs (CNM)

Docker implémente la spécification **CNM (Container Network Model)** composée de 3 abstractions clés :

```{.center}
┌────────────────────────────────────────────────────────────────────────┐
│ 1. SANDBOX  : Isole la pile réseau d'un conteneur (Linux Network NS)   │
│ 2. ENDPOINT : Interface réseau virtuelle (`veth`) connectant le conteneur│
│ 3. NETWORK  : Le commutateur virtuel (Bridge / Overlay) interconnecteur│
└────────────────────────────────────────────────────────────────────────┘
```

```{.center}
                           MACHINE HÔTE DOCKER
┌────────────────────────────────────────────────────────────────────────┐
│ CONTENEUR A (172.20.0.2)                     CONTENEUR B (172.20.0.3)  │
│   └── interface eth0 (vethA)                   └── interface eth0 (vethB)│
│            │                                            │              │
│            └───────────────────┬────────────────────────┘              │
│                                ▼                                       │
│                PONT RÉSEAU VIRTUEL : `my-bridge` (172.20.0.1)          │
│            (Serveur DNS intégré : 127.0.0.11 / Résolution par nom)     │
│                                │                                       │
│                                ▼ iptables (NAT / Forwarding)           │
│                   INTERFACE PHYSIQUE HÔTE (`eth0`)                     │
└────────────────────────────────────────────────────────────────────────┘
```

### Les 5 Pilotes de Réseau Standards

```{.center}
┌────────────┬──────────────────────────────────────────────────────────────────┐
│ PILOTE     │ DESCRIPTION ET CAS D'USAGE RECOMMANDÉ                            │
├────────────┼──────────────────────────────────────────────────────────────────┤
│ `bridge`   │ Réseau privé virtuel local sur l'hôte (Le standard par défaut)   │
│ `host`     │ Supprime l'isolation réseau : le conteneur partage l'IP de l'hôte│
│ `none`     │ Conteneur totalement déconnecté (boucle locale `lo` seule)       │
│ `macvlan`  │ Assigne une adresse MAC physique et une IP réelle de votre réseau│
│ `overlay`  │ Réseau chiffré multi-hôtes pour les clusters (Swarm / Kubernetes)│
└────────────┴──────────────────────────────────────────────────────────────────┘
```

### Bridge par Défaut (`docker0`) vs Bridge Personnalisé (User-Defined)

> ⚠️ **DIFFÉRENCE FONDAMENTALE :**
> - **Bridge par défaut (`docker0`)** : **Pas de résolution DNS automatique** par nom de conteneur (nécessitait l'ancienne option obsolète `--link`).
> - **Bridge Personnalisé (`user-defined bridge`)** : **Résolution DNS interne automatique** par nom de conteneur ou alias réseau !

```bash
# 1. Créer un réseau bridge dédié pour notre application
docker network create --driver bridge app-network

# 2. Lancer une base de données sur ce réseau
docker run -d --name database --network app-network redis:alpine

# 3. Lancer une API qui contacte la base DIRECTEMENT par son nom 'database'
docker run -d --name api --network app-network -p 8080:8080 my-api:latest
# Dans le code de l'API : redis://database:6379 fonctionne instantanément !
```

### Publication et Redirection de Ports (`-p`)

Par défaut, un conteneur est accessible uniquement depuis les autres conteneurs du même réseau. Pour l'ouvrir à l'extérieur :

```bash
# 1. Ouvrir le port 80 du conteneur sur le port 8080 de TOUTES les interfaces de l'hôte
docker run -d -p 8080:80 nginx:alpine

# 2. Sécuriser : écouter UNIQUEMENT sur l'adresse locale (localhost)
docker run -d -p 127.0.0.1:8080:80 nginx:alpine

# 3. Spécifier le protocole UDP
docker run -d -p 53:53/udp dns-server:latest

# 4. Attribution dynamique d'un port aléatoire éphémère de l'hôte (-P)
docker run -d -P nginx:alpine
docker port <container_id>  # Affiche le port attribué (ex: 49153 -> 80)
```

### Commandes de Gestion du Réseau

```bash
# 1. Lister tous les réseaux
docker network ls

# 2. Inspecter la configuration et la liste des conteneurs connectés avec leur IP
docker network inspect app-network

# 3. Connecter un conteneur existant à un deuxième réseau à chaud
docker network connect app-network web-app

# 4. Déconnecter un conteneur
docker network disconnect app-network web-app

# 5. Supprimer un réseau inutilisé
docker network rm app-network
```

### Cloisonnement & Pare-Feu entre Conteneurs

Deux conteneurs placés sur des réseaux bridges distincts **ne peuvent absolument pas communiquer entre eux**, même s'ils tournent sur la même machine physique :

```{.center}
  RÉSEAU FRONTEND (172.18.0.0/16)             RÉSEAU BACKEND (172.19.0.0/16)
┌─────────────────────────────────┐         ┌─────────────────────────────────┐
│ [ Conteneur Web Nginx ]         │         │ [ Base de Données PostgreSQL ]  │
└────────────────┬────────────────┘         └────────────────┬────────────────┘
                 │                                           │
                 └─────────────── X BLOQUÉ X ────────────────┘
```

Pour permettre la communication : attacher uniquement le composant intermédiaire (ex: l'API backend) aux deux réseaux simultanément.

### Quizz : Réseau Docker

**Pourquoi deux conteneurs sur le bridge par défaut (`docker0`) ne peuvent-ils pas se joindre via `ping mon-conteneur` ?**

[(X)] Parce que le serveur DNS intégré de Docker n'est activé que sur les réseaux bridges personnalisés (*user-defined*)
[( )] Parce que les conteneurs n'ont pas de carte réseau
[( )] Parce que le protocole ICMP est interdit par la licence Docker
[( )] Parce que les conteneurs ont obligatoirement la même adresse IP
