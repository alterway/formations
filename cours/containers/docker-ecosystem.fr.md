# Écosystème Docker

### Docker Inc.

- Docker Inc != Docker Project

- Docker Inc est le principal développeur du Docker Engine, Compose, Machine, Kitematic, Swarm etc.

- Ces projets restent OpenSource et les contributions sont possibles

### OCI

- Créé sous la Linux Fondation

- But : Créer des standards OpenSource concernant la manière de "runner" et le format des conteneurs

- Non lié à des produits commerciaux

- Non lié à des orchestrateurs ou des clients particuliers

- runC a été donné par Docker à l'OCI comme base pour leurs travaux

![](images/docker/oci.png){height="100px"}

### Les autres produits Docker

### Docker-compose

- Concept de stack

- Infrastructure as a code

- Scalabilité

![](images/docker/compose.png){height="100px"}

### Docker-compose

docker-compose.yml
```
nginx:
  image: vsense/nginx
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - "/srv/nginx/etc/sites-enabled:/etc/nginx/sites-enabled"
    - "/srv/nginx/etc/certs:/etc/nginx/certs"
    - "/srv/nginx/etc/log:/var/log/nginx"
    - "/srv/nginx/data:/var/www"
```

### Docker-machine

- "Metal" as a Service

- Provisionne des hôtes Docker

- Abstraction du Cloud Provider

### Docker Swarm

- Clustering : Mutualisation d'hôtes Docker

- Orchestration : placement intelligent des conteneurs au sein du cluster

![](images/docker/docker-swarm.png){height="100px"}

### Autour de Docker

- Plugins : étendre les fonctionnalités notamment réseau et volumes

![](images/docker/weave.png){height="80px"} ![](images/docker/kuryr.png){height="80px"} ![](images/docker/flocker.png){height="80px"} ![](images/docker/convoy.png){height="80px"}

- Systèmes de gestion de conteneurs (COE)

- Docker as a Service :
    - Docker Cloud
    - Tutum

![](images/docker/tutum.png){height="80px"} ![](images/docker-media-kit/small_h-trans.png){height="80px"}

### Écosystème Docker : conclusion

- Le projet Docker est Open Source et n'appartient plus a Docker

- Des outils permettent d'étendre les fonctionnalités de Docker

- Docker Inc. construit des offres commerciales autour de Docker
