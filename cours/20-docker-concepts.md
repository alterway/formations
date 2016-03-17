# Docker : les concepts

### Un ensemble de concepts et de composants

- Layers

- Stockage
-
- Volumes

- Réseau

- Ports

- Links

### Layers

- Les conteneurs et leurs images sont decomposées en couches (layers)

- Les layers peuvent etre reutiliser entre differents conteneurs

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

- Stable : performances écriture moyennes

- Non intégré dans le Kernel Linux (mainline)

### Stockage : Device Mapper

- Basé sur LVM

- Thin Provisionning et snapshot

- Intégré dans le Kernel Linux (mainline)

- Stable : performances écriture moyennes

### Stockage : OverlayFS

- Successeur de AUFS

- Performances accrues

- Relativement stable mais moins éprouvé que AUFS ou Device Mapper

### Stockage : volumes

![Un volume monté sur deux conteneurs](images/docker/shared-volume.jpg)

### Réseau : A la base, pas grand chose...

```
NETWORK ID      NAME      DRIVER
42f7f9558b7a    bridge    bridge
6ebf7b150515    none      null
0509391a1fbd    host      host
```

### Réseau : Et puis des trucs sympas !

- Driver réseau

- libnetwork

### Réseau : multihost overlay

![](images/docker/overlay_network.png)

### Réseau : ports

![](images/docker/network_access.png)

