# Build, Ship and Run !

### Build

### Le conteneur et son image

- Flexibilité et élasticité

- Format standard de facto

- Instanciation illimitée

### Construction d'une image

- Possibilité de construire son image à la main (long et source d'erreurs)

- Suivi de version et construction d'images de manière automatisée

- Utilisation de *Dockerfile* afin de garantir l'idempotence des images

### Dockerfile

- Suite d'instruction qui définit une image

- Permet de vérifier le contenu d'une image

```
FROM alpine:3.2
MAINTAINER Osones <docker@osones.io>
RUN apk -U add nginx
EXPOSE 80 443
CMD ["nginx"]
```

### Dockerfile : principales instructions

- `FROM` : baseimage utilisée

- `RUN` : Commandes effectuées lors du build de l'image

- `EXPOSE` : Ports exposées lors du run (si `-P` est précisé)

- `ENV` : Variables d'environnement du conteneur à l'instanciation

- `CMD` : Commande unique lancée par le conteneur

- `ENTRYPOINT` : "Préfixe" de la commande unique lancée par le conteneur

### Dockerfile : best practices

- Bien choisir sa baseimage

- Chaque commande Dockerfile génère un nouveau layer

- Comptez vos layers !

### Dockerfile : best practices

- SCHEMA GOOD/BAD LAYERING

### Dockerfile : DockerHub

- Build automatisée d'images Docker

- Intégration GitHub / DockerHub

- Plateforme de stockage et de distribution d'images Docker

### Ship

### Ship : Les conteneurs sont manipulables

- Sauvegarder un conteneur :

```
docker commit mon-conteneur backup/mon-conteneur
```

```
docker run -it backup/mon-conteneur
```

- Exporter un conteneur :

```
docker save -o mon-image.tar backup/mon-conteneur
```

- Importer un conteneur :

```
docker import mon-image.tar backup/mon-conteneur
```

### Ship : Docker Registry

- DockerHub n’est qu’au Docker registry ce que GitHub est à git

- Pull and Push

- Permet de stocker des images Docker *On premises*

### Run

### Run : lancer un conteneur

- docker run

  - `-d` (detach)

  - `-i` (interactive)

  - `-t` (pseudo tty)

### Run : beaucoup d’options...

- `-v` /directory/host:/directory/container

- `-p` portHost:portContainer

- `-P`

- `-e` “VARIABLE=valeur”

- `–restart=always`

- `–name=mon-conteneur`

### Run : ...dont certaines un peu dangereuses

- `–privileged` (Accès à tous les devices)

- `–pid=host` (Accès aux PID de l’host)

- `–net=host` (Accès à la stack IP de l’host)

### Run : se “connecter” à un conteneur

- docker exec

- docker attach

### Run : Détruire un conteneur

- docker kill (SIGKILL)

- docker stop (SIGTERM puis SIGKILL)

- docker rm (détruit complètement)

### Build, Ship & Run : Conclusions

- Écosystème de gestion d'images

- Construction automatisée d'images

- Contrôle au niveau conteneurs

