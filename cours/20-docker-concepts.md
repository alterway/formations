# Les concepts

### Un ensemble de concepts et de composants

- Layers

- Stockage

- Volumes

- Réseau

- Publication de ports

- Links

### Layers

- Les conteneurs et leurs images sont décomposés en couches (layers)

- Les layers peuvent être réutiliser entre différents conteneurs

- Gestion optimisée de l'espace disque.

### Layers : une image

![Une image se decompose en layers](images/docker/image-layers.jpg)

### Layers : un conteneur

![Une conteneur = une image + un layer r/w](images/docker/container-layers.jpg)

### Layers : plusieurs conteneurs

![Une image, plusieurs conteneurs](images/docker/sharing-layers.jpg)

### Layers : Répétition des layers

![Les layers sont indépendants de l'image](images/docker/saving-space.jpg)

### Stockage

- Images Docker, données des conteneurs, volumes

- Multiples backends (extensibles via plugins):
    - AUFS
    - DeviceMapper
    - OverlayFS
    - NFS (via plugin Convoy)
    - GlusterFS (via plugin Convoy)

### Stockage : AUFS

- A unification filesystem

- Stable : performance écriture moyenne

- Non intégré dans le Kernel Linux (mainline)

### Stockage : Device Mapper

- Basé sur LVM

- Thin Provisionning et snapshot

- Intégré dans le Kernel Linux (mainline)

- Stable : performance écriture moyenne

### Stockage : OverlayFS

- Successeur de AUFS

- Performances accrues

- Relativement stable mais moins éprouvé que AUFS ou Device Mapper

### Stockage : Plugins

- Étendre les drivers de stockages disponibles

- Utiliser des systèmes de fichier distribués (GlusterFS)

- Partager des volumes entre plusieurs hôtes docker

### Volumes

- Assurent une persistance des données

- Indépendance du volume par rapport au conteneur et aux layers

- Deux types de volumes :
    - Conteneur : Les données sont stockées dans ce que l'on appelle un data conteneur
    - Hôte : Montage d'un dossier de l'hôte docker dans le conteneur

- Partage de volumes entre plusieurs conteneurs

### Volumes : Exemple

![Un volume monté sur deux conteneurs](images/docker/shared-volume.jpg)

### Volumes : Plugins

- Permettre le partage de volumes entre differents hôtes

- Fonctionnalité avancées : snapshot, migration, restauration

- Quelques exemples:
    - Convoy : multi-host et multi-backend (NFS, GlusterFS) 
    - Flocker : migration de volumes dans un cluster

### Réseau : A la base, pas grand chose...

```
NETWORK ID      NAME      DRIVER
42f7f9558b7a    bridge    bridge
6ebf7b150515    none      null
0509391a1fbd    host      host
```

### Réseau : Bridge

- SCHÉMA

### Réseau : Host

- SCHÉMA

### Réseau : None

- Est assez explicite

### Réseau : Les évolutions

- Refactorisation des composants réseau (*libnetwork*)

- Système de plugins : multi host et multi backend (overlay network)

- Quelques exemples d'overlay :
    - Flannel : UDP et VXLAN
    - Weaves : UDP

### Réseau : multihost overlay

![](images/docker/overlay_network.png)

### Publication de ports

- Dans le cas d'un réseaux diffèrent de l'hôte

- Les conteneurs ne sont pas accessible depuis l'extérieur

- Possibilité de publier des ports depuis l'hôte vers le conteneur (*iptables*) 

- L'hôte sert de proxy au service

### Publication de ports

![](images/docker/network_access.png)

### Links

- Les conteneurs d'un même réseaux peuvent communiquer via IP

- Les liens permettent de lier deux conteneurs par nom

- Système de DNS rudimentaire (`/etc/hosts`)

- Remplacés par les *discovery services*

