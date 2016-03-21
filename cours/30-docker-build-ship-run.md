# Build, Ship and Run !

### Build

### Le conteneur et son image

- Flexibilité et élasticité

- Format standard

- Instanciation illimitée

### Dockerfile

- Définition d'une image

- Permet de vérifier le contenu d'une image

```
FROM alpine:3.2
MAINTAINER Romain Guichard <rgu@osones.io>
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

### Best Practices des Dockerfile

- Bien choisir sa baseimage

- Comptez vos layers !

- schéma montrant les pb de tailles dues à une baseimage de merde

### Présentation de DockerHub

- Intégration GitHub / DockerHub

- screenshot

### Ship

### Les conteneurs sont indépendants !

- Sauvegarder un conteneur :

`docker commit mon-conteneur backup/mon-conteneur`

`docker run -it backup/mon-conteneur`

- Exporter un conteneur :

`docker save -o mon-image.tar backup/mon-conteneur`

- Importe un conteneur :

`docker import mon-image.tar backup/mon-conteneur`

### Docker Registry

- DockerHub n’est qu’au Docker registry ce que GitHub est à git

- Pull and Push

### Run

### Lancer un conteneur

- docker run

  - `-d` (detach)

  - `-i` (interactive)

  - `-t` (pseudo tty)

### avec beaucoup d’options...

- `-v` /directory/host:/directory/container

- `-p` portHost:portContainer

- `-P`

- `-e` “VARIABLE=valeur”

- `–restart=always`

- `–name=mon-conteneur`

### ...dont certaines un peu dangereuses

- `–privileged` (Accès à tous les devices)

- `–pid=host` (Accès aux PID de l’host)

- `–net=host` (Accès à la stack IP de l’host)

### Se “connecter” à un conteneur

- docker exec

- docker attach

### Détruire un conteneur

- docker kill (SIGKILL)

- docker stop (SIGTERM puis SIGKILL)

- docker rm (détruit complètement)

