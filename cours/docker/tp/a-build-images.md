---

# builder une première image

## SALE

- docker pull ubuntu:14.04
- docker run -it --name test ubuntu:14.04 /bin/bash
créer un fichier quelconque
- ctrl + p, ctrl + q
- docker ps
vérifier que le container existe
- docker commit test local/test
- docker run -it local/test /bin/bash
vérifier que le fichier est toujours présent

## PROPRE

Dockerfile

FROM ubuntu:14.04
RUN touch toto

docker build -t local/test2 .

- docker run -it local/test /bin/bash
vérifier que le fichier est toujours présent

## Construire une image Etherpad

Paquets nécessaires :
- gzip
- git
- curl
- python
- libssl-dev
- pkg-config
- build-essential
- nodejs

Repo git : git clone git://github.com/ether/etherpad-lite.git

Exécutable : bin/run.sh
