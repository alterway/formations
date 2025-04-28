Okay, here is the content of the `docker-fundamentals` file converted into Markdown format.
# ALTER WAY CLOUD CONSULTING

## A NOTE ON PEDAGOGY
Alter Way believes in learning by doing, with support. The course is lab driven with lecture.
*   Work together
*   Ask questions at any time
© 2025 Alter Way

## SESSION LOGISTICS
*   1 day duration
*   mostly exercises
*   regular breaks
© 2025 Alter Way

## ASSUMED KNOWLEDGE AND REQUIREMENTS
*   Familiarity with using the Linux command line
© 2025 Alter Way

## YOUR LAB ENVIRONMENT
You have been given an instance for use in exercises.
Ask instructor for details

Labs site : [https://bit.ly/docker-labs](https://bit.ly/docker-labs)

© 2025 Alter Way

## AGENDA
*   Fundamental Containerization
*   Fundamental Orchestration
*   ...plus other odds and ends.
© 2025 Alter Way

---
© 2025 Alter Way
Accèder aux labs
---

## INTRODUCING DOCKER
© 2025 Alter Way

### FRICTION IN THE SOFTWARE SUPPLY CHAIN
© 2025 Alter Way

---
© 2025 Alter Way
---

### DEPLOYMENT NIGHTMARE
© 2025 Alter Way

---
© 2025 Alter Way
---

### ANY APP, ANYWHERE
© 2025 Alter Way

### SECURITY
> “Gartner asserts that applications deployed in containers are more secure than applications deployed on the bare OS.”
© 2025 Alter Way

### SECURITY BREACHES
© 2025 Alter Way

> Voici la traduction en français :
> C'est ici que vit notre directeur de la sécurité. Son appartement est celui du troisième étage.
> • Au premier plan, nous voyons la voiture de son voisin. Malheureusement, une nuit, sa voiture a été forcée...
> • Pire encore, son garage a été forcé car la télécommande d'ouverture du garage se trouvait dans la voiture...
> • Et depuis le garage, les cambrioleurs sont entrés dans l'appartement du voisin...
> • Heureusement, de là, les voleurs n'ont pas pu entrer dans l'appartement de notre responsable de la sécurité car... les portes étaient verrouillées !
> • Des attaques en cascade similaires se produisent en informatique. Si un code malveillant parvient à compromettre un composant d'une application ou d'une solution, les pirates peuvent alors s'introduire dans d'autres composants ou les infecter à partir de là et, dans le pire des cas, obtenir un accès racine (root access) à l'ensemble du système.
> • Nous avons donc besoin d'une défense en profondeur. Nous devons verrouiller toutes les portes et n'autoriser l'accès qu'aux parties de confiance...

### WHAT DOES THIS HAVE TO DO WITH DOCKER...?
© 2025 Alter Way
Les applications dans les DC (datacenters) sont souvent compartimentées de la même manière que la maison décrite précédemment - et les attaques dont elles sont victimes peuvent se propager en cascade de façon similaire.

### WHAT DOES THIS HAVE TO DO WITH DOCKER...?
© 2025 Alter Way
Supposons que des pirates parviennent à compromettre l'interface Web (Web-frontend) de notre application, un point d'entrée fréquent.

### WHAT DOES THIS HAVE TO DO WITH DOCKER...?
© 2025 Alter Way
Mais avec une encapsulation suffisamment rigoureuse, associée à des paramètres de sécurité par défaut pertinents et prêts à l'emploi (out-of-the-box), la propagation vers des cibles plus importantes dans le centre de données peut être stoppée.
En fait, il est possible non seulement d'encapsuler un processus dans un conteneur, mais aussi de renforcer différemment chaque conteneur contre les attaques - de sorte que si une attaque réussit sur un conteneur, rien ne garantit qu'elle réussira sur un autre.

### SAFER APPLICATIONS
© 2025 Alter Way

*   La philosophie de sécurité de Docker est « Sécurisé par défaut » (Secure by Default). Cela signifie que la sécurité doit être inhérente à la plateforme pour toutes les applications et non une solution distincte qui nécessite d'être déployée, configurée et intégrée.
*   Aujourd'hui, Docker Engine prend en charge toutes les fonctionnalités d'isolation disponibles dans le noyau Linux.
*   De plus, Docker favorise une expérience utilisateur simple en mettant en œuvre des paramètres par défaut sûrs.

### ENCAPSULATION I: PHYSICAL SERVERS
One application, one physical server
© 2025 Alter Way

### ENCAPSULATION I: PHYSICAL SERVERS - LIMITS OF PHYSICAL ENCAPSULATION
*   Slow deployment
*   Huge costs
*   Provisioning speed limited by physical logistics
*   Difficult to scale
*   Difficult to migrate
*   Vendor lock-in
© 2025 Alter Way

### ENCAPSULATION II: VIRTUAL MACHINES
*   Multiple apps on one server
*   Elastic, real time provisioning
*   Scalable pay-per-use cloud models viable
© 2025 Alter Way

### ENCAPSULATION II: VIRTUAL MACHINES - VIRTUAL MACHINE LIMITATIONS
*   Virtual Machines require CPU & memory allocation
*   Significant overhead from guest OS
© 2025 Alter Way

### ENCAPSULATION III: CONTAINERS
Containers leverage kernel features to create extremely light-weight encapsulation:
*   Kernel namespaces
*   Network namespaces
*   Linux containers
*   cgroups & security tools

Results in faster spool-up and denser servers
© 2025 Alter Way

### FRAMEWORK FOR SERVICE ENCAPSULATION
The most basic thing Docker provides is a framework for service encapsulation.
But what are the implications of this for developers, ops, and orgs?
© 2025 Alter Way

### DISTRIBUTED APPLICATION ARCHITECTURE
Encapsulation supercharges:
*   Monolith Densification
*   Service-Based Architecture
*   Devops
© 2025 Alter Way

### MODERNIZE TRADITIONAL APPS
© 2025 Alter Way

---

# PART 1: CONTAINERS
© 2025 Alter Way

## CONTAINERIZATION FUNDAMENTALS
© 2025 Alter Way

### TOPICS
*   Containers under the hood
*   Starting, stopping and deleting containers
*   Inspecting containers
*   Executing processes inside running containers
© 2025 Alter Way

### CONTAINERS ARE PROCESSES
Containers are processes sandboxed by:
*   Kernel namespaces
*   Root privilege management
*   System call restrictions
*   Private network stacks
*   etc
© 2025 Alter Way

### KERNEL NAMESPACES
Kernel Namespaces virtualize system resources for groups of processes.
© 2025 Alter Way

### ROOT & SYSCALL PERMISSIONS
© 2025 Alter Way
*   Rappelons les objectifs de sécurité de Docker : rendre les conteneurs plus sécurisés par défaut. Les capacités root (privilèges administrateur) et les appels système constituent l'essentiel de la boîte à outils d'un attaquant.
*   Comme les conteneurs Docker ne sont en réalité que des processus, il est possible de restreindre, conteneur par conteneur, l'ensemble des privilèges root et des appels système qu'ils sont autorisés à effectuer.
*   De plus, chaque conteneur peut avoir un ensemble différent de privilèges autorisés/refusés, ce qui signifie qu'une attaque qui réussit depuis un conteneur ne sera pas nécessairement possible dans un autre.
*   Par exemple, le conteneur 1 dans la figure pourrait être un serveur web qui souhaite démarrer sur un port privilégié puis changer son UID (identifiant utilisateur) et son GID (identifiant de groupe) pour des valeurs dans l'espace utilisateur. Il a besoin de quelques capacités root pour cela, mais il n'a pas besoin de l'appel système ptrace().
*   En parallèle, le conteneur 2 pourrait exécuter un processus de débogage qui a effectivement besoin de `ptrace()`, mais n'a pas besoin des capacités root dont votre serveur web avait besoin.

### CONTAINER LIFECYCLE
© 2025 Alter Way

### CONTAINER LOGS
STDOUT and STDERR for a containerized process
```bash
docker container logs <container name>
```
© 2025 Alter Way

### EXERCISE: INSTALLING DOCKER ON LINUX
The recommended method is to install the packages supplied by Docker Inc :
*   add Docker Inc.'s package repositories to your system configuration
*   install the Docker Engine
Detailed installation instructions (distro by distro) are available on:
[https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/)

You can also install from binaries (if your distro is not supported):
[https://docs.docker.com/engine/installation/linux/docker-ce/binaries/](https://docs.docker.com/engine/installation/linux/docker-ce/binaries/)

To quickly setup a dev environment, Docker provides a convenience install script:
```bash
curl -fsSL get.docker.com | sh
```
© 2025 Alter Way

### EXERCISE: CONTAINER BASICS
Work through:
*   Running and Inspecting a Container
*   Interactive Containers
*   Detached Containers and Logging
*   Starting, Stopping, Inspecting and Deleting Containers
In the Docker Fundamentals Exercises book.
© 2025 Alter Way

### CONTAINER BASICS TAKEAWAYS
*   Single process with PID 1
*   Private & ephemeral filesystem and data
*   Syntax:
    *   `docker container run`
    *   `docker container rm`
    *   `docker container start`
    *   `docker container stop` & `docker container kill`
    *   `docker container exec`
    *   `docker container attach`
    *   `docker container logs`
    *   `docker container inspect`
    *   `docker container ls`
© 2025 Alter Way

---

## CREATING IMAGES
© 2025 Alter Way

### TOPICS
*   Layered filesystems
*   Creating images
*   Dockerfiles & best practice
*   Tagging, Namespacing & Sharing images
© 2025 Alter Way

### WHAT ARE IMAGES?
*   A filesystem for container process
*   Made of a stack of immutable layers
*   Start with a base image
*   New layer for each change
© 2025 Alter Way

### SHARING LAYERS
*   Faster download
*   Optimize disk and memory usage
*   Leverage local cache
© 2025 Alter Way

### THE WRITABLE CONTAINER LAYER
© 2025 Alter Way

### COPY ON WRITE
© 2025 Alter Way

### CREATING IMAGES
Three methods:
1.  Commit the R/W container layer as a new R/O image layer.
2.  Define new layers to add to a starting image in a Dockerfile.
3.  Import a tarball into Docker as a standalone base layer.
© 2025 Alter Way

### COMMITTING CONTAINER CHANGES
*   `docker container commit` saves container layer as new R/O image layer
*   Pro: build images interactively
*   Con: hard to reproduce or audit
© 2025 Alter Way

### EXERCISE: INTERACTIVE IMAGE CREATION
Work through the 'Interactive Image Creation' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### DOCKERFILES
*   Content manifest
*   Provides image layer documentation
*   Enables automation (CI/CD)
© 2025 Alter Way

### DOCKERFILES
*   `FROM` command defines base image.
*   Each subsequent command adds a layer
*   `docker image build ...` builds image from Dockerfile

```dockerfile
# Comments begin with the pound sign
FROM ubuntu:16.04

RUN apt-get update
ADD /data /myapp/data
...
```
© 2025 Alter Way

### EXERCISE: DOCKERFILES (1/2)
Work through the 'Creating Images with Dockerfiles (1/2)' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### BUILD OUTPUT
```
$ docker image build -t demo .
Sending build context to Docker daemon  2.048kB
Step 1/3 : FROM ubuntu:16.04
 ---> 7b9b13f7b9c0
Step 2/3 : RUN apt-get update
 ---> Running in 2e8333703768
...
Reading package lists...
 ---> 0fac7902d4d4
Removing intermediate container 2e8333703768
Step 3/3 : RUN apt-get install -y iputils-ping
 ---> Running in 3277108034a6
Reading package lists...
 ---> 9469b454b516
Removing intermediate container 3277108034a6
Successfully built 9469b454b516
Successfully tagged demo:latest
```
© 2025 Alter Way

### BUILD CONTEXT
*   Directory archive
*   Must contain all local files necessary for image
*   Will omit anything listed in `.dockerignore`

```bash
 docker image build -t demo .
Sending build context to Docker daemon	2.048kB
```
© 2025 Alter Way

### EXAMINING THE BUILD PROCESS
For each command:
1.  Launch a new container based on the image thus far
2.  Execute command in that container:
3.  Commit R/W layer to image
4.  Delete intermediate container:

```
Step 2/3 : RUN apt-get update
 ---> Running in 2e8333703768
 ---> 0fac7902d4d4
Removing intermediate container 2e8333703768
```
© 2025 Alter Way

### EXAMINING THE BUILD PROCESS
This:
```dockerfile
RUN cd /src
RUN bash setup.sh
```
is different than this:
```dockerfile
RUN cd /src && bash setup.sh
```
because every Dockerfile command runs in a different container, and only the filesystem, not the in-memory state, is persisted from layer to layer.
© 2025 Alter Way

### BUILD CACHE
After completion, the resulting image layer is labeled with a hash of the content of all current image layers in the stack.
© 2025 Alter Way

### CMD AND ENTRYPOINT
*   Recall all containers run a process as their PID 1
*   `CMD` and `ENTRYPOINT` allow us to specify default processes.
© 2025 Alter Way

### EXERCISE: DOCKERFILES (2/2)
Work through the 'Creating Images with Dockerfiles (2/2)' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### CMD AND ENTRYPOINT
*   `CMD` alone: default command and list of parameters.
*   `CMD` + `ENTRYPOINT`: `ENTRYPOINT` provides command, `CMD` provides default parameters.
*   `CMD` overridden by command arguments to `docker container run`
*   `ENTRYPOINT` overridden via `--entrypoint` flag to `docker container run`.
© 2025 Alter Way

### SHELL VS. EXEC FORMAT
```dockerfile
# Shell form
ENTRYPOINT sudo -u ${USER} java ...

# Exec form
ENTRYPOINT ["sudo", "-u", "jdoe", "java", ...]
```
© 2025 Alter Way

### COPY AND ADD COMMANDS
*   `COPY` copies files from build context to image: `COPY <src> <dest>`
*   `ADD` can also untar and fetch URLs.
*   In both cases:
    *   create checksum for files added
    *   log checksum in build cache
    *   Cache invalidated if checksum changed
© 2025 Alter Way

### ENV COMMANDS
*   `ENV` sets environment variables inside container:
    ```dockerfile
    ENV APP_PORT 8080
    ```
*   Many more Dockerfile commands are available; see the docs at [https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/)
© 2025 Alter Way

### "IT WORKS ON MY LAPTOP, I SWEAR!"
A perfectly healthy Java app will break when migrated to a new environment if:
*   Missing JDK / JVM
*   Wrong versions of JDK or JVM
*   Missing libraries
*   Wrong versions of libraries

Capturing all dependencies and environment setup steps in a Dockerfile is the easiest way to make your application reliably portable.
© 2025 Alter Way

### OPTIMIZING IMAGE CONSTRUCTION
© 2025 Alter Way

### MULTI STAGE BUILDS 1/2
Hello World, in C:
```dockerfile
FROM alpine:3.5
RUN apk update && \
    apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
ADD hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello
CMD /app/bin/hello
```
Result:
```
REPOSITORY   TAG      IMAGE ID       CREATED        SIZE
hwc          latest   142c29686b6a   15 hours ago   184 MB
```
© 2025 Alter Way

### MULTI STAGE BUILDS 2/2
Hello World lightweight, in C:
```dockerfile
FROM alpine:3.5 AS build # Full SDK version (built and discarded)
RUN apk update && \
    apk add --update alpine-sdk
RUN mkdir /app
WORKDIR /app
ADD hello.c /app
RUN mkdir bin
RUN gcc -Wall hello.c -o bin/hello

# Lightweight image returned as final product
FROM alpine:3.5
COPY --from=build /app/bin/hello /app/hello
CMD /app/hello
```
Result:
```
REPOSITORY   TAG      IMAGE ID       CREATED          SIZE
hwc          latest   5d925cfc9c96   39 seconds ago   4MB
```
© 2025 Alter Way

### BUILD TARGETS
```dockerfile
FROM <base image> as base
...

FROM <foo image> as foo
...

FROM <bar image> as bar
...

FROM alpine:3.4
...
COPY --from foo ...
COPY --from bar ...
...
```
Building the image:
```bash
docker image build --target <name> ...
```
© 2025 Alter Way

### BUILDKIT
*   Speed-optimized builder, enable via export
    ```bash
    export DOCKER_BUILDKIT=1
    ```
*   Parallelizes multi-stage builds
*   Custom frontends
*   2x - 9x build speedup
*   Linux only as of 18.09.0-ee
© 2025 Alter Way

### EXERCISE: DOCKERIZING AN APPLICATION
Work through the 'Dockerizing an Application' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### DOCKERFILE BEST PRACTICES: LAYERS
*   Start with official images
*   Combine commands
*   Single ENTRYPOINT
© 2025 Alter Way

### DOCKERFILE BEST PRACTICES: CACHING
The cache is busted from the point in the Dockerfile where:
*   Anything explicitly changes
*   Anything implicitly changes:
© 2025 Alter Way

### DOCKERFILE BEST PRACTICES: CACHING
**Bad:**
```dockerfile
FROM alpine
RUN <install every dependency>
RUN <compile app 1>
RUN <compile app 2>
```
**Good:**
```dockerfile
FROM alpine
RUN <install app 1 deps>
RUN <compile app 1>
RUN <install app 2 deps>
RUN <compile app 2>
```
© 2025 Alter Way

### DOCKERFILE BEST PRACTICES: CACHING
**Bad:**
```dockerfile
COPY /mypy /app/
...
FROM python:3.5-alpine
RUN mkdir /app

RUN pip install -r app/reqs.txt
...
```
**Good:**
```dockerfile
COPY /mypy/reqs.txt /app/
...
FROM python:3.5-alpine
RUN mkdir /app

RUN pip install -r app/reqs.txt
COPY /mypy /app/
...
```
© 2025 Alter Way

### IMAGE TAGS
*   Optional string after image name, separated by `:`
*   `:latest` by default
*   Same image with two tags shares same ID, image layers:

```bash
$ docker image ls centos*
REPOSITORY   TAG     IMAGE ID       CREATED      SIZE
centos       7       8140d0c64310   7 days ago   193 MB

$ docker image tag centos:7 centos:mytag

$ docker image ls centos*
REPOSITORY   TAG     IMAGE ID       CREATED      SIZE
centos       7       8140d0c64310   7 days ago   193 MB
centos       mytag   8140d0c64310   7 days ago   193 MB
```
© 2025 Alter Way

### IMAGE NAMESPACES
Images exist in one of three namespaces:
1.  **Root** (`ubuntu`, `nginx`, `mongo`, `mysql`, ...)
2.  **User / Org** (`jdoe/myapp:1.1`, `tutum/mongodb:latest`, ...)
3.  **Registry** (`FQDN/jdoe/myapp:1.1`, ...)

Root and User/Org indicate images distributed on store.docker.com; Registry namespacing indicates a Docker Trusted Registry image.
© 2025 Alter Way

### IMAGE TAGGING & NAMESPACING
*   Tag on build: `docker image build -t myapp:1.0 .`
*   Retag an existing image: `docker image tag myapp:1.0 me/myapp:2.0`
*   Note `docker image tag` can set both tag and namespace.
© 2025 Alter Way

### SHARING IMAGES
*   Log in to store.docker.com: `docker login`
*   Share an image: `docker image push <image name>`
*   Public repos available for anyone to `docker pull`.
© 2025 Alter Way

### EXERCISE: MANAGING IMAGES
Work through the 'Managing Images' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### IMAGE CREATION TAKEAWAYS
*   Images are built out of read-only layers.
*   Dockerfiles specify image layer contents.
*   Key Dockerfile commands: `FROM`, `RUN`, `COPY` and `ENTRYPOINT`
*   Images must be namespaced according to where you intend on sharing them.
© 2025 Alter Way

---

## DOCKER SYSTEM COMMANDS
© 2025 Alter Way

### CLEAN-UP COMMANDS
*   `docker system df`
*   `docker system prune`
*   more limited...
    *   `docker image prune`
    *   `docker container prune`
    *   `docker volume prune`
    *   `docker network prune`

Example output of `docker system df`:
```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          39        2         9.01 GB   7.269 GB (80%)
Containers      2         2         69.36 MB  0 B (0%)
Local Volumes   0         0         0 B       0 B
```
© 2025 Alter Way

### INSPECT THE SYSTEM
`docker system info`
```
Containers: 2
 Running: 2
 Paused: 0
 Stopped: 0
Images: 105
Server Version: 17.03.0-ee
Storage Driver: overlay2
 Backing Filesystem: extfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host ipvlan macvlan null overlay
Swarm: active
 NodeID: ybmqksh6fm627armruq0e8id1
 Is Manager: true
 ClusterID: 2rbf1dv6t5ntro2fxbry6ikr3
 Managers: 1
 Nodes: 1
 Orchestration:
  Task History Retention Limit: 5
 Raft:
  Snapshot Interval: 10000
  Number of Old Snapshots to Retain: 0
  Heartbeat Tick: 1
...
```
© 2025 Alter Way

### SYSTEM EVENTS
Start observing with ...
```bash
docker system events
```
Generate events with ...
```bash
docker container run --rm alpine echo 'Hello World!'
```
Example output:
```
2017-01-25T16:57:48.553596179-06:00 container create 30eb630790d44052f26c1081...
2017-01-25T16:57:48.556718161-06:00 container attach 30eb630790d44052f26c1081...
2017-01-25T16:57:48.698190608-06:00 network connect de1b2b40f522e69318847ada3...
2017-01-25T16:57:49.062631155-06:00 container start 30eb630790d44052f26c1081d...
2017-01-25T16:57:49.164526268-06:00 container die 30eb630790d44052f26c1081dbf...
2017-01-25T16:57:49.613422740-06:00 network disconnect de1b2b40f522e69318847a...
2017-01-25T16:57:49.815845051-06:00 container destroy 30eb630790d44052f26c108...
```
© 2025 Alter Way

### EXERCISE: SYSTEM COMMANDS
Work through:
*   Cleaning up Docker Resources
*   Inspection Commands
in the Docker Fundamentals Exercises book.
© 2025 Alter Way

---

## DOCKER VOLUMES
© 2025 Alter Way

### TOPICS
*   Creating & deleting volumes
*   Mounting volumes
*   Inspecting volumes
*   Sharing volumes
© 2025 Alter Way

### VOLUMES
*   Persist when a container is deleted
*   Can be shared between containers
*   Separate from the union file system
© 2025 Alter Way

### DOCKER VOLUME COMMAND
`docker volume` sub-commands:
*   `docker volume create --name demo`
*   `docker volume ls`
*   `docker volume inspect demo`
*   `docker volume rm demo`
*   `docker volume prune`
© 2025 Alter Way

### MOUNT A VOLUME
*   Mounted at container startup
*   Syntax: `docker container run -v [name]:[path in container FS] …`
*   Example:
    ```bash
    # Execute a new container and mount the volume test1 in the folder /www/test1
    docker container run -it -v test1:/www/test1 ubuntu:16.04 bash
    ```
© 2025 Alter Way

### WHERE ARE OUR VOLUMES?
*   Use `docker container inspect` or `docker volume inspect`.
*   Look for the "Source" (in container inspect) or "Mountpoint" (in volume inspect) field.
© 2025 Alter Way

### DOCKER VOLUME INSPECT COMMAND
*   The `docker volume inspect` command shows all the information about a specified volume.
*   Information includes the “Mountpoint” which tells us where the volume is located on the host.
© 2025 Alter Way

### DELETING A VOLUME
*   Note the `-v` option: volumes not automatically deleted when deleting a container unless specified.
    ```bash
    # Delete the volume called test1
    docker volume rm test1

    # Delete a container and remove its associated anonymous volumes
    docker container rm -v <container ID>
    ```
    *(Note: `docker container rm -v` only removes anonymous volumes associated *solely* with that container. Named volumes are *not* removed.)*
© 2025 Alter Way

### DELETING VOLUMES
*   Cannot delete a volume if it is being used by a container (running or stopped).
*   `docker container rm -v <container ID>` will not delete a named volume associated with the container, nor an anonymous volume if that volume is mounted in another container.
© 2025 Alter Way

### EXERCISE: CREATING AND MOUNTING VOLUMES
Work through the 'Creating and Mounting Volumes' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### MOUNTING HOST DIRECTORIES (Bind Mounts)
*   Can map directories on the host to a container path.
*   Changes made on the host are reflected inside the container (and vice-versa if writable).
*   Syntax: `docker container run -v [host path]:[container path]:[rw|ro]`
*   `rw` or `ro` controls the write status of the directory inside the container.
*   Example:
    ```bash
    # Mount the contents of the public_html directory on the
    # host to the container volume at /data/www
    docker container run -d -v /home/user/public_html:/data/www:rw ubuntu
    ```
© 2025 Alter Way

### INSPECTING THE MAPPED DIRECTORY
Use `docker container inspect <container ID>` and look in the `Mounts` section for `"Type": "bind"`. The `Source` will be the host path and `Destination` the container path.
© 2025 Alter Way

### USE CASES FOR MOUNTING HOST DIRECTORIES
*   Storage management (using specific host storage)
*   Rapid updates (e.g., code development where changes on host are immediately available in container)
© 2025 Alter Way

### SHARING DATA BETWEEN CONTAINERS
*   Volumes can be mounted into multiple containers.
*   Allows data to be shared between containers.
*   Example use cases: databases sharing data directories, logging containers accessing application log volumes.
*   Note: Be aware of potential conflicts (multiple processes writing) and security implications!
© 2025 Alter Way

### EXERCISE: RECORDING LOGS
Work through the Volumes Usecase: 'Recording Logs' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### VOLUMES IN DOCKERFILES
*   `VOLUME` instruction creates a mount point for an anonymous volume.
*   Can specify arguments in a JSON array or string.
*   Cannot map volumes to host directories directly in Dockerfile.
*   Volumes are initialized (if empty) when the container is executed from the image content at that path.
*   Examples:
    ```dockerfile
    # String example
    VOLUME /myvol

    # String example with multiple volumes
    VOLUME /www/website1 /www/website2

    # JSON example
    VOLUME ["/myvol", "/myvol2"]
    ```
© 2025 Alter Way

### EXAMPLE DOCKERFILE WITH VOLUMES
Volume initialized along with data on `docker container run ...` if the volume is new/empty.
```dockerfile
FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y vim wget

# Create directory and initial content (will be copied to volume if volume is new)
RUN mkdir /data/myvol -p && echo "hello world" > /data/myvol/testfile

VOLUME ["/data/myvol"]
```
© 2025 Alter Way

### INSPECTING AN IMAGE FOR VOLUMES
`docker image inspect <Image ID>` - Look for the `Volumes` key in the `Config` section.
© 2025 Alter Way

### DOCKER VOLUME TAKEAWAYS
*   Volumes are for persistent data.
*   Volumes bypass the copy-on-write system.
*   A volume persists even after its container has been deleted.
© 2025 Alter Way

---

## DOCKER PLUGINS
© 2025 Alter Way

### PLUGINS
*   Extend the Docker platform
*   Distributed as Docker images
*   Hosted on store.docker.com (Docker Hub)
*   List plugins on system:
    ```bash
    $ docker plugin ls
    ID                  NAME                    DESCRIPTION              ENABLED
    bee424413706        vieux/sshfs:latest      sshFS plugin for Docker  true
    ```
© 2025 Alter Way

### INSTALL A PLUGIN
```bash
$ docker plugin install tiborvass/rexray-plugin
Plugin "tiborvass/rexray-plugin" is requesting the following privileges:
 - network: [host]
 - mount: [/dev]
 - allow-all-devices: [true]
 - capabilities: [CAP_SYS_ADMIN]
Do you grant the above permissions? [y/N] y
latest: Pulling from tiborvass/rexray-plugin
abd92ccefc91: Download complete
Digest: sha256:df5dbbb15a797102741d1991ecf4b8015b118e563edcba1b4274552fe2481be7
Status: Downloaded newer image for tiborvass/rexray-plugin:latest
Installed plugin tiborvass/rexray-plugin
```
© 2025 Alter Way

### USING THE PLUGIN
Create a volume (using the plugin's driver)...
```bash
docker volume create -d tiborvass/rexray-plugin my-volume
```
Use the volume...
```bash
# Example assuming vieux/sshfs plugin was installed and configured
# docker volume create -d vieux/sshfs -o sshcmd=user@host:/path -o password=SECRET sshvolume
docker container run --rm -it \
  -v sshvolume:/shared \
  busybox ls -al /shared
```
*(Note: The example command uses `tiborvass/rexray-plugin` for install but `vieux/sshfs` for usage. Adjusted the usage example slightly for clarity, assuming an sshfs plugin like `vieux/sshfs`)*
© 2025 Alter Way

### EXERCISE: PLUGINS
Work through the 'Docker Plugins' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

---

## CONTAINERIZATION FUNDAMENTALS CONCLUSION: ANY APP, ANYWHERE.
*   Containers are isolated processes
*   Images provide filesystem for containers
*   Volumes persist data
© 2025 Alter Way

---

# PART 2: ORCHESTRATION
© 2025 Alter Way

## DOCKER NETWORKING BASICS
© 2025 Alter Way

### TOPICS
*   Bridge networks
*   Overlay Networks
*   Network firewalling
*   Port management
© 2025 Alter Way

### THE CONTAINER NETWORK MODEL
© 2025 Alter Way

### SINGLE HOST NETWORKING
*   **Sandbox:** Kernel Namespace
*   **Endpoint:** Virtual ETHernet port (`veth`)
*   **Network:** Linux Bridge (`docker0` by default), an L2 (i.e., MAC address) packet router

`docker0` is the default container network bridge.
© 2025 Alter Way

### SINGLE HOST NETWORKING
*(Diagram placeholder)*
© 2025 Alter Way

### NETWORK FIREWALLS
*(Diagram placeholder showing separation)*
© 2025 Alter Way

### NETWORK FIREWALLS
Connecting a container to a specific bridge:
```bash
docker network connect my_bridge u2
```
*(Diagram placeholder showing connection)*
© 2025 Alter Way

### EXERCISE: INTRODUCTION TO CONTAINER NETWORKING
Work through the 'Introduction to Container Networking' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### SECURITY WARNINGS
*   Do not use the `host` network in production unless absolutely necessary and understood.
*   Do not connect containers to the same network unnecessarily (principle of least privilege).
© 2025 Alter Way

### MULTI-HOST NETWORKING (Overlay Networks)
*(Conceptual placeholder)*
© 2025 Alter Way

### EXPOSING CONTAINER PORTS
*   Containers have no public IP address by default; reachable only locally via their host's linux bridge or other containers on the same Docker network.
*   Can map a container port to a host port to allow external reachability.
*   Ports can be mapped manually (`-p HOST_PORT:CONTAINER_PORT`) or automatically (`-P`).
*   Port mappings visible via `docker container ls` or `docker container port <container>`.
© 2025 Alter Way

### EXERCISE: CONTAINER PORT MAPPING
Work through the 'Container Port Mapping' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### DOCKER NETWORKING TAKEAWAYS
*   Single host: uses linux bridge networks (`bridge` driver).
*   Multi-host: uses VXLAN overlay networks (`overlay` driver, typically in Swarm mode).
*   Separate Docker networks are firewalled from each other by default.
*   Containers are firewalled from the outside world by default, but can expose ports on the host.
© 2025 Alter Way

---

## INTRODUCTION TO DOCKER COMPOSE
© 2025 Alter Way

### TOPICS
*   Services
*   Defining Application with Docker Compose
*   Scaling Applications
© 2025 Alter Way

### DISTRIBUTED APPLICATION ARCHITECTURE
*   Applications consisting of one or more containers across one or more nodes
*   Docker Compose facilitates multi-container application definition and management on a *single* node.
© 2025 Alter Way

### DOCKER SERVICES (in context of Compose/Swarm)
*   **Containers:**
    *   (meant to be) lightweight
    *   easy to start and stop
    *   fundamentally just a process
*   **Services:**
    *   defines desired state of a collection of container replicas
    *   is a self healing (in Swarm) & scalable collection of containers
    *   is based on single image
© 2025 Alter Way

### DOCKERCOINS
It is a DockerCoin miner! Dockercoins consists of 5 services working together:
*(Diagram placeholder)*
© 2025 Alter Way

### OUR SAMPLE APPLICATION
*   [https://github.com/docker-training/orchestration-workshop](https://github.com/docker-training/orchestration-workshop)
*   The application is in the `dockercoins` subdirectory
*   Each service has its own subdirectory & Dockerfile
© 2025 Alter Way

### DOCKER-COMPOSE.YML
*   Applications are built around the concept of services.
*   `docker-compose.yml`: manifest of services and peripherals (networks, volumes).
© 2025 Alter Way

### SERVICE DISCOVERY (in Compose)
*   Containers on the same Compose-managed network can reach each other using the service name as a hostname.
*   Compose provides DNS resolution for service names.
*   Our code can connect to services using their short name (instead of e.g. IP address or FQDN).
© 2025 Alter Way

### EXAMPLE IN WORKER/WORKER.PY
*(Code snippet placeholder, likely showing connection to another service like 'redis' or 'rng' using the service name)*
© 2025 Alter Way

### EXERCISE: STARTING A COMPOSE APP
Work through the 'Starting a Compose App' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### CONNECTING TO THE WEB UI
*   webui dashboard: `http://[IP]:8000/`
*   Looks like about 3.33 coins/second.
© 2025 Alter Way

### SCALING UP THE APPLICATION
*   Want higher performance
*   Need to determine bottlenecks
*   Common UNIX tools to the rescue!
© 2025 Alter Way

### LOOKING AT RESOURCE USAGE
*   `top` (you should see idle cycles)
*   `vmstat 3` (the 4 numbers `r b w swpd` should be almost zero, except `bo` for logging output)
*   We have available resources; how can we use them?
© 2025 Alter Way

### EXERCISE: SCALING A COMPOSE APP
Work through the 'Scaling a Compose App' exercise in the Docker Fundamentals Exercises book. (Likely using `docker-compose up --scale service_name=N`)
© 2025 Alter Way

### DOCKER COMPOSE TAKEAWAYS
*   Docker Compose makes single node multi-container application definition easy.
*   Docker Compose makes scaling services (replicas) on that single node easy.
*   Bottleneck identification important for effective scaling.
*   Syntactically: `docker-compose.yml` manifest + `docker-compose` CLI commands.
© 2025 Alter Way

---

## INTRODUCTION TO SWARM MODE
© 2025 Alter Way

### TOPICS
*   Swarmkit
*   Services and Tasks
*   Creating Swarms
*   Manager & Worker Coordination
*   Routing Mesh
*   Swarm Scheduling
*   Service Upgrades
© 2025 Alter Way

### DISTRIBUTED APPLICATION ARCHITECTURE
*   Applications consisting of one or more containers across one or more nodes
*   Docker Swarm mode facilitates multi-node orchestration.
*   Also supports multiple interacting services (like Compose, often using Compose file format v3+).
© 2025 Alter Way

### A TYPICAL SWARM
*(Diagram placeholder showing manager(s) and worker nodes)*
© 2025 Alter Way

### SECURE BY DEFAULT
*   All manager communication is automatically mutually TLS encrypted.
*   First Swarm manager creates root CA.
*   Root CA signs certificates for all subsequent nodes joining the swarm.
*   Keys and certs rotated automatically (default: every 90 days).
© 2025 Alter Way

### KEY CONCEPTS - SERVICES
*   **Service:** Defines the desired state of container replicas based on a given image.
*   Primary point of user interaction with the swarm (`docker service create`, `docker service update`, etc.).
*   Scheduler tries to automatically maintain the desired state (e.g., number of replicas) of all services.
© 2025 Alter Way

### KEY CONCEPTS - TASKS
*   A **Task** represents a unit of work assigned to a node.
*   One task = one container (instance of a service).
*   Atomic scheduling unit of swarm. Managers assign tasks to workers.
© 2025 Alter Way

### SWARMS & SERVICES
*(Diagram placeholder showing a service definition leading to tasks/containers on nodes)*
© 2025 Alter Way

### SWARMS & SERVICES
*(Diagram placeholder showing service scaling)*
© 2025 Alter Way

### RECOVERING FROM NODE FAILURE
Initial state:
```bash
docker service create --replicas 3 --name myapp --network mynet --publish 80:80 myapp:1.0
```
*(Diagram placeholder showing 3 replicas across nodes)*
© 2025 Alter Way

### RECOVERING FROM NODE FAILURE
After a node fails:
*   Swarm manager detects the node failure.
*   Swarm will schedule a new task on a healthy node in order to create a replacement container, restoring the desired state of 3 replicas.
*(Diagram placeholder showing one node down, a new replica started on another node)*
© 2025 Alter Way

### SWARMKIT
*   Open source toolkit used by Docker Swarm mode to build multi-node systems.
*   SwarmKit comes with components for:
    *   Distributed state store (Raft)
    *   Scheduling
    *   Node management
    *   Security (TLS, CA)
*   Project repository: [https://github.com/docker/swarmkit](https://github.com/docker/swarmkit)
*   Full features list: [https://docs.docker.com/engine/swarm/](https://docs.docker.com/engine/swarm/)
*   100% Docker native orchestration.
© 2025 Alter Way

### EXERCISE: SWARMS & SERVICES
Work through:
*   Creating a Swarm (`docker swarm init`, `docker swarm join`)
*   Starting a Service (`docker service create`)
*   Node Failure Recovery (Observing rescheduling)
in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### UNDER THE HOOD - SWARM INIT
When we first run `docker swarm init`:
*   current node enters Swarm Mode as manager-leader
*   listens for workers on TCP port `:2377`
*   prepares to accept tasks from the scheduler
*   starts an internal distributed data store (Raft) for cluster state (networks, services, nodes, secrets, configs)
*   generates a self-signed root CA for the swarm
*   generates join tokens for worker and manager nodes
*   creates an overlay network named `ingress` for external traffic inbound to published service ports
*   ... and a whole lot more.
© 2025 Alter Way

### SWARM MODE NETWORK TOPOLOGY
*   Manager nodes should have fixed IP addresses if possible (for worker join stability).
*   Open ports between your hosts:
    *   **TCP port 2377:** Cluster management communications (manager <-> manager, workers connect here initially)
    *   **TCP and UDP port 7946:** Container network discovery (node <-> node communication)
    *   **UDP port 4789:** Container overlay network traffic (VXLAN)
© 2025 Alter Way

### BEHIND THE SCENES: SERVICE MANAGEMENT
*(Diagram placeholder showing manager coordinating tasks on workers)*
© 2025 Alter Way

### SERVICES & THE OUTSIDE WORLD
Services can be exposed to the web on a host port (`--publish`), with two special properties:
1.  The public port is available on *every* node of the Swarm - even ones that aren't running a task for that service (This is the Routing Mesh).
2.  Requests coming in on the public port are load balanced across all healthy tasks (containers) for that service.
© 2025 Alter Way

### THE ROUTING MESH
```bash
docker service create --replicas 2 --publish 80:80 --name webapp webapp:1.0
```
*(Diagram placeholder showing external request hitting any node on port 80, being routed internally via IPVS to one of the two running tasks on potentially different nodes)*
© 2025 Alter Way

### EXERCISE: LOAD BALANCING & THE ROUTING MESH
Work through the 'Load Balancing & the Routing Mesh' exercise in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### OUR APPLICATION: DOCKERCOINS
It is a DockerCoin miner! Dockercoins consists of 5 services working together:
*(DockerCoins 2016 logo courtesy of @XtlCnslt and @ndeloof. Thanks!)*
*(Diagram placeholder)*
© 2025 Alter Way

### SWARMING OUR APP: STACKS
*   A **Stack** is a collection of related services, networks, and volumes.
*   Uses `docker-compose.yml` v3.x format as the manifest file.
*   Deployed and managed using `docker stack deploy` and `docker stack rm`.
*   Can specify replicas, networks, volumes, placement constraints, update policies, etc. within the compose file for Swarm deployment.
© 2025 Alter Way

### SCALING & SCHEDULING SERVICES
*   Default scheduling strategy is `replicated`: run a specified number of tasks (`--replicas N`). Swarm distributes these across available nodes.
*   Improve performance by adding more replicas (`docker service scale service_name=N`).
*   Ingress routing mesh (external) and internal DNS/VIPs (internal) load balance across tasks.
*   Works best with stateless containers.
*   Alternative scheduling strategy is `global`: run exactly one task on *every* eligible node in the swarm (useful for agents, monitoring).
© 2025 Alter Way

### UPDATING SERVICES
*   Apps get periodic updates (new image versions, config changes).
*   Want updates with minimal service interruption.
*   Swarm mode provides tooling for rolling updates:
    *   Specify update parallelism (`--update-parallelism`)
    *   Specify update delay (`--update-delay`)
    *   Specify action on failure (`--update-failure-action`: `pause` (default) or `continue`, `rollback`)
    *   Manual rollback (`docker service rollback`)
© 2025 Alter Way

### EXERCISE: APPLICATION DEPLOYMENT
Work through:
*   Dockercoins On Swarm (using `docker stack deploy`)
*   Scaling and Scheduling Services (`docker service scale`, observe placement)
*   Updating a Service (`docker service update --image ...`)
in the Docker Fundamentals Exercises book.
© 2025 Alter Way

### SWARM DETAILS: NODE CONSTRAINTS
Place tasks on nodes matching specific labels (engine labels or node labels).
```bash
# Assuming nodes have been labeled, e.g., docker node update --label-add com.example.storage=ssd node1
docker service create --replicas 3 --name myapp \
  --network mynet --publish 80:80 \
  --constraint 'node.labels.com.example.storage == ssd' myapp:1.0
```
© 2025 Alter Way

### SWARM DETAILS: SERVICE LOAD BALANCING
*   Network requests for service names (internal communication) resolve to a Virtual IP (VIP).
*   Traffic sent to the VIP is internally load balanced by the kernel's IPVS module across all healthy tasks for the service.
*   DNSRR (DNS Round Robin) is also available as an alternative endpoint mode. Returns multiple IPs (task IPs) instead of a single VIP.
*   Default is now VIP.
*   Specify on service creation or update:
    ```bash
    docker service create --endpoint-mode [vip|dnsrr] ...
    ```
© 2025 Alter Way

### SWARM MODE ROBUSTNESS
It doesn't matter:
*   which node a container runs on
*   if a few nodes die (if you have sufficient replicas/manager redundancy)
*   if interacting processes are on different nodes
*   which nodes are running user-facing containers (thanks to routing mesh)
... everything will still work (within the bounds of configured availability).
© 2025 Alter Way

### SWARM MODE TAKEAWAYS
*   Orchestrates distributed applications across infrastructure.
*   Provides high availability features (replication, rescheduling).
*   Self-healing service definitions (maintains desired state).
*   Default security via mutual TLS encryption & automatic certificate rotation.
*   Simple service discovery (DNS/VIP) & load balancing (Routing Mesh/IPVS).
© 2025 Alter Way

---

## DOCKER SECRETS
© 2025 Alter Way

### WHAT IS A SECRET?
*(Conceptual placeholder - things like passwords, API keys, TLS certificates)*
© 2025 Alter Way

### MOTIVATION FOR SECRETS
Challenges in distributed systems:
*   Secrets can be accidentally embedded in source code in GitHub/version control.
*   Secrets need to be securely distributed to nodes/containers in orchestration systems.
*   Secrets could be tampered with or intercepted in transit.
© 2025 Alter Way

### SECRETS USE CASE
Manage services with sensitive information in Docker Swarm such as:
*   passwords
*   TLS certificates
*   private keys
*   API tokens
*   and more...
© 2025 Alter Way

### SECRETS WORKFLOW 1: CREATION & STORAGE
*   Secrets are created via `docker secret create` or defined in stack files.
*   Transmitted over mutual TLS to manager nodes.
*   Stored encrypted at rest in the Swarm's distributed Raft datastore.
*   Part of the Raft datastore means they are Highly Available (HA) along with manager quorum.
*   Access control can be managed via service definitions (which service can access which secret).
© 2025 Alter Way

### SECRETS WORKFLOW 2: DISTRIBUTION
*   Secret access is granted per service (`--secret` flag on `docker service create/update`).
*   Managers propagate secrets (securely over TLS) *only* to the nodes running tasks for services that need them ("Least Privilege").
*   Secrets are mounted unencrypted into the container's filesystem as an in-memory `tmpfs` mount at `/run/secrets/<secret_name>`.
*   The `tmpfs` mount is deleted from the container when the task stops or the service loses access to the secret.
© 2025 Alter Way

### SECRETS WORKFLOW 3: SECRET USAGE
*(Diagram placeholder showing an application reading a file from /run/secrets/ inside the container)*
© 2025 Alter Way

### EXERCISE: SECRETS
Work through the 'Docker Secrets' exercise in the Docker Fundamentals Exercise book.
© 2025 Alter Way

---

## FUNDAMENTAL ORCHESTRATION TAKEAWAYS
*   Distributed Application Architecture orchestrates one or more containers across one or more nodes.
*   Docker Swarm mode and Docker Compose provide native node and container orchestration support (Swarm for multi-node, Compose primarily for single-node definition but usable with Swarm stacks).
*   Services, Swarms and Stacks enhance scalability, availability, and manageability.
© 2025 Alter Way

---

# DOCKER FUNDAMENTALS END
© 2025 Alter Way