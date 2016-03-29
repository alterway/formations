# TP 01 : Getting Started

## Prérequis

- Docker Toolbox (voir PDF envoyé au préalable)

## Lancement de l'environnement

Dans un terminal:

```
/Applications/Docker/Docker\ Quickstart\ Terminal.app/Contents/Resources/Scripts/start.sh
Running pre-create checks...
Creating machine...
(default) Copying /Users/lefevrek/.docker/machine/cache/boot2docker.iso to /Users/lefevrek/.docker/machine/machines/default/boot2docker.iso...
(default) Creating VirtualBox VM...
(default) Creating SSH key...
(default) Starting the VM...
(default) Check network to re-create if needed...
(default) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: /usr/local/bin/docker-machine env default


                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/


docker is configured to use the default machine with IP 192.168.99.100
For help getting started, check out the docs at https://docs.docker.com
```

Lister la machine Docker disponible:

```
docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.10.3
```

De base, les binaires docker sont configurés pour utiliser la machine *default*. Il est possible de se SSH sur la machine ou de piloter directement docker depuis Mac OS.

Depuis Mac OS :

```
docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

Depuis la machine Docker:

```
docker-machine ssh default                                                                                                                                 1
                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/
 _                 _   ____     _            _
| |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
| '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
| |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
|_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
Boot2Docker version 1.10.3, build master : 625117e - Thu Mar 10 22:09:02 UTC 2016
Docker version 1.10.3, build 20f81dd
docker@default:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
docker@default:~$
```

## Test des fonctionnalités de base

Lancer une baseimage depuis le Docker Hub:

```
docker run -it --rm alpine /bin/sh
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
4d06f2521e4f: Pull complete
Digest: sha256:7739b19a213f3a0aa8dacbd5898c8bd467e6eaf71074296a3d75824e76257396
Status: Downloaded newer image for alpine:latest
/ #
```

Lancer une image

