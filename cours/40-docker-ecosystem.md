# Ecosystème Docker

### Docker Inc.

- Docker Inc != Docker Project

- Docker Inc est le principal développeur du Docker Engine, Compose, Machine,
  Kitematic, Swarm etc.

- Ces projets restent OpenSource et les contributions sont possibles

### OCI

- Crée sous la Linux Fondation

- But : Créer des standards opensource concernant la manière de "runner" et le
  format des conteneurs

- Non lié à des produits commerciaux

- Non lié à des orchestrateurs ou des clients particuliers

- runC a été donné par Docker à l'OCI comme base pour leurs travaux

### Les autres produits Docker

### Docker-compose

- Concept de stack

- Infrastructure as a code

- Scalabilité

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

### Machine

- "Metal" as a Service

- Abstraction du cloud provider

### Swarm

- Clustering

- Orchestration

![](images/docker/docker-swarm.png)

### Plugins réseau et stockage

- Schéma

