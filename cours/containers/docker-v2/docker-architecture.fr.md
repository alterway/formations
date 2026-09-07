# DOCKER : Architecture Interne & Fondations Linux {-}

### La Vérité Fondamentale : Un Conteneur n'Existe Pas !

Sur Linux, un conteneur n'est **pas une entité matérielle ou une machine virtuelle**.

> Un conteneur est un **simple processus Linux standard**, exécuté directement par le processeur de l'hôte, mais **isolé et contraint** par des fonctionnalités natives du noyau Linux :
> 1. Les **Namespaces** (pour isoler ce que le processus peut *voir*).
> 2. Les **Cgroups** (pour limiter ce que le processus peut *consommer*).
> 3. **Overlay2 / UnionFS** (pour lui fournir son propre *système de fichiers*).

### Les 7 Namespaces du Noyau Linux

Les *Namespaces* virtualisent les ressources globales de l'OS en espaces isolés :

```{.center}
┌──────────────────────────────────────────────────────────────────┐
│                LES 7 NAMESPACES LINUX DU CONTENEUR               │
├──────────────────┬───────────────────────────────────────────────┤
│ 1. PID Namespace │ Arborescence de processus isolée (PID 1 dédié)│
│ 2. NET Namespace │ Interfaces réseau (eth0, lo), tables IP/ports │
│ 3. MNT Namespace │ Points de montage et système de fichiers isolé│
│ 4. UTS Namespace │ Nom d'hôte (hostname) et nom de domaine       │
│ 5. IPC Namespace │ Communication inter-processus & mémoire part. │
│ 6. USER Namespace│ Mappage des UIDs/GIDs (root conteneur != host)│
│ 7. CGROUP NS     │ Masquage de la hiérarchie cgroup parente      │
└──────────────────┴───────────────────────────────────────────────┘
```

### L'Isolation des Processus : PID Namespaces

Le même processus possède deux identifiants : un PID local vu dans le conteneur, et un PID réel sur l'hôte.

```{.center}
                    PARENT PID NAMESPACE (HÔTE LINUX)
┌──────────────────────────────────────────────────────────────────┐
│ PID 1 : /sbin/init (systemd)                                     │
│   └── PID 1042 : dockerd                                         │
│         └── PID 1120 : containerd                                │
│               ├── PID 2104 : containerd-shim (Conteneur Nginx)   │
│               │     └── PID 2180 : nginx: master process         │
│               └── PID 3240 : containerd-shim (Conteneur Python)  │
│                     └── PID 3310 : python app.py                 │
└───────────────────────────────────┬──────────────────────────────┘
                                    │
                                    ▼
       CONTENEUR NGINX (PID NS 1)        CONTENEUR PYTHON (PID NS 2)
      ┌──────────────────────────┐      ┌──────────────────────────┐
      │ PID 1 : nginx: master    │      │ PID 1 : python app.py    │
      │ PID 2 : nginx: worker    │      │ PID 2 : worker thread    │
      └──────────────────────────┘      └──────────────────────────┘
```

### Control Groups (Cgroups v1 & v2) : Le Budget de Ressources

Les **Cgroups** garantissent qu'un conteneur ne peut pas saturer ou affamer la machine hôte (*Noisy Neighbor problem*) :

- **CPU** : Partage relatif (`--cpu-shares`) ou plafond strict en millicores (`--cpus=1.5`).
- **Mémoire RAM** : Limite stricte (`--memory=512m`). Si le conteneur dépasse ce seuil, le noyau déclenche l'**OOM Killer** (*Out Of Memory* - code sortie 137).
- **Entrées/Sorties (I/O)** : Débit maximal de lecture/écriture disque (`--device-read-bps`).
- **Nombre de processus (PIDs)** : Protection contre les *fork bombs* (`--pids-limit=100`).

### Le Système de Fichiers : UnionFS & Driver Overlay2

Un conteneur combine plusieurs couches en lecture seule avec une couche supérieure en lecture/écriture :

```{.center}
┌─────────────────────────────────────────────────────────────┐
│ 4. MERGED VIEW (Ce que voit l'application dans le conteneur)│
├─────────────────────────────────────────────────────────────┤
│ 3. UPPERDIR (Lecture / Écriture - Couche du conteneur)      │ ── Modifiable
├─────────────────────────────────────────────────────────────┤
│ 2. LOWERDIR 2 (Couche Image - Configuration & Code)         │ ── Lecture Seule
├─────────────────────────────────────────────────────────────┤
│ 1. LOWERDIR 1 (Couche Image - Base OS Ubuntu / Alpine)      │ ── Lecture Seule
└─────────────────────────────────────────────────────────────┘
```

**Le mécanisme de Copy-on-Write (CoW)** :
- Lors d'une lecture : les fichiers sont lus directement dans les couches de l'image (*lowerdir*).
- Lors d'une écriture sur un fichier existant : le fichier est **copié** depuis l'image vers la couche supérieure (*upperdir*) avant modification.

### Architecture Modulaire de Docker Engine

Docker n'est pas un bloc monolithique, mais une suite de composants spécialisés OCI :

```{.center}
┌─────────────────────────────────────────────────────────────┐
│ 1. CLIENT DOCKER (CLI) : `docker run`, `docker build`       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Appel REST / Socket UNIX
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. DOCKER DAEMON (`dockerd`) : API, Réseau, Volumes, Builds │
└──────────────────────────────┬──────────────────────────────┘
                               │ Interface gRPC
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. CONTAINERD : Gestionnaire complet du cycle de vie OCI    │
└──────────────────────────────┬──────────────────────────────┘
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
┌───────────────────────────────┐   ┌───────────────────────────┐
│ containerd-shim (Conteneur A) │   │ containerd-shim (Cont. B) │
├───────────────────────────────┤   ├───────────────────────────┤
│ runc (Instancie namespaces)   │   │ runc (Instancie namespaces│
├───────────────────────────────┤   ├───────────────────────────┤
│ Processus applicatif (App A)  │   │ Processus applicatif (App)│
└───────────────────────────────┘   └───────────────────────────┘
```

- **`containerd-shim`** : Permet de redémarrer ou mettre à jour le démon Docker **sans tuer les conteneurs en cours d'exécution** (*Live Restore*).
- **`runc`** : L'implémentation de référence OCI qui configure les appels noyau (`clone`, `unshare`, `pivot_root`).

### Mini-Défi Architecture

**Que se passe-t-il si le démon `dockerd` crashe ou est redémarré avec l'option `live-restore: true` ?**

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE                              │
│  Grâce à `containerd-shim`, les processus applicatifs       │
│  continuent de s'exécuter normalement sans aucune coupure ! │
│  Le démon se reconnecte simplement aux shims à son retour.  │
└─────────────────────────────────────────────────────────────┘
```
