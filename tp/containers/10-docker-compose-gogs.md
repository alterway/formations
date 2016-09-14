# Docker Compose

[Gogs](https://github.com/gogits/gogs) : Go Git Service

Par exemple dans le fichier `~/docker-compose/gogs/docker-compose.yaml` :

```
version: '2'
services:
    gogs_server:
        image: gogs/gogs
        container_name: gogs_server
        ports:
            - "3000:3000"
            - "10022:22"
        links:
            - gogs_db:mysql
        volumes:
            - gogs_server_data:/data
    gogs_db:
        image: mysql
        container_name: gogs_db
        volumes:
            - gogs_db_data:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=password
            - MYSQL_DATABASE=gogs
volumes:
  gogs_server_data:
    driver: local
  gogs_db_data:
    driver: local
```

Se placer dans le dossier :

```
# docker-compose up -d
Creating network "10dockercomposegogs_default" with the default driver
Creating volume "10dockercomposegogs_gogs_db_data" with local driver
Creating volume "10dockercomposegogs_gogs_server_data" with local driver
Creating gogs_db
Creating gogs_server
```

Vérifier les conteneur créés :

```
# docker-compose ps
   Name                  Command               State                       Ports
----------------------------------------------------------------------------------------------------
gogs_db       /entrypoint.sh mysqld            Up      3306/tcp
gogs_server   docker/start.sh /bin/s6-sv ...   Up      0.0.0.0:10022->22/tcp, 0.0.0.0:3000->3000/tcp
```

Trouver l'IP de la docker-machine :

```
# docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
default   *        virtualbox   Running   tcp://192.168.99.100:2376           v1.10.3
```

Accéder a l'URL de Gogs pour finaliser l'installation : `http://192.168.99.100:3000`

Destruction de la stack (l'option `-v` supprimer également les volumes persistent) :

```
# docker-compose down -v
Stopping gogs_server ... done
Stopping gogs_db ... done
Removing gogs_server ... done
Removing gogs_db ... done
Removing network 10dockercomposegogs_default
Removing volume 10dockercomposegogs_gogs_db_data
Removing volume 10dockercomposegogs_gogs_server_data
```
