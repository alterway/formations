# Docker : les concepts

### Un ensemble de concepts et de composants

- Layers : un image contient une ou plusieurs couches, ces couches peuvent être partagées et réutilisées entre les différentes images afin de réduire l'espace de stockage

- Stockage : Docker permet l'utilisation de plusieurs backend de stockage contenant les layers ainsi que potentiellement les données des conteneurs.

- Volumes : Un conteneur est éphémère, il est cependant possible de disposer de données persistantes grâce au volumes.

- Réseau : Docker permet l'utilisation de plusieurs backend réseau afin de fournir la connectivité aux conteneurs.

- Ports :

- Links

### Stockage

- Images Docker

- Les données des conteneurs

- Multiples backends (extensibles via plugins):
    - AUFS
    - DeviceMapper
    - OverlayFS
    - BTRFS
    - ZFS
    - XFS
    - NFS (via plugin Convoy)
    - GlusterFS (via plugin Convoy)

### Layers : une image

![](images/docker/image-layers.jpg)

### Layers : un conteneur

![Une conteneur = une image + un layer r/w](images/docker/container-layers.jpg)

### Layers : plusieurs conteneurs

![Une image, plusieurs conteneurs](images/docker/sharing-layers.jpg)

### Layers : Répétition des layers

![Les layers sont indépendants de l'image](images/docker/saving-space.jpg)

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

