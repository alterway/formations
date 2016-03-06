# Docker : les concepts

### Un ensemble de composants

- Layers
- Stockage
- Volumes
- Réseau
- Ports
- Links

### Layers : une image

![image-layers](images/docker/image-layers.jpg)

### Layers : un conteneur

![container-layers](images/docker/container-layers.jpg)

### Layers : plusieurs conteneurs

![sharing-layers](images/docker/sharing-layers.jpg)

### Layers : Répétition des layers

![saving-space](images/docker/saving-space.jpg)

### Stockage : volumes

![shared-volume](images/docker/shared-volume.jpg)

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

![overlay](images/docker/overlay_network.png)

### Réseau : ports

![ports](images/docker/network_access.png)

