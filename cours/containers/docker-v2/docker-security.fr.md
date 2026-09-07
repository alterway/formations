# DOCKER : Sécurité, Isolation & Durcissement {-}

### Le Modèle des 4C Appliqué aux Conteneurs

La sécurité Cloud Native repose sur le principe de **défense en profondeur** (*Defense in Depth*) :

```{.center}
┌───────────────────────────────────────────────────────────┐
│               1. CLOUD / HÔTE (Host Security)             │
│   ┌───────────────────────────────────────────────────┐   │
│   │           2. DÉMON DOCKER (Docker Engine)         │   │
│   │   ┌───────────────────────────────────────────┐   │   │
│   │   │         3. CONTENEUR (Runtime Hardening)  │   │   │
│   │   │   ┌───────────────────────────────────┐   │   │   │
│   │   │   │          4. CODE & DÉPENDANCES    │   │   │   │
│   │   │   └───────────────────────────────────┘   │   │   │
│   │   └───────────────────────────────────────────┘   │   │
│   └───────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────┘
```

- **Hôte** : Durcissement Linux, mises à jour kernel, pare-feu UFW/iptables, chiffrement disques.
- **Démon** : Socket UNIX protégée (`/var/run/docker.sock` non exposée), mode Rootless, TLS mutuel pour l'API.
- **Conteneur** : Utilisateur non-root, drop des Linux Capabilities, profils Seccomp & AppArmor, système de fichiers en lecture seule.
- **Code** : Scan des dépendances (SCA), analyse statique (SAST), gestion des secrets hors de l'image.

### Règle d'Or N°1 : Ne Jamais Exécuter en tant que `root` !

Par défaut, l'utilisateur à l'intérieur du conteneur est `root (UID 0)`. En cas d'évasion de conteneur (*Container Escape*), l'attaquant devient root sur l'hôte !

```dockerfile
# Dans le Dockerfile :
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -s /bin/sh -m appuser

USER 1001:1001
```

```bash
# Ou en surcharge lors du lancement :
docker run -d --user 1001:1001 --name safe-app my-image:latest
```

### Le Mode Docker Rootless : Éliminer les Privilèges

Le mode **Rootless** permet d'exécuter à la fois le démon Docker et les conteneurs sous un utilisateur standard sans aucun droit `sudo` :

```{.center}
       DOCKER CLASSIQUE (ROOT)                        DOCKER ROOTLESS (NON-ROOT)
┌──────────────────────────────────────┐       ┌──────────────────────────────────────┐
│ `dockerd` tourne en tant que `root`  │       │ `dockerd` tourne sous l'UID 1000     │
│ Faille conteneur = Compromission Hôte│       │ Faille conteneur = Restreinte au user│
└──────────────────────────────────────┘       └──────────────────────────────────────┘
```

```bash
# Installation du mode rootless par utilisateur :
dockerd-rootless-setuptool.sh install
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
```

### Réduire les Privilèges : Les Linux Capabilities

Par défaut, le noyau Linux accorde environ 14 capacités aux conteneurs (sur les 40 existantes). La bonne pratique consiste à **tout supprimer, puis réautoriser au cas par cas** :

```bash
# 1. Dropper TOUTES les capacités, et autoriser UNIQUEMENT la liaison aux ports < 1024 :
docker run -d \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  -p 80:80 \
  nginx:alpine
```

### Système de Fichiers Immuable : `--read-only`

Empêcher un malware d'écrire ou de modifier des binaires dans le conteneur en rendant le système de fichiers en lecture seule :

```bash
# Système en lecture seule + montage de /tmp éphémère en mémoire RAM
docker run -d \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --tmpfs /var/run:rw,noexec,nosuid \
  my-app:prod
```

### Les Profils Seccomp & AppArmor

- **Seccomp (Secure Computing Mode)** : Filtre les appels système Linux (*syscalls*). Le profil par défaut de Docker bloque plus de 44 appels système dangereux (`reboot`, `ptrace`, `mount`, `kexec_load`).
- **AppArmor / SELinux** : Contrôle d'accès obligatoire (MAC) restreignant l'accès aux fichiers sensibles `/proc` et `/sys`.

### Scan de Vulnérabilités Intégré avec Docker Scout & Trivy

Détecter les failles de sécurité (CVEs) directement avant le déploiement :

```bash
# 1. Analyser une image avec Docker Scout
docker scout quickview nginx:latest
docker scout cves nginx:latest

# 2. Scanner avec Trivy (outil open-source incontournable)
trivy image --severity HIGH,CRITICAL my-app:latest
```

### Audit Automatique : Le Docker CIS Benchmark

Vérifier la conformité de votre hôte et démon Docker selon les recommandations du Center for Internet Security (CIS) :

```bash
# Lancer l'audit de sécurité automatisé :
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /etc:/etc:ro --label docker_bench_security \
  docker/docker-bench-security
```

### Mini-Défi : Durcissement Ultime en Production

**Question** : Quelle combinaison de drapeaux `docker run` applique le principe du moindre privilège pour un conteneur web ?

- **A.** `--privileged --net=host --user 0:0`
- **B.** `--cap-add=ALL --restart always`
- **C.** `--read-only --cap-drop=ALL --cap-add=NET_BIND_SERVICE --user 1000:1000 --security-opt no-new-privileges:true`
- **D.** `-v /:/host -it ubuntu bash`

### Mini-Défi : Durcissement Ultime en Production

**Question** : Quelle combinaison de drapeaux `docker run` applique le principe du moindre privilège pour un conteneur web ?

- **A.** `--privileged --net=host --user 0:0`
- **B.** `--cap-add=ALL --restart always`
- **C.** `--read-only --cap-drop=ALL --cap-add=NET_BIND_SERVICE --user 1000:1000 --security-opt no-new-privileges:true`
- **D.** `-v /:/host -it ubuntu bash`

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                        RÉPONSE : C                          │
│  Cette combinaison verrouille le système en lecture seule,  │
│  supprime toutes les capacités Linux sauf le bind du port,  │
│  tourne sans droits root et bloque l'escalade de privilèges.│
└─────────────────────────────────────────────────────────────┘
```

