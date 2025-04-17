<!--
author:   Hervé Leclerc

email:    herve.leclerc@alterway.fr

version:  1.0.0

language: en

narrator: US English Male

comment:  Courss Docker Fundamentals

logo: https://assets.alterway.fr/2021/01/strong-mind.png

-->

# **Cours Docker : Les Fondamentaux par la Pratique**

## **Chapitre 1 : Installation de Docker**

### **Objectifs de ce chapitre :**

*   Comprendre ce qu'est Docker (très brièvement).
*   Connaître les différentes éditions de Docker.
*   Installer Docker sur votre système d'exploitation (Windows, macOS, Linux).
*   Vérifier que l'installation fonctionne correctement.


### **Partie 1 : Introduction et Concepts (Le "Magistral")**

#### **1.1 Qu'est-ce que Docker ? (Rappel rapide)**

Docker est une plateforme open-source qui permet d' **automatiser le déploiement, la mise à l'échelle et la gestion d'applications** en utilisant la **conteneurisation**.

Imaginez un conteneur comme une **boîte standardisée** qui contient tout ce dont une application a besoin pour fonctionner : le code, les dépendances (librairies, frameworks), les outils système, et les configurations. Cette boîte peut ensuite être déplacée et exécutée de manière fiable sur n'importe quelle machine disposant de Docker, indépendamment de l'environnement sous-jacent.

*   **Isolation :** Les conteneurs isolent les applications les unes des autres et du système hôte.
*   **Légèreté :** Ils partagent le noyau du système d'exploitation hôte, ce qui les rend beaucoup plus légers que les machines virtuelles traditionnelles.
*   **Portabilité :** Une application conteneurisée fonctionnera de la même manière partout où Docker est installé.

`[Image : Schéma simple comparant VM et Conteneurs - VM avec OS invité vs Conteneurs partageant le noyau hôte]`

#### **1.2 Docker Desktop vs Docker Engine**

Il existe principalement deux "saveurs" de Docker que vous rencontrerez :

1.  **Docker Desktop :**
    *   **Pour :** Windows et macOS.
    *   **Caractéristiques :** Une application facile à installer qui inclut le moteur Docker (Docker Engine), l'outil en ligne de commande (`docker` CLI), Docker Compose (pour l'orchestration simple), Kubernetes (optionnel), et une interface graphique (GUI). C'est la solution recommandée pour le développement sur Windows et macOS.
    *   **Fonctionnement interne :** Sur Windows, il utilise WSL 2 (Windows Subsystem for Linux 2) ou Hyper-V. Sur macOS, il utilise le framework de virtualisation d'Apple. Il crée en fait une petite machine virtuelle Linux discrète pour faire tourner le démon Docker.

2.  **Docker Engine :**
    *   **Pour :** Principalement les serveurs Linux (mais c'est aussi le cœur de Docker Desktop).
    *   **Caractéristiques :** C'est le moteur de conteneurisation principal (le "démon" `dockerd`), l'API, et l'outil en ligne de commande (`docker` CLI). Pas d'interface graphique fournie par défaut. C'est ce que l'on installe typiquement sur les serveurs de production ou de test sous Linux. Il peut être installé séparément de Docker Compose.

Pour ce cours, si vous êtes sur Windows ou macOS, vous installerez **Docker Desktop**. Si vous êtes sur Linux, vous installerez **Docker Engine** (et nous installerons Docker Compose plus tard si nécessaire, bien qu'il soit souvent inclus ou facile à ajouter).


### **Partie 2 : Installation et Vérification (Les "Exercices")**

Passons à la pratique !

#### **Exercice 1.1 : Téléchargement et Installation**

Suivez les instructions officielles pour votre système d'exploitation. Elles sont les plus à jour :

*   **Windows :**
    1.  Allez sur le site officiel de Docker : [https://docs.docker.com/desktop/install/windows-install/](https://docs.docker.com/desktop/install/windows-install/)
    2.  Vérifiez les prérequis système (notamment WSL 2 ou Hyper-V). Le processus d'installation vous guidera souvent pour activer WSL 2 si ce n'est pas déjà fait.
    3.  Téléchargez et exécutez l'installateur de Docker Desktop.
    4.  Suivez les étapes de l'assistant d'installation. Un redémarrage peut être nécessaire.
    5.  Après l'installation, lancez Docker Desktop. Vous devriez voir une icône de baleine dans votre barre des tâches.

*   **macOS :**
    1.  Allez sur le site officiel de Docker : [https://docs.docker.com/desktop/install/mac-install/](https://docs.docker.com/desktop/install/mac-install/)
    2.  Vérifiez les prérequis système.
    3.  Téléchargez le fichier `.dmg` pour votre type de processeur (Intel ou Apple Silicon).
    4.  Ouvrez le `.dmg` et glissez l'icône Docker dans votre dossier Applications.
    5.  Lancez Docker depuis le dossier Applications. Vous devrez peut-être autoriser son exécution et accorder des privilèges. Une icône de baleine apparaîtra dans votre barre de menu.

*   **Linux (Exemple avec Ubuntu/Debian) :**
    *   *Note :* Il est fortement recommandé de suivre la documentation officielle pour votre distribution spécifique : [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/) (Sélectionnez votre distribution dans le menu de gauche).
    *   La méthode recommandée est d'utiliser le **référentiel (repository) officiel de Docker**.
    1.  **Désinstaller les anciennes versions (si présentes) :**
        ```bash
        sudo apt-get remove docker docker-engine docker.io containerd runc
        ```
    2.  **Configurer le référentiel Docker :**
        ```bash
        # Mettre à jour l'index des paquets apt et installer les prérequis
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg lsb-release

        # Ajouter la clé GPG officielle de Docker
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Configurer le référentiel stable
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        ```
        *(Remplacez `ubuntu` par `debian` si vous êtes sur Debian)*
    3.  **Installer Docker Engine :**
        ```bash
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin # Installe le moteur, CLI, containerd et le plugin Compose V2
        ```
    4.  **(Optionnel mais recommandé) Gérer Docker en tant qu'utilisateur non-root :** Pour éviter de taper `sudo` avant chaque commande `docker`, ajoutez votre utilisateur au groupe `docker`.
        ```bash
        sudo groupadd docker # Peut déjà exister
        sudo usermod -aG docker $USER
        ```
        **Important :** Après avoir exécuté cette commande, vous devez vous **déconnecter et vous reconnecter** (ou redémarrer votre session/terminal) pour que les changements de groupe prennent effet. Vous pouvez aussi exécuter `newgrp docker` dans votre terminal actuel pour appliquer le changement immédiatement pour cette session.

#### **Exercice 1.2 : Vérification de l'Installation**

Ouvrez un terminal (ou PowerShell/Invite de commandes sur Windows).

1.  **Vérifiez la version de Docker :**
    ```bash
    docker --version
    ```
    *   *Résultat attendu (exemple) :* `Docker version 24.0.5, build ced0996` (La version peut varier)

2.  **Obtenez des informations détaillées sur l'installation :**
    ```bash
    docker info
    ```
    *   *Résultat attendu :* Affiche beaucoup d'informations sur le client et le serveur (démon) Docker, y compris le nombre de conteneurs, d'images, le système d'exploitation, l'architecture, etc. Vérifiez qu'il n'y a pas de message d'erreur indiquant que le démon ne tourne pas.

#### **Exercice 1.3 : Exécution de votre premier conteneur ("Hello World")**

C'est le test classique pour s'assurer que tout fonctionne de bout en bout.

1.  **Lancez le conteneur `hello-world` :**
    ```bash
    docker run hello-world
    ```

2.  **Analysez le résultat :** Vous devriez voir quelque chose comme ceci :

    ```
    Unable to find image 'hello-world:latest' locally
    latest: Pulling from library/hello-world
    Digest: sha256: [...]
    Status: Downloaded newer image for hello-world:latest

    Hello from Docker!
    This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
        (amd64)
     3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash

    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com

    For more examples and ideas, visit:
     https://docs.docker.com/get-started/
    ```

    **Que s'est-il passé ?**
    *   La commande `docker run` demande à Docker de démarrer un nouveau conteneur.
    *   `hello-world` est le nom de l' **image** à utiliser comme modèle pour ce conteneur.
    *   Docker a d'abord cherché l'image `hello-world` sur votre machine locale. Comme c'était la première fois, il ne l'a pas trouvée (`Unable to find image 'hello-world:latest' locally`).
    *   Il l'a donc **téléchargée** (`Pulling from library/hello-world`) depuis le registre par défaut, Docker Hub.
    *   Une fois l'image téléchargée, Docker a **créé un conteneur** basé sur cette image.
    *   Il a **exécuté la commande par défaut** définie dans l'image `hello-world` (qui est un simple programme affichant ce message).
    *   Le **résultat (sortie standard)** du programme a été affiché dans votre terminal.
    *   Le programme s'est terminé, et le **conteneur s'est arrêté**.


### **Synthèse du Chapitre 1**

Félicitations ! Si vous avez réussi l'exercice 1.3, Docker est correctement installé et fonctionnel sur votre machine. Vous avez compris la différence entre Docker Desktop et Docker Engine et vous avez lancé votre tout premier conteneur.


Parfait ! Attaquons-nous au cœur de Docker : la gestion des conteneurs.


## **Chapitre 2 : Cycle de Vie des Conteneurs**

### **Objectifs de ce chapitre :**

*   Comprendre la différence fondamentale entre une image et un conteneur.
*   Maîtriser les commandes essentielles pour créer, démarrer, arrêter, lister, inspecter et supprimer des conteneurs.
*   Savoir interagir avec un conteneur en cours d'exécution (logs, exécution de commandes).


### **Partie 1 : Concepts Clés (Le "Magistral")**

#### **2.1 Image vs Conteneur (Rappel important)**

Il est crucial de bien distinguer ces deux concepts :

*   **Image Docker :** C'est un **modèle (template) immuable**, une sorte de "plan" ou de "snapshot" en lecture seule. Elle contient le système de fichiers et les instructions nécessaires pour créer un conteneur. Les images sont construites à partir d'un Dockerfile (on verra ça plus tard) ou téléchargées depuis un registre (comme Docker Hub). *Exemple : L'image `nginx:latest` contient tous les fichiers et la configuration pour faire tourner un serveur web Nginx.*
*   **Conteneur Docker :** C'est une **instance en cours d'exécution (ou arrêtée)** d'une image. C'est la "boîte" vivante basée sur le modèle de l'image. Vous pouvez démarrer, arrêter, déplacer, supprimer des conteneurs. Chaque conteneur a son propre état, son propre système de fichiers (basé sur l'image, mais avec une couche accessible en écriture), et son propre processus isolé. *Exemple : Vous pouvez lancer plusieurs conteneurs Nginx distincts à partir de la seule image `nginx:latest`.*

`[Image : Schéma simple montrant une Image (Boîte bleue "Modèle Nginx") qui sert à créer plusieurs Conteneurs (Boîtes vertes "Instance Nginx 1", "Instance Nginx 2")]`

#### **2.2 Le Cycle de Vie d'un Conteneur**

Un conteneur passe par différents états au cours de son existence :

1.  **Créé (Created) :** Le conteneur a été créé à partir d'une image, mais il n'est pas encore démarré. Son système de fichiers est prêt, mais aucun processus n'est lancé à l'intérieur.
2.  **En cours d'exécution (Running / Up) :** Le conteneur a été démarré. Le processus principal défini dans l'image est en cours d'exécution.
3.  **En pause (Paused) :** L'exécution de tous les processus à l'intérieur du conteneur est suspendue. L'état est gelé en mémoire. (Moins courant pour les débutants).
4.  **Arrêté (Stopped / Exited) :** Le conteneur a terminé son exécution (soit parce que le processus principal s'est terminé, soit parce qu'il a été arrêté manuellement). Les données de sa couche d'écriture sont conservées, mais il ne consomme plus de CPU ni de RAM activement.
5.  **Supprimé (Deleted) :** Le conteneur a été retiré du système. Sa couche d'écriture et toutes les informations associées sont perdues.

`[Image : Diagramme simple du cycle de vie : Created -> (start) -> Running -> (stop) -> Stopped -> (start) -> Running | Running -> (pause) -> Paused -> (unpause) -> Running | Stopped -> (rm) -> Deleted ]`


### **Partie 2 : Commandes Essentielles et Exercices**

Mettons les mains dans le cambouis ! Ouvrez votre terminal.

#### **Exercice 2.1 : Créer et Démarrer un Conteneur (`docker run`)**

La commande `docker run` est la plus fondamentale. Elle *crée* et *démarre* un conteneur à partir d'une image. Si l'image n'est pas présente localement, elle la télécharge d'abord (comme vu avec `hello-world`).

Lançons un serveur web Nginx :

```bash
docker run --name mon-serveur-nginx -p 8080:80 -d nginx:latest
```

Décortiquons cette commande :

*   `docker run` : La commande pour créer et démarrer un conteneur.
*   `--name mon-serveur-nginx` : Attribue un nom lisible (`mon-serveur-nginx`) au conteneur. C'est très pratique pour le gérer ensuite, plutôt que d'utiliser son ID long et aléatoire.
*   `-p 8080:80` : **Publie** (mappe) un port. Cela redirige le trafic arrivant sur le port `8080` de votre machine hôte (la première valeur) vers le port `80` à l'intérieur du conteneur (la seconde valeur). Nginx écoute par défaut sur le port 80. Sans cela, vous ne pourriez pas accéder au serveur Nginx depuis votre navigateur.
*   `-d` : Mode **"detached" (détaché)**. Le conteneur s'exécute en arrière-plan, et la commande vous rend la main immédiatement dans le terminal. Sans `-d`, le terminal resterait attaché au processus principal du conteneur (utile pour certains cas, mais pas pour un serveur).
*   `nginx:latest` : Le nom de l' **image** à utiliser (ici, la version `latest` de l'image officielle Nginx). Docker va la télécharger si elle n'existe pas localement.

**Vérification :**
Ouvrez votre navigateur web et allez à l'adresse `http://localhost:8080` (ou `http://<IP_de_votre_machine>:8080` si Docker tourne sur une VM ou une machine distante). Vous devriez voir la page d'accueil par défaut de Nginx ("Welcome to nginx!").

#### **Exercice 2.2 : Lister les Conteneurs (`docker ps`)**

Comment savoir quels conteneurs sont en cours d'exécution ou existent sur votre système ?

1.  **Lister les conteneurs en cours d'exécution :**
    ```bash
    docker ps
    ```
    *   *Résultat attendu :* Vous devriez voir une ligne correspondant à `mon-serveur-nginx`, avec son ID, l'image utilisée (`nginx:latest`), la commande exécutée, quand il a été créé, son statut (`Up ...`), les ports mappés (`0.0.0.0:8080->80/tcp`), et son nom.

2.  **Lister tous les conteneurs (y compris ceux arrêtés) :**
    ```bash
    docker ps -a
    ```
    *   *Résultat attendu :* Vous verrez `mon-serveur-nginx` (statut `Up`) et probablement aussi le conteneur `hello-world` que nous avons lancé au chapitre 1 (statut `Exited`).

#### **Exercice 2.3 : Arrêter, Démarrer et Redémarrer (`docker stop`, `docker start`, `docker restart`)**

Gérons l'état de notre serveur Nginx :

1.  **Arrêter le conteneur :**
    ```bash
    docker stop mon-serveur-nginx
    ```
    *   *Vérification 1 :* Essayez de rafraîchir `http://localhost:8080`. La page ne devrait plus se charger.
    *   *Vérification 2 :* Exécutez `docker ps`. Le conteneur `mon-serveur-nginx` ne devrait plus apparaître.
    *   *Vérification 3 :* Exécutez `docker ps -a`. Vous le verrez avec le statut `Exited`.

2.  **Démarrer le conteneur arrêté :**
    ```bash
    docker start mon-serveur-nginx
    ```
    *   *Vérification 1 :* Exécutez `docker ps`. Le conteneur est de nouveau listé comme `Up`.
    *   *Vérification 2 :* Rafraîchissez `http://localhost:8080`. La page d'accueil Nginx est de retour !

3.  **Redémarrer le conteneur (équivaut à stop puis start) :**
    ```bash
    docker restart mon-serveur-nginx
    ```
    *   Cela est utile pour appliquer certaines modifications de configuration ou simplement pour relancer le processus. Le conteneur reste `Up` (il y a juste une interruption très brève).

#### **Exercice 2.4 : Consulter les Logs (`docker logs`)**

Les logs sont essentiels pour comprendre ce qui se passe à l'intérieur d'un conteneur, surtout s'il ne démarre pas ou se comporte bizarrement. Docker capture la sortie standard (stdout) et la sortie d'erreur standard (stderr) du processus principal du conteneur.

1.  **Afficher les logs actuels du conteneur Nginx :**
    ```bash
    docker logs mon-serveur-nginx
    ```
    *   *Résultat attendu :* Vous verrez les logs d'accès de Nginx, notamment les requêtes faites par votre navigateur lorsque vous avez accédé à `http://localhost:8080`.

2.  **Suivre les logs en temps réel :**
    ```bash
    docker logs -f mon-serveur-nginx
    # Ou : docker logs --follow mon-serveur-nginx
    ```
    *   Le terminal reste maintenant attaché et affiche les nouveaux logs au fur et à mesure qu'ils arrivent.
    *   Ouvrez `http://localhost:8080` dans votre navigateur et rafraîchissez la page plusieurs fois. Vous verrez de nouvelles lignes apparaître dans le terminal.
    *   Appuyez sur `Ctrl + C` dans le terminal pour arrêter de suivre les logs.

#### **Exercice 2.5 : Exécuter une Commande dans un Conteneur (`docker exec`)**

Parfois, vous avez besoin d'exécuter une commande ponctuelle à l'intérieur d'un conteneur *déjà en cours d'exécution*, par exemple pour explorer son système de fichiers, vérifier un processus, ou lancer un outil de débogage.

1.  **Lister les fichiers de la racine web de Nginx :**
    ```bash
    docker exec mon-serveur-nginx ls /usr/share/nginx/html
    ```
    *   *Résultat attendu :* Vous devriez voir `index.html` et `50x.html`, les fichiers servis par Nginx par défaut.
    *   `docker exec` : La commande pour exécuter quelque chose dans un conteneur.
    *   `mon-serveur-nginx` : Le nom du conteneur cible.
    *   `ls /usr/share/nginx/html` : La commande à exécuter à l'intérieur du conteneur.

2.  **Ouvrir un shell interactif dans le conteneur :** C'est extrêmement utile pour le débogage !
    ```bash
    docker exec -it mon-serveur-nginx bash
    ```
    *   `-i` : Mode **interactif** (garde STDIN ouvert).
    *   `-t` : Alloue un pseudo-**TTY** (terminal). La combinaison `-it` est nécessaire pour avoir un shell fonctionnel.
    *   `bash` : La commande à exécuter (ici, le shell Bash). Si l'image ne contient pas `bash` (cas des images minimalistes comme Alpine), essayez `sh`.
    *   *Résultat attendu :* Votre prompt de terminal devrait changer, indiquant que vous êtes maintenant *à l'intérieur* du conteneur (par exemple, `root@<container_id>:/#`).
    *   Vous pouvez maintenant naviguer dans le système de fichiers du conteneur (`cd /`, `ls`, `cat /etc/nginx/nginx.conf`, etc.).
    *   Pour sortir du shell du conteneur et revenir à votre terminal hôte, tapez `exit`.

#### **Exercice 2.6 : Supprimer des Conteneurs (`docker rm`)**

Quand vous n'avez plus besoin d'un conteneur, il est bon de le supprimer pour libérer de l'espace disque (sa couche d'écriture) et pour garder la liste des conteneurs propre. **Attention : Un conteneur doit être arrêté avant de pouvoir être supprimé.**

1.  **Essayez de supprimer le conteneur Nginx pendant qu'il tourne :**
    ```bash
    docker rm mon-serveur-nginx
    ```
    *   *Résultat attendu :* Docker renvoie une erreur indiquant que vous ne pouvez pas supprimer un conteneur en cours d'exécution. Il suggère de l'arrêter d'abord ou d'utiliser l'option `-f` (force).

2.  **Arrêtez puis supprimez le conteneur Nginx :**
    ```bash
    docker stop mon-serveur-nginx
    docker rm mon-serveur-nginx
    ```
    *   *Vérification :* Exécutez `docker ps -a`. Le conteneur `mon-serveur-nginx` ne devrait plus être listé.

3.  **Supprimez le conteneur `hello-world` (qui est déjà arrêté) :**
    *   Trouvez son nom ou son ID avec `docker ps -a`. Le nom est souvent généré aléatoirement (par ex. `jolly_mayer`). Utilisons son ID (les premiers caractères suffisent généralement) ou son nom.
    ```bash
    # Si vous utilisez son ID (remplacez <id_hello_world> par l'ID réel)
    # docker rm <id_hello_world>

    # Si vous utilisez son nom (remplacez <nom_hello_world> par le nom réel)
    docker rm <nom_hello_world>
    ```

4.  **Nettoyer tous les conteneurs arrêtés d'un coup (`docker container prune`) :** C'est une commande très pratique pour faire le ménage.
    ```bash
    docker container prune
    ```
    *   Docker vous demandera une confirmation car cette action est irréversible. Tapez `y` puis Entrée.
    *   *Résultat attendu :* Docker liste les ID des conteneurs supprimés et l'espace disque récupéré.

#### **Exercice 2.7 : Obtenir des Détails sur un Conteneur (`docker inspect`)**

Cette commande renvoie une foule d'informations détaillées (en format JSON) sur la configuration et l'état d'un conteneur.

1.  **Créez un conteneur simple qui ne fait rien (juste pour l'exemple) :** L'image `alpine` est une image Linux très légère. `sleep 3600` le fait juste attendre pendant une heure.
    ```bash
    docker run -d --name inspect-me alpine sleep 3600
    ```
2.  **Inspectez le conteneur :**
    ```bash
    docker inspect inspect-me
    ```
    *   *Résultat attendu :* Un gros bloc de JSON. Parcourez-le pour trouver des informations intéressantes comme :
        *   `Id` : L'ID complet du conteneur.
        *   `Created` : Date de création.
        *   `Path`, `Args` : La commande exécutée.
        *   `State` : État détaillé (Running, Pid, StartedAt, etc.).
        *   `Image` : L'ID de l'image utilisée.
        *   `NetworkSettings` -> `IPAddress` : L'adresse IP interne du conteneur dans le réseau Docker par défaut.
        *   `Mounts` : Les volumes ou points de montage (on verra ça plus tard).
        *   `Config` -> `Labels` : Les éventuels labels attachés.
        *   ... et bien d'autres choses.

3.  **Nettoyez :**
    ```bash
    docker stop inspect-me
    docker rm inspect-me
    # Ou directement : docker rm -f inspect-me (force la suppression même s'il tourne)
    ```


### **Synthèse du Chapitre 2**

Vous avez maintenant une bonne compréhension du cycle de vie d'un conteneur et maîtrisez les commandes essentielles pour les gérer :

*   `docker run` : Créer et démarrer (avec des options comme `--name`, `-d`, `-p`).
*   `docker ps [-a]` : Lister les conteneurs (en cours ou tous).
*   `docker stop`, `docker start`, `docker restart` : Contrôler l'état d'un conteneur.
*   `docker logs [-f]` : Consulter la sortie d'un conteneur.
*   `docker exec [-it]` : Exécuter des commandes à l'intérieur d'un conteneur.
*   `docker rm` : Supprimer des conteneurs arrêtés.
*   `docker container prune` : Supprimer tous les conteneurs arrêtés.
*   `docker inspect` : Obtenir des informations détaillées.

Le flux typique est : `run` -> `ps` -> `stop`/`start`/`restart`/`logs`/`exec` -> `rm` (ou `prune`).

Excellent ! Maintenant que nous savons manipuler les conteneurs, apprenons à créer nos propres "modèles" : les images Docker. C'est une étape fondamentale pour conteneuriser vos propres applications.


## **Chapitre 3 : Création d'Images Docker**

### **Objectifs de ce chapitre :**

*   Comprendre les différentes méthodes pour créer une image Docker.
*   Maîtriser la création d'images via un `Dockerfile` (la méthode standard).
*   Savoir utiliser les instructions Dockerfile les plus courantes.
*   Comprendre le concept de "build context".
*   Apprendre à construire une image à partir d'un Dockerfile (`docker build`).
*   Explorer brièvement d'autres méthodes (commit, load) et concepts (multi-stage, BuildKit).



### **Partie 1 : Concepts et Méthodes (Le "Magistral")**

#### **3.1 Pourquoi créer ses propres images ?**

L'intérêt principal de Docker est de pouvoir empaqueter **votre application** et ses dépendances. Si les images officielles (comme `nginx`, `python`, `node`, `postgres`, etc.) sont très utiles comme base, vous aurez presque toujours besoin de :

*   Ajouter **votre code source** à l'image.
*   Installer des **dépendances spécifiques** (librairies, paquets système).
*   Configurer l'environnement (variables d'environnement, fichiers de configuration).
*   Définir la **commande par défaut** qui lance votre application.

C'est là qu'intervient la création d'images personnalisées.

#### **3.2 Méthodes de Création d'Images**

1.  **À partir d'un `Dockerfile` (Méthode Recommandée) :**
    *   C'est la méthode **standard, reproductible et transparente**.
    *   Un `Dockerfile` est un fichier texte contenant une série d'instructions (commandes) qui décrivent étape par étape comment construire l'image.
    *   Docker lit ce fichier et exécute chaque instruction pour créer des **couches (layers)** successives, formant l'image finale.
    *   **Avantages :** Automatisation, versionnement (le Dockerfile peut être mis dans Git), clarté, optimisation du cache.

2.  **En mode interactif (`docker commit`) (Déconseillé pour la production) :**
    *   Vous lancez un conteneur à partir d'une image de base (ex: `ubuntu`).
    *   Vous exécutez des commandes *à l'intérieur* de ce conteneur pour installer des logiciels, modifier des fichiers, etc.
    *   Vous utilisez ensuite `docker commit <id_conteneur> <nom_nouvelle_image>` pour créer une nouvelle image à partir de l'état actuel du conteneur.
    *   **Inconvénients :** Manque de transparence (difficile de savoir exactement ce qui a été fait), non reproductible facilement, "magique" et opaque, difficile à maintenir.
    *   **Usage :** Principalement pour le débogage rapide ou l'expérimentation ponctuelle. **À éviter pour créer les images de vos applications.**

3.  **À partir d'une archive (`docker load`) :**
    *   Vous pouvez exporter une image existante dans une archive `.tar` (avec `docker save`).
    *   `docker load -i <fichier.tar>` permet de recharger cette image sur une autre machine Docker (ou la même).
    *   **Usage :** Transfert d'images hors ligne, sauvegarde/restauration, partage sans passer par un registre. Ce n'est pas une méthode de *création* à partir de zéro, mais d'importation.

4.  **À partir de zéro (`FROM scratch`) :**
    *   Pour créer des images minimalistes ne contenant qu'un binaire statique (ex: un programme Go). `scratch` est une image vide spéciale. C'est un cas d'usage avancé.

**Dans ce chapitre, nous nous concentrerons sur la méthode essentielle : le `Dockerfile`.**

#### **3.3 Le Dockerfile : Structure et Instructions Courantes**

Un `Dockerfile` est une recette. Chaque ligne est une instruction. Voici les plus importantes :

*   **`FROM <image>[:<tag>]`** (Obligatoire, première instruction)
    *   Définit l' **image de base** sur laquelle votre nouvelle image sera construite.
    *   Exemple : `FROM ubuntu:22.04`, `FROM python:3.9-slim`, `FROM node:18-alpine`. Le choix de l'image de base est crucial (taille, sécurité, outils inclus).
*   **`RUN <commande>`**
    *   Exécute une commande shell *pendant la construction de l'image* (dans un conteneur temporaire). Utilisé pour installer des paquets, créer des dossiers, télécharger des fichiers, compiler du code, etc.
    *   Chaque `RUN` crée une nouvelle couche d'image. Il est souvent préférable de chaîner les commandes avec `&&` pour limiter le nombre de couches.
    *   Exemple : `RUN apt-get update && apt-get install -y curl vim && rm -rf /var/lib/apt/lists/*`
*   **`COPY <source_hôte> <destination_conteneur>`**
    *   Copie des fichiers ou répertoires depuis votre machine (le "build context", voir plus bas) vers le système de fichiers de l'image.
    *   Exemple : `COPY ./app /app` (copie le dossier `app` local dans le dossier `/app` de l'image).
*   **`ADD <source> <destination_conteneur>`**
    *   Similaire à `COPY`, mais avec des fonctionnalités supplémentaires (peut télécharger depuis une URL, peut décompresser automatiquement des archives `.tar` locales).
    *   **Bonne pratique :** Préférer `COPY` sauf si vous avez spécifiquement besoin des fonctionnalités de `ADD` (pour plus de clarté).
*   **`WORKDIR /chemin/dans/le/conteneur`**
    *   Définit le **répertoire de travail** pour les instructions `RUN`, `CMD`, `ENTRYPOINT`, `COPY`, `ADD` qui suivent dans le Dockerfile. Si le répertoire n'existe pas, il sera créé.
    *   Exemple : `WORKDIR /app` (les commandes suivantes s'exécuteront dans `/app`).
*   **`EXPOSE <port>[/protocole]`**
    *   **Documente** sur quel port le conteneur écoutera une fois démarré. C'est une indication pour l'utilisateur. **Cela ne publie PAS le port !** La publication se fait toujours avec `docker run -p <port_hôte>:<port_conteneur>`.
    *   Exemple : `EXPOSE 80` (indique que l'application dans le conteneur écoute sur le port 80).
*   **`CMD ["executable", "param1", "param2"]` (Forme JSON préférée)** ou `CMD commande param1 param2` (Forme shell)
    *   Définit la **commande par défaut** qui sera exécutée lorsque le conteneur démarre.
    *   S'il y a plusieurs `CMD`, seul le dernier est pris en compte.
    *   Peut être **surchargé** lors de l'exécution (`docker run <image> <autre_commande>`).
    *   Exemple : `CMD ["python", "app.py"]`
*   **`ENTRYPOINT ["executable", "param1", "param2"]` (Forme JSON préférée)** ou `ENTRYPOINT commande param1 param2` (Forme shell)
    *   Configure le conteneur pour qu'il s'exécute comme un **exécutable principal**.
    *   Les arguments passés à `docker run <image> arg1 arg2` sont ajoutés *après* l'ENTRYPOINT.
    *   Moins facile à surcharger que `CMD`. Souvent utilisé en combinaison avec `CMD` (où `CMD` fournit les arguments par défaut à l'`ENTRYPOINT`).
    *   Exemple : `ENTRYPOINT ["java", "-jar", "app.jar"]` (et `CMD ["--help"]` pour l'argument par défaut).
*   **`ENV <clé>=<valeur>`** ou `ENV <clé1>=<valeur1> <clé2>=<valeur2> ...`
    *   Définit des **variables d'environnement** dans l'image. Elles seront disponibles pour les instructions suivantes dans le Dockerfile et pour l'application qui s'exécute dans le conteneur.
    *   Exemple : `ENV APP_VERSION=1.0`
*   **`ARG <nom>[=<valeur_par_défaut>]`**
    *   Définit une **variable utilisable uniquement pendant la construction de l'image** (pas disponible dans le conteneur final, sauf si utilisée pour définir une `ENV`). Peut être passée lors du build avec `docker build --build-arg <nom>=<valeur>`.
    *   Exemple : `ARG USER=guest`

#### **3.4 Le Contexte de Build (`Build Context`)**

Lorsque vous exécutez `docker build`, la première chose que fait le client Docker est d'envoyer un dossier (ou une archive) au démon Docker. Ce dossier est le **contexte de build**. Par défaut, c'est le dossier où se trouve votre `Dockerfile` (souvent représenté par `.` dans la commande `docker build .`).

*   Seuls les fichiers présents dans le contexte de build peuvent être utilisés par les instructions `COPY` ou `ADD`.
*   **Important :** Évitez d'avoir des fichiers volumineux et inutiles (logs, `node_modules`, builds précédents, etc.) dans votre contexte de build, car tout est envoyé au démon Docker, ce qui ralentit le build. Utilisez un fichier `.dockerignore` (similaire à `.gitignore`) pour exclure des fichiers/dossiers.

#### **3.5 Les Couches (Layers) et le Cache**

Chaque instruction dans le `Dockerfile` (sauf celles qui ne modifient pas le système de fichiers comme `FROM`, `WORKDIR`, `EXPOSE`, `CMD`, `ENTRYPOINT`, `ENV`, `ARG`) crée une **nouvelle couche** dans l'image.

*   Ces couches sont superposées et immuables (sauf la dernière couche accessible en écriture quand un conteneur est lancé).
*   Docker utilise un **cache** pour accélérer les builds. Si une instruction et ses fichiers sources (pour `COPY`/`ADD`) n'ont pas changé depuis le dernier build, Docker réutilise la couche existante au lieu de ré-exécuter l'instruction.
*   **Optimisation :** Placez les instructions qui changent le moins souvent (ex: installation de dépendances système `RUN apt-get install ...`) **avant** celles qui changent fréquemment (ex: `COPY` de votre code source).



### **Partie 2 : Exercices Pratiques**

#### **Exercice 3.1 : Création d'une Image Simple avec un Dockerfile**

Créons une image qui exécute un simple script Python.

1.  **Créez un nouveau dossier** pour ce projet, par exemple `mon-app-docker`.
    ```bash
    mkdir mon-app-docker
    cd mon-app-docker
    ```
2.  **Créez un fichier `app.py`** avec le contenu suivant :
    ```python
    # app.py
    import os
    import time

    print("Bonjour depuis Docker !")
    print(f"Je tourne avec Python.")
    message = os.getenv("MESSAGE_PERSO", "Pas de message personnalisé.")
    print(f"Message : {message}")

    print("Je vais dormir un peu...")
    time.sleep(30)
    print("Au revoir !")
    ```
3.  **Créez un fichier nommé `Dockerfile`** (sans extension) dans le même dossier `mon-app-docker` :
    ```dockerfile
    # Utiliser une image Python officielle comme base
    FROM python:3.9-slim

    # Définir le répertoire de travail dans le conteneur
    WORKDIR /app

    # Copier le script Python local dans le répertoire de travail du conteneur
    COPY app.py .

    # Définir une variable d'environnement (optionnel)
    ENV MESSAGE_PERSO="Ceci est mon message !"

    # Définir la commande à exécuter au démarrage du conteneur
    CMD ["python", "app.py"]
    ```
4.  **Créez un fichier `.dockerignore`** (optionnel mais bonne pratique) pour exclure des fichiers/dossiers du contexte de build :
    ```
    # .dockerignore
    *.pyc
    __pycache__/
    .git
    .venv # Si vous utilisez un environnement virtuel localement
    ```
5.  **Construisez (Build) l'image Docker :** Ouvrez votre terminal dans le dossier `mon-app-docker`.
    ```bash
    docker build -t mon-app:1.0 .
    ```
    *   `docker build` : La commande pour construire une image.
    *   `-t mon-app:1.0` : **Tag** de l'image. `-t` permet de donner un nom (`mon-app`) et une étiquette (`1.0`) à l'image. C'est essentiel pour la gérer facilement. Format: `<nom_image>:<tag>`.
    *   `.` : Le **chemin vers le contexte de build** (ici, le répertoire courant).

    *   *Résultat attendu :* Vous verrez Docker exécuter chaque étape du Dockerfile (`Step 1/5 : FROM python:3.9-slim`, `Step 2/5 : WORKDIR /app`, etc.). S'il télécharge l'image de base, cela peut prendre un peu de temps la première fois. À la fin, vous devriez voir `Successfully built <id_image>` et `Successfully tagged mon-app:1.0`.

6.  **Vérifiez que l'image a été créée :**
    ```bash
    docker images
    # Ou pour filtrer : docker images mon-app
    ```
    *   *Résultat attendu :* Vous devriez voir votre image `mon-app` avec le tag `1.0` dans la liste.

7.  **Exécutez un conteneur à partir de votre nouvelle image :**
    ```bash
    docker run --rm mon-app:1.0
    ```
    *   `--rm` : Option pratique qui supprime automatiquement le conteneur une fois qu'il s'arrête. Utile pour les tests rapides.
    *   *Résultat attendu :* Vous devriez voir la sortie de votre script Python s'afficher dans le terminal :
        ```
        Bonjour depuis Docker !
        Je tourne avec Python.
        Message : Ceci est mon message !
        Je vais dormir un peu...
        (Attente de 30 secondes)
        Au revoir !
        ```

8.  **Expérimentez avec le cache :**
    *   Modifiez *légèrement* le fichier `app.py` (changez un message).
    *   Reconstruisez l'image : `docker build -t mon-app:1.0 .`
    *   *Observez le résultat :* Docker devrait réutiliser les couches `FROM` et `WORKDIR` (marquées comme `Using cache`). L'étape `COPY` sera ré-exécutée car `app.py` a changé, ainsi que les étapes suivantes (`ENV`, `CMD`). C'est beaucoup plus rapide !

#### **Exercice 3.2 : Création d'une Image via `docker commit` (Pour comprendre, pas pour utiliser)**

1.  **Lancez un conteneur Ubuntu interactif :**
    ```bash
    docker run -it --name commit-test ubuntu:22.04 bash
    ```
2.  **À l'intérieur du conteneur (le prompt est `root@...:/#`) :** Installez `curl` et créez un fichier.
    ```bash
    # Mettre à jour les listes de paquets
    apt-get update

    # Installer curl sans poser de questions interactives
    apt-get install -y curl

    # Créer un fichier
    echo "Fichier créé via commit" > /mon_fichier.txt

    # Quitter le conteneur
    exit
    ```
3.  Le conteneur `commit-test` est maintenant arrêté. **Créez une image à partir de son état :**
    ```bash
    docker commit commit-test mon-image-commit:latest
    ```
4.  **Vérifiez la nouvelle image :**
    ```bash
    docker images mon-image-commit
    ```
5.  **Lancez un conteneur à partir de cette nouvelle image pour vérifier :**
    ```bash
    # Vérifier que curl est installé
    docker run --rm mon-image-commit:latest curl --version

    # Vérifier que le fichier existe
    docker run --rm mon-image-commit:latest cat /mon_fichier.txt
    ```
    *   *Résultat attendu :* La version de `curl` s'affiche, et le contenu du fichier aussi. L'image contient bien nos modifications. Mais comment ces modifications ont-elles été faites ? C'est opaque !

6.  **Nettoyez :**
    ```bash
    docker rm commit-test
    docker rmi mon-image-commit:latest # rmi pour supprimer une image
    ```

#### **Exercice 3.3 : Importer une Image avec `docker load` (Simulation)**

1.  **Sauvegardez l'image Python de base dans une archive :**
    ```bash
    docker save -o python_slim.tar python:3.9-slim
    # Ou : docker save python:3.9-slim > python_slim.tar
    ```
    *   Cela crée un fichier `python_slim.tar` contenant l'image.

2.  **(Optionnel) Supprimez l'image locale pour simuler un transfert :**
    ```bash
    docker rmi python:3.9-slim
    docker images python # Vérifiez qu'elle n'est plus là
    ```
3.  **Chargez l'image depuis l'archive :**
    ```bash
    docker load -i python_slim.tar
    # Ou : docker load < python_slim.tar
    ```
4.  **Vérifiez que l'image est de retour :**
    ```bash
    docker images python
    ```
5.  **Nettoyez (supprimez l'archive si vous voulez) :**
    ```bash
    rm python_slim.tar
    ```

#### **3.6 Concept Avancé : Multi-Stage Builds**

Imaginez que vous avez besoin d'outils spécifiques (compilateur, librairies de build, etc.) pour construire votre application, mais que vous ne voulez pas de ces outils dans l'image finale (pour la sécurité et la taille). C'est là qu'interviennent les builds multi-étapes.

*   Vous définissez plusieurs étapes `FROM` dans le même `Dockerfile`.
*   Chaque étape `FROM` commence une nouvelle phase de build.
*   Vous pouvez nommer les étapes (`FROM ... AS <nom_etape>`).
*   Vous pouvez copier des artefacts (fichiers compilés, etc.) d'une étape précédente vers une étape ultérieure en utilisant `COPY --from=<nom_etape> <source> <destination>`.

**Exemple Conceptuel (Pas d'exercice détaillé ici, juste pour illustrer) :**

```dockerfile
# ---- Étape 1 : Build ----
# Utiliser une image avec les outils de build (ex: Maven et JDK complet)
FROM maven:3.8-openjdk-17 AS builder

WORKDIR /build

# Copier le descripteur de projet et télécharger les dépendances (profite du cache)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copier le reste du code source et compiler
COPY src ./src
RUN mvn package -DskipTests

# ---- Étape 2 : Production ----
# Utiliser une image légère juste avec le JRE
FROM openjdk:17-jre-slim

WORKDIR /app

# Copier UNIQUEMENT le .jar compilé depuis l'étape 'builder'
COPY --from=builder /build/target/*.jar app.jar

# Exposer le port et définir la commande d'exécution
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

```

*   L'image finale (`openjdk:17-jre-slim` avec `app.jar`) ne contiendra pas Maven ni le JDK complet, seulement le JRE et l'application compilée. C'est beaucoup plus léger et sécurisé.

#### **3.7 BuildKit**

BuildKit est le moteur de construction nouvelle génération de Docker. Il est activé par défaut dans les versions récentes de Docker Desktop et Docker Engine.

*   **Avantages :** Meilleure performance (parallélisation des étapes de build indépendantes), meilleure gestion du cache, gestion des secrets de build plus sécurisée, etc.
*   Vous n'avez généralement rien de spécial à faire pour l'utiliser s'il est activé par défaut. Vous pouvez le forcer en définissant la variable d'environnement `DOCKER_BUILDKIT=1` avant d'exécuter `docker build`.
*   La sortie de `docker build` avec BuildKit est souvent plus structurée et informative.



### **Synthèse du Chapitre 3**

Vous savez maintenant créer vos propres images Docker, la compétence clé pour conteneuriser vos applications :

*   La méthode **recommandée et standard** est d'utiliser un `Dockerfile`.
*   Vous maîtrisez les instructions de base : `FROM`, `RUN`, `COPY`, `WORKDIR`, `EXPOSE`, `CMD`, `ENV`.
*   Vous comprenez l'importance du **contexte de build** et du fichier `.dockerignore`.
*   Vous savez construire une image avec `docker build -t <nom>:<tag> .`
*   Vous comprenez le **système de cache** et comment l'optimiser (ordre des instructions).
*   Vous avez vu d'autres méthodes (`commit`, `load`) et concepts (`multi-stage`, `BuildKit`).

Nous avons des images locales. Comment les partager et récupérer celles des autres ? C'est l'objet du prochain chapitre.

On continue ! Maintenant que nous savons construire nos images personnalisées, voyons comment les gérer, les partager et utiliser celles créées par d'autres.


## **Chapitre 4 : Gestion des Images (Tag, Pull, Push, Registres)**

### **Objectifs de ce chapitre :**

*   Comprendre la convention de nommage et de taggage des images.
*   Savoir ce qu'est un registre Docker (Docker Hub et autres).
*   Maîtriser les commandes pour télécharger (`pull`), taguer (`tag`), envoyer (`push`) et supprimer (`rmi`) des images.
*   Apprendre à se connecter à un registre.



### **Partie 1 : Concepts Clés (Le "Magistral")**

#### **4.1 Nommage et Taggage des Images**

Quand on parle d'une image Docker, on utilise généralement un nom et un tag, séparés par deux-points (`:`). La convention de nommage complète est la suivante :

`[registry-hostname/][username/]<repository>:<tag>`

Décortiquons :

*   **`<repository>` (Obligatoire) :** Le nom principal de l'image (par exemple, `nginx`, `ubuntu`, `mon-app`).
*   **`:<tag>` (Optionnel, `:latest` par défaut) :** Une étiquette qui identifie généralement une version spécifique de l'image (par exemple, `:1.21`, `:latest`, `:3.9-slim`, `:1.0`).
    *   **`latest` :** C'est le tag par défaut si vous n'en spécifiez pas. **Attention :** `latest` ne signifie pas nécessairement "la version la plus récente stable". C'est juste un tag qui *peut* être mis à jour par le mainteneur de l'image. Il est **fortement recommandé** d'utiliser des tags explicites (comme `:1.21.6`) pour garantir la reproductibilité de vos builds et déploiements.
*   **`[username/]` (Optionnel, requis pour Docker Hub si ce n'est pas une image officielle) :** Pour les images sur Docker Hub qui ne sont pas des images officielles (comme `nginx`, `python`, etc.), le nom est préfixé par le nom d'utilisateur ou de l'organisation Docker Hub (par exemple, `johndoe/mon-app-perso`).
*   **`[registry-hostname/]` (Optionnel, requis si ce n'est pas Docker Hub) :** Si l'image n'est pas hébergée sur le registre Docker Hub par défaut, vous devez préfixer le nom complet par l'adresse du registre (par exemple, `gcr.io/mon-projet/mon-app`, `quay.io/mon-org/mon-outil`, `mon-registre-prive.local:5000/mon-app`).

**Exemples :**
*   `nginx:1.21-alpine` : Image officielle `nginx`, tag `1.21-alpine`, depuis Docker Hub.
*   `ubuntu` : Image officielle `ubuntu`, tag `latest` implicite, depuis Docker Hub.
*   `bitnami/wordpress:latest` : Image `wordpress` de l'utilisateur/organisation `bitnami`, tag `latest`, depuis Docker Hub.
*   `mon-app:1.0` : Image locale que nous avons créée, non encore liée à un registre ou un utilisateur.
*   `my_private_registry.com:5000/internal/database:v2-beta` : Image `database` dans le namespace `internal` sur un registre privé, tag `v2-beta`.

#### **4.2 Les Registres Docker (Docker Registries)**

Un registre Docker est un **système de stockage et de distribution pour les images Docker**. C'est un serveur (ou un ensemble de serveurs) qui héberge des dépôts (repositories) d'images.

*   **Docker Hub (`hub.docker.com`) :**
    *   Le registre **public par défaut** utilisé par Docker.
    *   Héberge les images "officielles" (maintenues par Docker ou des partenaires) et des millions d'images partagées par la communauté et des entreprises.
    *   Offre des dépôts publics gratuits et des dépôts privés payants.
    *   C'est là que Docker cherche les images par défaut lorsque vous faites `docker pull` ou `docker run` si aucun nom de registre n'est spécifié.

*   **Registres Cloud :**
    *   Fournis par les grands fournisseurs de cloud :
        *   Amazon Elastic Container Registry (ECR)
        *   Google Container Registry (GCR) / Artifact Registry
        *   Azure Container Registry (ACR)
        *   GitLab Container Registry
        *   GitHub Container Registry (ghcr.io)
        *   ...et d'autres.
    *   Souvent utilisés pour héberger les images privées des applications déployées dans leur cloud respectif. Offrent une intégration étroite avec leurs autres services (sécurité, déploiement).

*   **Registres Auto-hébergés :**
    *   Vous pouvez héberger votre propre registre Docker en utilisant des logiciels comme :
        *   Docker Registry (l'implémentation open-source officielle)
        *   Harbor (une solution d'entreprise avec plus de fonctionnalités : UI, sécurité, etc.)
        *   Nexus Repository Manager
        *   JFrog Artifactory
    *   Utile pour des raisons de sécurité, de contrôle, de performance (cache local) ou de fonctionnement en environnement déconnecté (air-gapped).

Pour partager vos images ou pour les utiliser dans des systèmes d'intégration continue ou de déploiement, vous devrez les **pousser (`push`)** vers un registre. Pour utiliser des images venant d'un registre, vous devrez les **tirer (`pull`)**.



### **Partie 2 : Commandes Essentielles et Exercices**

Reprenons notre image `mon-app:1.0` du chapitre précédent.

#### **Exercice 4.1 : Tagger une Image (`docker tag`)**

La commande `docker tag` ne crée pas une nouvelle image, mais ajoute une **étiquette supplémentaire** (un alias) à une image existante. C'est essentiel avant de pousser une image vers un registre spécifique ou sous un nom d'utilisateur particulier.

1.  **Vérifiez vos images locales :**
    ```bash
    docker images mon-app
    ```
    *   Vous devriez voir `mon-app` avec le tag `1.0`. Notez l'IMAGE ID.

2.  **Créez un nouveau tag pour la même image :** Donnons-lui le tag `latest`.
    ```bash
    docker tag mon-app:1.0 mon-app:latest
    ```

3.  **Vérifiez à nouveau les images :**
    ```bash
    docker images mon-app
    ```
    *   *Résultat attendu :* Vous voyez maintenant deux lignes pour `mon-app` : une avec le tag `1.0` et une avec `latest`. **Remarquez que l'IMAGE ID est identique !** Cela confirme que c'est la même image, juste avec deux noms/tags différents.

4.  **(Préparation pour le push)** Si vous avez un compte Docker Hub (sinon, créez-en un gratuitement sur [https://hub.docker.com/](https://hub.docker.com/)), taguez l'image avec votre nom d'utilisateur. Remplacez `<votre_nom_utilisateur_dockerhub>` par votre vrai nom d'utilisateur.
    ```bash
    # Assurez-vous de remplacer <votre_nom_utilisateur_dockerhub>
    docker tag mon-app:1.0 <votre_nom_utilisateur_dockerhub>/mon-app:1.0
    ```

5.  **Vérifiez une dernière fois les images :**
    ```bash
    docker images
    ```
    *   Vous devriez maintenant voir `mon-app:1.0`, `mon-app:latest`, et `<votre_nom_utilisateur_dockerhub>/mon-app:1.0`, toutes partageant le même IMAGE ID.

#### **Exercice 4.2 : Télécharger une Image (`docker pull`)**

La commande `docker pull` télécharge une image depuis un registre (Docker Hub par défaut) vers votre machine locale.

1.  **Téléchargez une version spécifique de Nginx (une image légère basée sur Alpine Linux) :**
    ```bash
    docker pull nginx:1.21-alpine
    ```
    *   *Résultat attendu :* Docker contacte Docker Hub, trouve l'image et télécharge ses différentes couches. Vous verrez la progression du téléchargement pour chaque couche. Si l'image (ou certaines couches) est déjà présente localement, Docker le signalera.

2.  **Téléchargez l'image Redis officielle (tag `latest` implicite) :**
    ```bash
    docker pull redis
    ```

3.  **Vérifiez les images téléchargées :**
    ```bash
    docker images
    ```
    *   Vous devriez maintenant voir `nginx` avec le tag `1.21-alpine` et `redis` avec le tag `latest` (en plus de vos images `mon-app`).

#### **Exercice 4.3 : Se Connecter à un Registre (`docker login`)**

Pour pouvoir pousser (`push`) des images vers un registre privé ou vers votre compte Docker Hub, vous devez d'abord vous authentifier.

1.  **Connectez-vous à Docker Hub :**
    ```bash
    docker login
    ```
    *   Docker vous demandera votre nom d'utilisateur Docker Hub et votre mot de passe (ou un Access Token - recommandé pour la sécurité, vous pouvez en créer un dans les paramètres de votre compte Docker Hub).
    *   Si la connexion réussit, vous verrez le message "Login Succeeded".

2.  **Pour se déconnecter (pas nécessaire maintenant) :**
    ```bash
    docker logout
    ```

3.  **Pour se connecter à un registre privé :**
    ```bash
    docker login <adresse_du_registre_prive>
    # Exemple: docker login my_private_registry.com:5000
    ```
    *   Les identifiants demandés dépendront de la configuration du registre privé.

#### **Exercice 4.4 : Envoyer une Image vers un Registre (`docker push`)**

Maintenant que vous êtes connecté et que vous avez tagué votre image `mon-app` avec votre nom d'utilisateur Docker Hub, vous pouvez la pousser.

1.  **Poussez l'image taguée vers Docker Hub :**
    ```bash
    # Assurez-vous d'utiliser le tag complet avec votre nom d'utilisateur
    docker push <votre_nom_utilisateur_dockerhub>/mon-app:1.0
    ```
    *   *Résultat attendu :* Docker va envoyer les couches de votre image vers Docker Hub. Si certaines couches existent déjà (par exemple, celles de l'image de base `python:3.9-slim`), elles ne seront pas renvoyées, ce qui accélère le processus. Vous verrez la progression de l'upload.

2.  **(Vérification Optionnelle)** Allez sur votre compte Docker Hub dans votre navigateur web. Vous devriez trouver un nouveau dépôt nommé `mon-app` contenant le tag `1.0`.

#### **Exercice 4.5 : Supprimer des Images Locales (`docker rmi`)**

Une fois que vous avez poussé une image ou si vous n'en avez plus besoin localement, vous pouvez la supprimer pour libérer de l'espace disque.

1.  **Essayez de supprimer l'image `mon-app:1.0` pendant qu'elle a d'autres tags :**
    ```bash
    docker rmi mon-app:1.0
    ```
    *   *Résultat attendu :* Le tag `mon-app:1.0` sera "détagué" (`Untagged: mon-app:1.0`), mais l'image elle-même ne sera probablement pas supprimée car d'autres tags (`mon-app:latest`, `<votre_nom_utilisateur_dockerhub>/mon-app:1.0`) pointent toujours vers elle.

2.  **Supprimez un autre tag :**
    ```bash
    docker rmi mon-app:latest
    ```
    *   *Résultat attendu :* `Untagged: mon-app:latest`. L'image n'est toujours pas supprimée.

3.  **Supprimez le dernier tag pointant vers cette image localement :**
    ```bash
    docker rmi <votre_nom_utilisateur_dockerhub>/mon-app:1.0
    ```
    *   *Résultat attendu :* Cette fois, le tag est retiré (`Untagged: ...`) ET les couches de l'image qui ne sont plus référencées par aucun tag sont supprimées (`Deleted: sha256:...`).

4.  **Supprimez l'image Nginx téléchargée précédemment :**
    ```bash
    docker rmi nginx:1.21-alpine
    ```
    *   *Résultat attendu :* L'image et ses couches sont supprimées (sauf si une autre image utilise les mêmes couches de base).

5.  **Supprimer une image utilisée par un conteneur (même arrêté) :**
    *   Lancez un conteneur Redis (il s'arrêtera car on ne lui donne pas de commande pour rester actif longtemps) : `docker run --name temp-redis redis`
    *   Essayez de supprimer l'image Redis : `docker rmi redis`
    *   *Résultat attendu :* Erreur ! Docker vous informe que l'image est utilisée par un conteneur (même arrêté). Vous devez d'abord supprimer le conteneur (`docker rm temp-redis`) avant de pouvoir supprimer l'image (`docker rmi redis`).
    *   **Nettoyez :** `docker rm temp-redis` puis `docker rmi redis`.

6.  **Nettoyer les images "dangling" (`docker image prune`) :** Les images "dangling" sont des couches d'images qui ne sont plus associées à aucun tag (souvent le résultat de builds successifs où l'ancien tag a été réaffecté à une nouvelle image).
    ```bash
    docker image prune
    ```
    *   Docker vous demande confirmation. Tapez `y`. Il supprime toutes les images sans tag et indique l'espace récupéré.

7.  **Nettoyer toutes les images non utilisées (`docker image prune -a`) :** ATTENTION ! Ceci supprime toutes les images qui ne sont utilisées par aucun conteneur (même arrêté).
    ```bash
    # À utiliser avec précaution si vous voulez garder des images non utilisées pour plus tard
    # docker image prune -a
    ```

#### **Exercice 4.6 : Rechercher des Images (`docker search`)**

Vous pouvez rechercher des images sur Docker Hub depuis la ligne de commande.

1.  **Recherchez des images liées à "alpine" :**
    ```bash
    docker search alpine
    ```
    *   *Résultat attendu :* Une liste d'images contenant "alpine" dans leur nom ou description, avec des étoiles (popularité), si elles sont officielles, etc. L'image `alpine` officielle devrait être en haut.

2.  **Recherchez des images liées à "wordpress" avec plus de 100 étoiles :**
    ```bash
    docker search --filter stars=100 wordpress
    ```

*   **Note :** Bien que `docker search` existe, il est souvent plus pratique et informatif de rechercher des images directement sur le site web de Docker Hub ou du registre que vous utilisez.



### **Synthèse du Chapitre 4**

Vous savez maintenant comment interagir avec les registres Docker pour partager et récupérer des images :

*   Le nommage des images suit la structure `[registry/][username/]<repository>:<tag>`.
*   Les **tags** sont essentiels pour versionner vos images (évitez `latest` en production).
*   **Docker Hub** est le registre public par défaut, mais des registres privés (cloud ou auto-hébergés) existent.
*   `docker tag` : Ajoute une étiquette à une image existante.
*   `docker pull` : Télécharge une image depuis un registre.
*   `docker login` : S'authentifie auprès d'un registre.
*   `docker push` : Envoie une image locale vers un registre.
*   `docker rmi` : Supprime une image (ou un tag) localement.
*   `docker image prune` : Nettoie les images non utilisées ou sans tag.
*   `docker search` : Recherche des images sur Docker Hub (interface web souvent préférable).

La prochaine étape est de comprendre comment observer ce qui se passe à l'intérieur de nos conteneurs en fonctionnement.

Parfait, continuons avec la gestion des logs, un aspect essentiel pour comprendre et déboguer nos applications conteneurisées.


## **Chapitre 5 : Gestion du Logging dans Docker**

### **Objectifs de ce chapitre :**

*   Comprendre comment Docker capture les logs des conteneurs.
*   Maîtriser la commande `docker logs` et ses options utiles.
*   Découvrir le concept de "logging drivers" pour acheminer les logs.
*   Comprendre les bases de la configuration du logging (rotation des logs).
*   Appréhender l'importance de la centralisation des logs en production.

---

### **Partie 1 : Concepts Clés (Le "Magistral")**

#### **5.1 Pourquoi les logs sont-ils importants ?**

Dans n'importe quelle application, et encore plus dans un environnement conteneurisé où les processus sont isolés, les logs sont la **principale source d'information** pour :

*   **Débogage :** Comprendre les erreurs, les avertissements et le comportement inattendu d'une application.
*   **Monitoring :** Suivre l'état de santé de l'application, détecter les problèmes de performance.
*   **Audit & Sécurité :** Garder une trace des événements importants (qui a fait quoi, quand).
*   **Analyse :** Comprendre comment l'application est utilisée.

#### **5.2 Mécanisme de Logging par Défaut de Docker**

Par défaut, Docker est conçu pour capturer la **sortie standard (stdout)** et la **sortie d'erreur standard (stderr)** du processus principal (PID 1) qui s'exécute à l'intérieur du conteneur.

*   Lorsque vous lancez un conteneur (par exemple, `docker run mon-app`), Docker attache des "pipes" virtuels à ces flux de sortie.
*   Ce que l'application écrit sur `stdout` ou `stderr` est intercepté par le démon Docker.
*   Le démon stocke ensuite ces logs en utilisant un **"logging driver"**.

`[Image : Schéma simple montrant une Appli dans un Conteneur écrivant sur stdout/stderr -> Démon Docker interceptant -> Logging Driver -> Stockage (ex: fichier JSON)]`

#### **5.3 Les Logging Drivers**

Un **logging driver** détermine **où et comment** le démon Docker envoie les logs qu'il a capturés. Docker prend en charge plusieurs drivers :

*   **`json-file` (Défaut) :**
    *   Stocke les logs dans des fichiers JSON sur la machine hôte Docker.
    *   Emplacement typique (sur Linux) : `/var/lib/docker/containers/<container_id>/<container_id>-json.log`. Sur Docker Desktop, c'est géré en interne.
    *   **Avantages :** Simple, fonctionne partout, utilisé par `docker logs`.
    *   **Inconvénients :** Peut consommer beaucoup d'espace disque si non géré (rotation), pas adapté à la centralisation à grande échelle sans outils supplémentaires.

*   **`local` :**
    *   Similaire à `json-file` mais utilise un format interne optimisé pour le stockage, pas destiné à être lu directement par des humains ou des outils externes. Conçu pour une empreinte disque minimale.

*   **`journald` :**
    *   Envoie les logs au système `systemd journal` (disponible sur de nombreuses distributions Linux modernes).
    *   Permet d'utiliser les outils `journalctl` pour consulter les logs du conteneur avec ceux du système.

*   **`syslog` :**
    *   Envoie les logs à un démon `syslog` (local ou distant).
    *   Format standard, utile pour s'intégrer avec des systèmes de gestion de logs existants.

*   **`fluentd`, `gelf` (Graylog Extended Log Format) :**
    *   Envoient les logs vers des **agrégateurs de logs centralisés** (comme Fluentd, Logstash, Graylog). C'est la voie vers la centralisation robuste.

*   **`awslogs` (Amazon CloudWatch Logs), `gcplogs` (Google Cloud Logging), `azure-file` :**
    *   Intégration directe avec les services de logging des fournisseurs cloud respectifs.

*   **`splunk` :**
    *   Envoie les logs vers une instance Splunk.

*   **`none` :**
    *   Désactive complètement la capture des logs pour un conteneur. Utile dans certains cas spécifiques pour la performance, mais rend le débogage via `docker logs` impossible.

Vous pouvez configurer le logging driver **par défaut** pour tous les conteneurs au niveau du démon Docker, ou le **spécifier par conteneur** lors du `docker run` ou dans Docker Compose.

#### **5.4 Rotation des Logs (avec `json-file`)**

Avec le driver par défaut `json-file`, les fichiers de logs peuvent grossir indéfiniment si rien n'est fait. Il est crucial de configurer la **rotation des logs** pour éviter de saturer l'espace disque.

On peut définir des options comme :
*   `max-size` : Taille maximale d'un fichier de log avant rotation (ex: `10m` pour 10 mégaoctets).
*   `max-file` : Nombre maximum de fichiers de logs à conserver (ex: `3`). Quand un nouveau fichier est créé après rotation, le plus ancien est supprimé.

Cette configuration peut se faire au niveau du démon Docker (pour tous les conteneurs utilisant `json-file`) ou par conteneur.

---

### **Partie 2 : Commandes et Exercices**

#### **Exercice 5.1 : Exploration de `docker logs`**

Reprenons un conteneur simple qui génère des logs. Nous allons utiliser une image Alpine qui exécute une boucle `ping` (qui écrit sur stdout).

1.  **Lancez un conteneur en arrière-plan :**
    ```bash
    docker run -d --name pinger alpine sh -c "while true; do echo \$(date): Pinging...; ping -c 1 8.8.8.8 > /dev/null; sleep 5; done"
    ```
    *   `-d` : Détaché.
    *   `--name pinger` : Nom du conteneur.
    *   `alpine` : Image de base.
    *   `sh -c "..."` : La commande exécutée. Une boucle qui affiche la date et "Pinging..." toutes les 5 secondes. La sortie de `ping` elle-même est redirigée vers `/dev/null` pour ne pas polluer nos logs d'exemple.

2.  **Affichez les logs actuels :**
    ```bash
    docker logs pinger
    ```
    *   *Résultat attendu :* Vous verrez les quelques lignes de log générées depuis le démarrage du conteneur.

3.  **Suivez les logs en temps réel :**
    ```bash
    docker logs -f pinger
    # Ou : docker logs --follow pinger
    ```
    *   *Résultat attendu :* De nouvelles lignes `Mon Feb 27 10:30:05 UTC 2023: Pinging...` (date/heure actuelles) apparaissent toutes les 5 secondes. Appuyez sur `Ctrl + C` pour arrêter le suivi.

4.  **Affichez les N dernières lignes :**
    ```bash
    # Affiche les 3 dernières lignes de log
    docker logs --tail 3 pinger
    ```

5.  **Ajoutez des timestamps (ajoutés par Docker) :**
    ```bash
    docker logs -t pinger
    ```
    *   *Résultat attendu :* Chaque ligne est préfixée par un timestamp au format `YYYY-MM-DDTHH:MM:SS.mmmmmmmmmZ`. C'est utile si l'application elle-même ne met pas de timestamp dans ses logs.

6.  **Filtrez par date/heure (relatives) :**
    ```bash
    # Attendez une minute ou deux que des logs s'accumulent...

    # Affiche les logs des 30 dernières secondes
    docker logs --since 30s pinger

    # Affiche les logs générés depuis 1 minute
    docker logs --since 1m pinger
    ```

7.  **Filtrez par date/heure (absolues - exemple) :**
    ```bash
    # Note: Le format peut varier légèrement, mais ISO 8601 est généralement accepté
    # docker logs --since 2023-10-27T10:00:00 pinger
    # docker logs --until 2023-10-27T10:05:00 pinger
    ```

8.  **Nettoyez le conteneur :**
    ```bash
    docker stop pinger
    docker rm pinger
    ```

#### **Exercice 5.2 : Configuration de la Rotation des Logs (Démon Docker)**

Cette partie montre *comment* configurer, mais l'application réelle nécessite un redémarrage du démon Docker.

1.  **Localisez/Créez le fichier de configuration du démon :**
    *   **Linux :** Le fichier est généralement `/etc/docker/daemon.json`. S'il n'existe pas, créez-le.
    *   **Docker Desktop (Windows/macOS) :** Allez dans `Settings` -> `Docker Engine`. Vous verrez un éditeur JSON.

2.  **Ajoutez la configuration pour `json-file` :**
    Assurez-vous que le contenu du fichier est un JSON valide. S'il est vide, ajoutez :
    ```json
    {
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
    }
    ```
    Si le fichier existe déjà et contient d'autres clés, ajoutez simplement les clés `"log-driver"` et `"log-opts"` (ou modifiez les existantes) :
    ```json
    {
      "existing-key": "value",
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "10m",
        "max-file": "3"
      }
      // autres clés...
    }
    ```
    *   `"max-size": "10m"` : Chaque fichier log fera au maximum 10 Mo.
    *   `"max-file": "3"` : Docker conservera les 3 derniers fichiers de logs (donc au maximum 30 Mo d'historique pour ce conteneur).

3.  **Appliquez les changements :**
    *   **Linux :** Sauvegardez le fichier et redémarrez le service Docker :
        ```bash
        sudo systemctl restart docker
        ```
        **Attention :** Ceci va arrêter tous vos conteneurs en cours d'exécution !
    *   **Docker Desktop :** Cliquez sur "Apply & Restart".

4.  **Vérification (Conceptuelle) :** Après redémarrage, tous les *nouveaux* conteneurs démarrés utiliseront cette configuration de rotation. Pour vérifier, il faudrait générer plus de 10 Mo de logs dans un conteneur et vérifier le nombre et la taille des fichiers dans `/var/lib/docker/containers/...` (sur Linux) ou observer le comportement sur le long terme.

#### **Exercice 5.3 : Spécifier un Logging Driver par Conteneur**

Vous pouvez outrepasser la configuration par défaut pour un conteneur spécifique.

1.  **Lancez un conteneur en désactivant les logs :**
    ```bash
    docker run -d --name no-logs-container --log-driver none alpine sleep 300
    ```
2.  **Essayez de voir les logs :**
    ```bash
    docker logs no-logs-container
    ```
    *   *Résultat attendu :* Une erreur indiquant que le logging driver configuré (`none`) ne supporte pas la lecture des logs via `docker logs`.

3.  **(Si possible sur votre système) Lancez un conteneur avec le driver `journald` (Linux avec systemd) :**
    ```bash
    # Uniquement sur Linux avec systemd et journald fonctionnel
    # docker run -d --name journald-logs-container --log-driver journald alpine sh -c 'while true; do echo "Log vers Journald"; sleep 5; done'
    ```
4.  **(Si exécuté) Vérifiez les logs dans journald :**
    ```bash
    # journalctl -f CONTAINER_NAME=journald-logs-container
    # Ou plus généralement pour voir les logs de Docker :
    # journalctl -u docker.service -f
    ```
    *   Vous devriez voir les lignes "Log vers Journald" apparaître dans la sortie de `journalctl`.

5.  **Nettoyez :**
    ```bash
    docker stop no-logs-container journald-logs-container # Ignorez l'erreur si journald-logs-container n'existe pas
    docker rm no-logs-container journald-logs-container
    ```

#### **5.5 Centralisation des Logs (Discussion)**

Dans un environnement avec plusieurs conteneurs, potentiellement sur plusieurs machines, consulter les logs avec `docker logs` sur chaque machine devient ingérable.

La solution est la **centralisation des logs** :
1.  Configurez Docker (via un logging driver approprié comme `fluentd`, `gelf`, `syslog`, `awslogs`, etc.) pour envoyer les logs de tous les conteneurs vers un point central (l'agrégateur de logs).
2.  L'agrégateur collecte, parse, indexe et stocke les logs.
3.  Une interface (comme Kibana, Grafana Loki, Graylog UI, Splunk Search, CloudWatch Logs Console) permet de rechercher, visualiser et analyser les logs de toutes vos applications en un seul endroit.

`[Image : Schéma montrant plusieurs Hôtes Docker, chacun avec des Conteneurs -> Logging Driver (ex: fluentd) -> Réseau -> Serveur Fluentd/Logstash -> Elasticsearch/Loki -> Interface Kibana/Grafana]`

Utiliser un logging driver autre que `json-file` ou `local` est la première étape vers une stratégie de logging centralisée et robuste, indispensable en production.

---

### **Synthèse du Chapitre 5**

Vous avez maintenant une bonne compréhension de la gestion des logs dans Docker :

*   Docker capture **stdout/stderr** du processus principal.
*   La commande `docker logs` (avec `-f`, `--tail`, `--since`, `-t`) est votre outil de base pour consulter les logs d'un conteneur.
*   Les **logging drivers** contrôlent la destination des logs (`json-file` par défaut).
*   La **rotation des logs** est cruciale pour le driver `json-file` afin de gérer l'espace disque (options `max-size`, `max-file`).
*   Vous pouvez configurer le driver au niveau du **démon** ou **par conteneur**.
*   La **centralisation des logs** (via des drivers comme `fluentd`, `gelf`, `syslog`, ou des solutions cloud) est essentielle pour les environnements de production.

La prochaine étape concerne la communication entre les conteneurs et avec le monde extérieur : le réseau.

Très bien, abordons maintenant la communication entre les conteneurs et avec le monde extérieur : le réseau Docker.


## **Chapitre 6 : Gestion du Réseau dans Docker**

### **Objectifs de ce chapitre :**

*   Comprendre pourquoi la mise en réseau est essentielle pour les conteneurs.
*   Découvrir les principaux "network drivers" de Docker (`bridge`, `host`, `overlay`, `none`).
*   Comprendre le fonctionnement du réseau `bridge` par défaut et ses limitations.
*   Maîtriser la création et l'utilisation des réseaux `bridge` **définis par l'utilisateur** (la méthode recommandée).
*   Comprendre la résolution DNS automatique entre conteneurs sur les réseaux définis par l'utilisateur.
*   Savoir publier des ports pour rendre les services des conteneurs accessibles depuis l'extérieur.
*   Maîtriser les commandes de gestion des réseaux Docker.

---

### **Partie 1 : Concepts Clés (Le "Magistral")**

#### **6.1 Pourquoi un Réseau pour les Conteneurs ?**

Les conteneurs isolent les processus, mais les applications ont souvent besoin de communiquer :

*   **Entre elles :** Une application web (dans un conteneur) doit parler à une base de données (dans un autre conteneur).
*   **Avec le monde extérieur :** L'application web doit être accessible par les utilisateurs via leur navigateur (depuis l'extérieur du serveur Docker).
*   **Depuis l'extérieur vers l'intérieur :** Parfois, un conteneur doit pouvoir initier des connexions vers l'extérieur (par exemple, pour télécharger des mises à jour ou appeler une API externe).

Docker fournit un système de réseau flexible pour gérer ces scénarios.

#### **6.2 Les Network Drivers Docker**

Comme pour le logging, Docker utilise des **drivers réseau** pour définir comment un conteneur est connecté au réseau. Les principaux sont :

1.  **`bridge` (Pont - Le driver par défaut)** :
    *   **Fonctionnement :** Crée un réseau privé interne sur l'hôte Docker. Chaque conteneur connecté à ce réseau reçoit une adresse IP interne (par exemple, `172.17.0.2`, `172.17.0.3`). Les conteneurs sur le même réseau `bridge` peuvent communiquer entre eux en utilisant leurs adresses IP. Pour qu'un service d'un conteneur soit accessible depuis l'extérieur de l'hôte Docker, il faut **publier** un port (mapper un port de l'hôte vers un port du conteneur).
    *   **Isolation :** Fournit une isolation réseau par rapport à l'hôte. Les conteneurs ne sont pas directement accessibles de l'extérieur sans publication de ports.
    *   **Quand l'utiliser :** C'est le choix par défaut et convient aux applications autonomes ou lorsque les conteneurs doivent communiquer entre eux sur un seul hôte.

2.  **`host` (Hôte)** :
    *   **Fonctionnement :** Supprime l'isolation réseau entre le conteneur et l'hôte Docker. Le conteneur partage directement l'interface réseau de l'hôte. Si une application dans le conteneur écoute sur le port 80, elle est *directement* accessible sur le port 80 de l'hôte (pas besoin de `-p`).
    *   **Avantages :** Performances réseau potentiellement meilleures (pas de NAT), plus simple pour certains cas d'usage (quand le conteneur doit utiliser de nombreux ports).
    *   **Inconvénients :** **Aucune isolation réseau**, risque de conflits de ports (le conteneur ne peut pas utiliser un port déjà utilisé par l'hôte ou un autre conteneur en mode `host`). Moins sécurisé.
    *   **Quand l'utiliser :** Rarement pour des applications web classiques. Plutôt pour des conteneurs qui ont besoin d'accéder directement au matériel réseau ou quand la performance réseau est critique et l'isolation moins importante.

3.  **`overlay` (Superposition)** :
    *   **Fonctionnement :** Conçu pour les réseaux **multi-hôtes**. Il permet à des conteneurs s'exécutant sur différents hôtes Docker de communiquer entre eux comme s'ils étaient sur le même réseau privé. C'est le driver utilisé par défaut pour les services dans Docker Swarm (l'outil d'orchestration intégré de Docker) et est fondamental pour des orchestrateurs comme Kubernetes.
    *   **Quand l'utiliser :** Lorsque vous avez besoin de connecter des conteneurs répartis sur plusieurs machines (clusters).

4.  **`macvlan`** :
    *   **Fonctionnement :** Permet d'assigner une adresse MAC à un conteneur, le faisant apparaître sur le réseau comme une machine physique distincte (avec sa propre adresse IP sur le réseau local, pas seulement une IP interne Docker).
    *   **Quand l'utiliser :** Cas d'usage avancés, par exemple pour des applications qui doivent être directement sur le réseau local (certains systèmes de monitoring, applications legacy). Nécessite une configuration spécifique de l'interface réseau de l'hôte.

5.  **`none` (Aucun)** :
    *   **Fonctionnement :** Attache le conteneur à une pile réseau minimale, contenant uniquement l'interface de loopback (`lo`). Le conteneur n'a aucune connectivité réseau externe ou avec d'autres conteneurs.
    *   **Quand l'utiliser :** Pour des tâches qui n'ont absolument pas besoin de réseau (par exemple, un traitement de données par lot purement localisé dans le conteneur) ou pour une sécurité maximale quand aucune communication n'est requise.

#### **6.3 Les Réseaux par Défaut**

Quand Docker est installé, il crée automatiquement trois réseaux :

*   `bridge` : Le réseau de type `bridge` par défaut. Les conteneurs lancés sans l'option `--network` y sont connectés.
*   `host` : Le réseau de type `host`. Vous connectez un conteneur à ce réseau avec `docker run --network host ...`.
*   `none` : Le réseau de type `none`. Vous connectez un conteneur avec `docker run --network none ...`.

#### **6.4 Pourquoi Utiliser des Réseaux `bridge` Définis par l'Utilisateur ?**

Bien qu'il existe un réseau `bridge` par défaut, il est **fortement recommandé de créer vos propres réseaux `bridge`** pour vos applications. Pourquoi ?

1.  **Meilleure Isolation :** Par défaut, tous les conteneurs non explicitement attachés à un autre réseau sont sur le réseau `bridge` par défaut. Ils pourraient potentiellement (bien que ce ne soit pas trivial) interférer les uns avec les autres. Les réseaux définis par l'utilisateur fournissent un segment réseau dédié uniquement aux conteneurs que vous y connectez.
2.  **Résolution DNS Automatique par Nom de Conteneur :** C'est l'avantage **MAJEUR**. Sur un réseau `bridge` défini par l'utilisateur, les conteneurs peuvent se trouver et communiquer entre eux en utilisant simplement leur **nom de conteneur** comme nom d'hôte. Docker gère un serveur DNS interne pour ces réseaux. Sur le réseau `bridge` *par défaut*, cette résolution DNS par nom ne fonctionne pas automatiquement (il fallait utiliser l'ancienne option `--link`, maintenant déconseillée).
3.  **Gestion Dynamique :** Vous pouvez connecter et déconnecter des conteneurs de réseaux définis par l'utilisateur pendant qu'ils sont en cours d'exécution (`docker network connect` / `disconnect`), ce qui n'est pas possible avec le réseau `bridge` par défaut.

**En résumé : Pour toute application composée de plusieurs conteneurs qui doivent communiquer, créez un réseau `bridge` personnalisé pour eux.**

#### **6.5 Publication de Ports (`-p`, `--publish`)**

Rappel (vu au Chapitre 2) : Lorsque vous utilisez un réseau `bridge` (par défaut ou défini par l'utilisateur), les ports du conteneur ne sont pas accessibles depuis l'extérieur de l'hôte Docker par défaut. L'option `-p` ou `--publish` lors du `docker run` crée une règle de redirection de port sur l'hôte Docker.

*   **Syntaxe :**
    *   `-p <port_hôte>:<port_conteneur>` (ex: `-p 8080:80`) : Mappe le port `8080` de *toutes* les interfaces réseau de l'hôte vers le port `80` du conteneur.
    *   `-p <ip_hôte>:<port_hôte>:<port_conteneur>` (ex: `-p 127.0.0.1:8080:80`) : Mappe le port `8080` de l'interface *spécifique* de l'hôte (ici, localhost uniquement) vers le port `80` du conteneur.
    *   `-p <port_conteneur>` (ex: `-p 80`) : Mappe le port `80` du conteneur à un port *aléatoire disponible* sur l'hôte. Utile quand vous ne vous souciez pas du port hôte exact. Vous pouvez trouver le port attribué avec `docker ps`.

---

### **Partie 2 : Commandes et Exercices**

#### **Exercice 6.1 : Exploration des Réseaux Docker**

1.  **Lister les réseaux existants :**
    ```bash
    docker network ls
    ```
    *   *Résultat attendu :* Vous devriez voir au moins `bridge`, `host`, et `none`, chacun avec son `NETWORK ID`, `NAME`, et `DRIVER`.

2.  **Inspecter le réseau `bridge` par défaut :**
    ```bash
    docker network inspect bridge
    ```
    *   *Résultat attendu :* Un JSON détaillé. Cherchez :
        *   `"Driver": "bridge"`
        *   `"Scope": "local"`
        *   `"IPAM"` -> `"Config"` -> `"Subnet"` (par ex: `"172.17.0.0/16"`) et `"Gateway"` (par ex: `"172.17.0.1"`) : La plage d'adresses IP utilisée par ce réseau.
        *   `"Containers": {}` (normalement vide si aucun conteneur n'est lancé).

3.  **Lancez un conteneur simple (il sera sur le réseau `bridge` par défaut) :**
    ```bash
    docker run -d --name test-container alpine sleep infinity
    ```
    *   `sleep infinity` : Maintient le conteneur en vie indéfiniment sans rien faire.

4.  **Inspectez à nouveau le réseau `bridge` :**
    ```bash
    docker network inspect bridge
    ```
    *   *Résultat attendu :* Maintenant, dans la section `"Containers"`, vous devriez voir une entrée pour `test-container` avec son nom, son adresse MAC, et son adresse IPv4 (par exemple, `"172.17.0.2/16"`).

5.  **Inspectez le conteneur lui-même pour voir ses paramètres réseau :**
    ```bash
    docker inspect test-container
    ```
    *   *Résultat attendu :* Descendez jusqu'à la section `"NetworkSettings"`. Vous y trouverez des informations globales et, sous `"Networks"` -> `"bridge"`, les détails spécifiques à sa connexion au réseau `bridge` (IPAddress, Gateway, NetworkID, etc.).

6.  **Nettoyez :**
    ```bash
    docker stop test-container
    docker rm test-container
    ```

#### **Exercice 6.2 : Communication sur le Réseau `bridge` par Défaut (Limitations)**

1.  **Lancez deux conteneurs Nginx sur le réseau par défaut :**
    ```bash
    docker run -d --name nginx1 nginx:alpine
    docker run -d --name nginx2 nginx:alpine
    ```

2.  **Trouvez leurs adresses IP internes :**
    ```bash
    docker inspect nginx1 | grep IPAddress
    docker inspect nginx2 | grep IPAddress
    # Notez les adresses IP (ex: 172.17.0.2 et 172.17.0.3)
    ```
    *(Alternative: `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx1`)*

3.  **Essayez de pinguer `nginx2` depuis `nginx1` en utilisant l'adresse IP :** (Remplacez `<ip_nginx2>` par l'IP réelle)
    ```bash
    docker exec nginx1 ping -c 3 <ip_nginx2>
    ```
    *   *Résultat attendu :* Le ping devrait fonctionner. Les conteneurs sur le même réseau bridge peuvent communiquer par IP.

4.  **Essayez de pinguer `nginx2` depuis `nginx1` en utilisant son nom de conteneur :**
    ```bash
    docker exec nginx1 ping -c 3 nginx2
    ```
    *   *Résultat attendu :* **Échec !** (`ping: bad address 'nginx2'`). Le réseau `bridge` par défaut ne fournit pas de résolution DNS automatique par nom de conteneur.

5.  **Nettoyez :**
    ```bash
    docker stop nginx1 nginx2
    docker rm nginx1 nginx2
    ```

#### **Exercice 6.3 : Création et Utilisation d'un Réseau `bridge` Défini par l'Utilisateur**

1.  **Créez un nouveau réseau de type `bridge` :**
    ```bash
    docker network create mon-app-reseau
    ```

2.  **Vérifiez qu'il a été créé :**
    ```bash
    docker network ls
    # Vous devriez voir "mon-app-reseau" avec le driver "bridge"
    ```

3.  **Inspectez votre nouveau réseau :**
    ```bash
    docker network inspect mon-app-reseau
    ```
    *   Notez qu'il a sa propre plage d'adresses IP (Subnet, Gateway), différente de celle du `bridge` par défaut (par ex., `172.18.0.0/16`).

4.  **Lancez un conteneur "serveur" (Apache httpd) et connectez-le à ce réseau :**
    ```bash
    docker run -d --name serveur-web --network mon-app-reseau httpd:alpine
    ```
    *   `--network mon-app-reseau` : La clé pour connecter le conteneur à votre réseau.

5.  **Lancez un conteneur "client" (busybox) connecté au même réseau, en mode interactif :**
    ```bash
    # busybox contient des outils réseau de base comme ping, wget, nslookup
    docker run -it --rm --name client --network mon-app-reseau busybox sh
    ```
    *   `--rm` : Le conteneur sera supprimé quand vous quitterez le shell.
    *   Vous êtes maintenant dans le shell du conteneur `client`.

#### **Exercice 6.4 : Résolution DNS sur un Réseau Défini par l'Utilisateur**

1.  **Depuis le shell du conteneur `client` (ouvert à l'étape précédente) :**
    *   **Pinguez le conteneur `serveur-web` par son nom :**
        ```sh
        # Dans le shell du conteneur 'client'
        ping -c 3 serveur-web
        ```
        *   *Résultat attendu :* **Succès !** Le nom `serveur-web` est automatiquement résolu en l'adresse IP interne du conteneur `serveur-web` sur le réseau `mon-app-reseau`.

    *   **Utilisez `wget` pour récupérer la page d'accueil du serveur web :**
        ```sh
        # Dans le shell du conteneur 'client'
        wget -q -O - http://serveur-web/
        ```
        *   *Résultat attendu :* Vous devriez voir le code HTML de la page par défaut d'Apache httpd (souvent `<html><body><h1>It works!</h1></body></html>`).

    *   **(Optionnel) Utilisez `nslookup` pour voir la résolution DNS :**
        ```sh
        # Dans le shell du conteneur 'client'
        nslookup serveur-web
        ```
        *   *Résultat attendu :* Affiche l'adresse IP interne du conteneur `serveur-web` et l'adresse du serveur DNS utilisé (qui est un serveur DNS intégré à Docker, souvent `127.0.0.11`).

2.  **Quittez le shell du conteneur `client` :**
    ```sh
    exit
    ```
    *   Le conteneur `client` est automatiquement supprimé grâce à `--rm`.

#### **Exercice 6.5 : Connecter/Déconnecter des Conteneurs**

1.  **Vérifiez que `serveur-web` est toujours en cours d'exécution :**
    ```bash
    docker ps
    ```

2.  **Créez un second réseau :**
    ```bash
    docker network create autre-reseau
    ```

3.  **Connectez le conteneur `serveur-web` (qui est déjà en cours d'exécution) à ce nouveau réseau :**
    ```bash
    docker network connect autre-reseau serveur-web
    ```

4.  **Inspectez à nouveau le conteneur `serveur-web` :**
    ```bash
    docker inspect serveur-web
    ```
    *   *Résultat attendu :* Dans la section `NetworkSettings` -> `Networks`, vous devriez maintenant voir **deux** entrées : une pour `mon-app-reseau` et une pour `autre-reseau`. Le conteneur a une adresse IP distincte sur chaque réseau. Il est maintenant multi-domicilié (multi-homed).

5.  **Déconnectez le conteneur `serveur-web` du réseau `autre-reseau` :**
    ```bash
    docker network disconnect autre-reseau serveur-web
    ```

6.  **Inspectez une dernière fois pour vérifier :**
    ```bash
    docker inspect serveur-web
    ```
    *   *Résultat attendu :* Seule la connexion à `mon-app-reseau` devrait rester.

#### **Exercice 6.6 : Publication de Ports**

1.  **Arrêtez et supprimez le conteneur `serveur-web` actuel :**
    ```bash
    docker stop serveur-web
    docker rm serveur-web
    ```

2.  **Relancez le conteneur `serveur-web`, mais cette fois en publiant le port 80 du conteneur sur le port 8888 de votre hôte :**
    ```bash
    docker run -d --name serveur-web-expose --network mon-app-reseau -p 8888:80 httpd:alpine
    ```
    *   `-p 8888:80` : La partie clé ici.

3.  **Ouvrez votre navigateur web sur votre machine hôte** et allez à l'adresse `http://localhost:8888` (ou `http://<IP_machine_docker>:8888` si Docker n'est pas local).
    *   *Résultat attendu :* Vous devriez voir la page "It works!" d'Apache. Le trafic de votre navigateur arrive sur le port 8888 de l'hôte, Docker le redirige vers le port 80 du conteneur `serveur-web-expose` via le réseau `mon-app-reseau`.

#### **Exercice 6.7 : Nettoyage des Réseaux**

1.  **Arrêtez et supprimez les conteneurs restants :**
    ```bash
    docker stop serveur-web-expose
    docker rm serveur-web-expose
    ```

2.  **Essayez de supprimer un réseau qui contient (ou contenait récemment) des conteneurs (cela peut parfois échouer s'il y a des endpoints actifs) :**
    ```bash
    # Cette commande peut échouer si un endpoint est encore référencé
    # docker network rm mon-app-reseau
    ```
    *   Si elle échoue, assurez-vous qu'aucun conteneur n'est connecté. Parfois, un `docker container prune` peut aider.

3.  **Supprimez les réseaux que vous avez créés :**
    ```bash
    docker network rm mon-app-reseau
    docker network rm autre-reseau
    ```

4.  **Nettoyer tous les réseaux non utilisés (qui n'ont aucun conteneur connecté) :**
    ```bash
    docker network prune
    ```
    *   Docker demandera confirmation. Tapez `y`. Cela supprime les réseaux créés par l'utilisateur qui ne sont plus utilisés. Les réseaux par défaut (`bridge`, `host`, `none`) ne sont pas affectés.

---

### **Synthèse du Chapitre 6**

Vous maîtrisez maintenant les bases du réseau Docker :

*   Les conteneurs ont besoin de réseaux pour communiquer entre eux et avec l'extérieur.
*   Docker propose plusieurs **drivers réseau** (`bridge`, `host`, `overlay`, `none`, `macvlan`).
*   Le driver `bridge` est le plus courant pour les applications sur un seul hôte.
*   Il est **fortement recommandé** d'utiliser des **réseaux `bridge` définis par l'utilisateur** (`docker network create`) plutôt que le réseau `bridge` par défaut.
*   L'avantage principal des réseaux définis par l'utilisateur est la **résolution DNS automatique par nom de conteneur**.
*   La **publication de ports** (`docker run -p <host>:<container>`) est nécessaire pour accéder aux services des conteneurs sur un réseau `bridge` depuis l'extérieur.
*   Vous savez gérer les réseaux avec les commandes `ls`, `inspect`, `create`, `rm`, `connect`, `disconnect` et `prune`.

Nous avons vu comment lancer des conteneurs individuels, mais comment gérer des applications composées de plusieurs conteneurs (un serveur web, une base de données, une API) de manière cohérente ? C'est le rôle de Docker Compose.

Absolument ! Gérer plusieurs conteneurs individuellement avec des commandes `docker run` longues et complexes devient vite fastidieux. C'est là qu'intervient Docker Compose, un outil puissant pour définir et exécuter des applications multi-conteneurs.



## **Chapitre 7 : Orchestration Simple avec Docker Compose**

### **Objectifs de ce chapitre :**

*   Comprendre le rôle et les avantages de Docker Compose.
*   Maîtriser la syntaxe de base du fichier `docker-compose.yml`.
*   Définir et lier plusieurs services (conteneurs) ensemble.
*   Utiliser Docker Compose pour gérer le cycle de vie complet d'une application multi-conteneurs (démarrage, arrêt, logs, etc.).
*   Comprendre comment Compose gère les réseaux et les volumes (introduction).

---

### **Partie 1 : Concepts Clés (Le "Magistral")**

#### **7.1 Qu'est-ce que Docker Compose ?**

Docker Compose est un outil (inclus avec Docker Desktop, installable séparément ou comme plugin sur Linux) qui permet de **définir et gérer des applications Docker multi-conteneurs** à l'aide d'un simple fichier de configuration YAML : `docker-compose.yml`.

**Problème résolu :** Imaginez une application web typique :
*   Un conteneur pour le serveur web (Nginx, Apache).
*   Un conteneur pour l'application backend (Python/Flask, Node.js/Express, PHP).
*   Un conteneur pour la base de données (PostgreSQL, MySQL, MongoDB).
*   Peut-être un conteneur pour un cache (Redis).

Lancer chacun de ces conteneurs avec `docker run` nécessiterait des commandes longues, avec la gestion manuelle des réseaux pour qu'ils communiquent, la configuration des ports, des volumes, des variables d'environnement, etc. C'est répétitif, sujet aux erreurs et difficile à maintenir.

**Solution Docker Compose :** Vous décrivez l'ensemble de votre application (tous les services, réseaux, volumes) dans un fichier `docker-compose.yml`. Ensuite, avec une seule commande (`docker compose up`), Docker Compose s'occupe de :
*   Créer les réseaux nécessaires (par défaut, un réseau `bridge` personnalisé pour l'application).
*   Créer les volumes nécessaires.
*   Construire les images si nécessaire (à partir de Dockerfiles).
*   Démarrer les conteneurs (services) dans le bon ordre (si `depends_on` est utilisé).
*   Attacher les conteneurs aux réseaux.
*   Et bien plus encore...

Avec une autre commande (`docker compose down`), vous pouvez arrêter et supprimer tous les conteneurs, réseaux et (optionnellement) volumes créés pour cette application.

#### **7.2 Le Fichier `docker-compose.yml`**

C'est le cœur de Docker Compose. C'est un fichier texte au format [YAML](https://fr.wikipedia.org/wiki/YAML) (YAML Ain't Markup Language), qui est un format de sérialisation de données lisible par l'homme. L'indentation (espaces, pas de tabulations !) est cruciale en YAML pour définir la structure.

Structure générale d'un fichier `docker-compose.yml` :

```yaml
# Version du format de fichier Compose (important pour la compatibilité)
version: '3.8' # Ou une version plus récente si nécessaire

# Définition des services (conteneurs)
services:
  # Nom logique du premier service (ex: web, frontend)
  web:
    # Configuration du service 'web'
    image: nginx:alpine # Utiliser une image existante
    # ou
    # build: . # Construire depuis un Dockerfile dans le répertoire courant
    container_name: mon-serveur-web # Nom spécifique du conteneur (optionnel)
    ports:
      - "8080:80" # Publier port hôte:conteneur
    volumes:
      - ./html:/usr/share/nginx/html # Monter un répertoire local (plus de détails au chap. suivant)
      - data-volume:/var/data # Utiliser un volume nommé
    networks:
      - front-tier # Connecter à un réseau spécifique
    environment:
      - NGINX_HOST=example.com
      - NGINX_PORT=80
    depends_on:
      - api # Indique que 'api' doit démarrer avant 'web'

  # Nom logique du second service (ex: api, backend)
  api:
    image: mon-api-perso:1.0
    container_name: mon-api
    networks:
      - front-tier
      - back-tier
    environment:
      - DATABASE_HOST=db # Communication via le nom du service !
    depends_on:
      - db

  # Nom logique du service de base de données
  db:
    image: postgres:14-alpine
    container_name: ma-base-de-donnees
    environment:
      POSTGRES_DB: ma_bdd
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password # Attention: pas idéal pour la prod, utiliser des secrets
    volumes:
      - db-data:/var/lib/postgresql/data # Volume nommé pour la persistance des données
    networks:
      - back-tier

# Définition des réseaux personnalisés
networks:
  front-tier:
    driver: bridge # Le driver par défaut
  back-tier:
    driver: bridge

# Définition des volumes nommés
volumes:
  db-data:
    driver: local # Le driver par défaut
  data-volume:
```

**Concepts Clés dans le fichier :**

*   **`version`**: Spécifie la version du schéma du fichier Compose. Cela détermine les fonctionnalités disponibles. `'3.8'` est une version courante et stable.
*   **`services`**: Définit les différents conteneurs qui composent votre application. Chaque clé sous `services` est un **nom de service** logique (ex: `web`, `api`, `db`). Ce nom est important car il sera utilisé pour la résolution DNS entre les services sur le réseau créé par Compose.
*   **`image`**: Spécifie l'image Docker à utiliser pour le service (comme dans `docker run`).
*   **`build`**: Alternative à `image`. Permet de construire une image à partir d'un Dockerfile local. Vous pouvez spécifier le contexte (`context: .`) et le nom du Dockerfile (`dockerfile: Dockerfile.prod`).
*   **`container_name`**: Donne un nom fixe au conteneur. Si omis, Compose génère un nom unique (ex: `projet_web_1`).
*   **`ports`**: Publie des ports (syntaxe : `"<port_hôte>:<port_conteneur>"`).
*   **`environment`**: Définit des variables d'environnement dans le conteneur (peut être une liste ou un dictionnaire).
*   **`volumes`**: Monte des volumes ou des répertoires de l'hôte dans le conteneur (syntaxe : `<source>:<destination>`). Nous détaillerons les volumes au prochain chapitre.
*   **`networks`**: Connecte le service à des réseaux spécifiques définis dans la section `networks` (ou au réseau par défaut s'il n'est pas spécifié).
*   **`depends_on`**: Définit une dépendance de démarrage simple. Compose démarrera les services listés sous `depends_on` *avant* de démarrer le service courant. **Important :** Cela ne garantit que le démarrage du conteneur, pas que l'application à l'intérieur soit prête à recevoir des connexions. Pour une gestion plus fine, des mécanismes de "healthcheck" sont nécessaires.
*   **`networks` (section racine)**: Permet de définir des réseaux personnalisés (équivalent à `docker network create`). Si cette section est omise, Compose crée un réseau `bridge` par défaut nommé `<nom_projet>_default`.
*   **`volumes` (section racine)**: Permet de définir des volumes nommés (équivalent à `docker volume create`).

#### **7.3 Installation de Docker Compose**

*   **Docker Desktop (Windows, macOS) :** Docker Compose est **inclus** par défaut. Vous utiliserez la commande `docker compose ...` (notez l'espace, c'est la V2 intégrée).
*   **Linux (avec Docker Engine) :**
    *   **Méthode recommandée (Compose V2 - Plugin) :** Il est souvent installé avec le moteur Docker via le paquet `docker-compose-plugin` (comme vu au Chapitre 1). La commande est `docker compose ...` (avec un espace).
    *   **Ancienne méthode (Compose V1 - Standalone) :** Vous pouviez l'installer comme un binaire Python séparé. La commande était `docker-compose ...` (avec un tiret). Cette version est moins maintenue et il est conseillé de passer à la V2.
    *   **Vérification :** Essayez `docker compose version`. Si cela fonctionne, vous avez la V2. Sinon, essayez `docker-compose --version`. Si vous avez besoin de l'installer, suivez la documentation officielle Docker pour le plugin (`docker-compose-plugin`).

Pour ce cours, nous utiliserons la syntaxe **`docker compose ...` (V2)**. Si seule la V1 fonctionne pour vous, remplacez simplement l'espace par un tiret.

---

### **Partie 2 : Exercices Pratiques**

Créez un nouveau dossier pour ce chapitre, par exemple `compose-app`.

```bash
mkdir compose-app
cd compose-app
```

#### **Exercice 7.1 : Un Service Simple avec Compose**

Définissons un service Nginx simple.

1.  **Créez le fichier `docker-compose.yml` :**
    ```yaml
    # compose-app/docker-compose.yml
    version: '3.8'

    services:
      webserver:
        image: nginx:alpine
        container_name: compose-nginx
        ports:
          - "8081:80" # Utilisons 8081 pour éviter les conflits
    ```

2.  **Démarrez l'application :** Dans le terminal, depuis le dossier `compose-app` :
    ```bash
    docker compose up -d
    ```
    *   `-d` : Mode détaché (arrière-plan).
    *   *Résultat attendu :* Compose va :
        *   Créer un réseau par défaut (ex: `compose-app_default`).
        *   Tirer l'image `nginx:alpine` si elle n'est pas locale.
        *   Créer et démarrer le conteneur `compose-nginx`, le connecter au réseau et publier le port.
        Vous verrez des lignes comme `Creating network "compose-app_default"`, `Creating compose-nginx ... done`.

3.  **Vérifiez les conteneurs en cours :**
    ```bash
    docker compose ps
    ```
    *   *Résultat attendu :* Liste le service `webserver` avec son nom de conteneur (`compose-nginx`), la commande, l'état (`running` ou `up`) et les ports (`0.0.0.0:8081->80/tcp`).
    *   Vous pouvez aussi utiliser `docker ps` pour voir le conteneur.

4.  **Vérifiez le réseau créé :**
    ```bash
    docker network ls
    ```
    *   Vous devriez voir le réseau `compose-app_default` (ou un nom similaire basé sur le nom de votre dossier).

5.  **Accédez au service :** Ouvrez votre navigateur sur `http://localhost:8081`. Vous devriez voir la page d'accueil Nginx.

6.  **Consultez les logs :**
    ```bash
    docker compose logs webserver
    # Pour suivre les logs :
    # docker compose logs -f webserver
    ```

7.  **Arrêtez et supprimez les ressources :**
    ```bash
    docker compose down
    ```
    *   *Résultat attendu :* Compose arrête le conteneur `compose-nginx`, le supprime, et supprime le réseau `compose-app_default`. Vous verrez des lignes comme `Stopping compose-nginx ... done`, `Removing compose-nginx ... done`, `Removing network compose-app_default`.
    *   Vérifiez avec `docker ps -a` et `docker network ls` que tout a disparu.

#### **Exercice 7.2 : Application Multi-Services (Web + "API" simple)**

Simulons une application avec un serveur Nginx et une "API" simple (ici, juste un autre conteneur web pour l'exemple).

1.  **Modifiez le fichier `docker-compose.yml` :**
    ```yaml
    # compose-app/docker-compose.yml
    version: '3.8'

    services:
      # Service "Frontend" (Nginx)
      frontend:
        image: nginx:alpine
        container_name: compose-frontend
        ports:
          - "8082:80" # Nouveau port pour cet exercice
        networks:
          - app-net # Connecté au réseau personnalisé

      # Service "Backend" (simulé par Apache httpd ici)
      backend:
        image: httpd:alpine # Image Apache httpd légère
        container_name: compose-backend
        networks:
          - app-net # Connecté au même réseau

    # Définition du réseau personnalisé
    networks:
      app-net:
        driver: bridge
    ```

2.  **Démarrez l'application :**
    ```bash
    docker compose up -d
    ```
    *   *Résultat attendu :* Compose crée le réseau `app-net`, puis démarre les conteneurs `compose-frontend` et `compose-backend` en les connectant à `app-net`.

3.  **Vérifiez les services :**
    ```bash
    docker compose ps
    ```
    *   Vous devriez voir les deux services `frontend` et `backend` en cours d'exécution.

4.  **Testez la communication inter-services :** Entrons dans le conteneur `frontend` (Nginx) et essayons d'atteindre le `backend` (httpd) en utilisant son nom de service.
    ```bash
    docker compose exec frontend sh
    ```
    *   Vous êtes maintenant dans le shell du conteneur `frontend`.
    *   **Installez `curl` (non présent dans `nginx:alpine` par défaut) :**
        ```sh
        # Dans le shell du conteneur frontend
        apk update && apk add curl
        ```
    *   **Essayez d'accéder au service `backend` sur son port 80 (port par défaut de httpd) :**
        ```sh
        # Dans le shell du conteneur frontend
        curl http://backend/
        ```
        *   *Résultat attendu :* **Succès !** Vous devriez voir le HTML `<html><body><h1>It works!</h1></body></html>` retourné par le conteneur `backend` (Apache httpd). Cela démontre la résolution DNS automatique fournie par Compose sur le réseau personnalisé `app-net`. Le nom `backend` a été résolu en l'adresse IP interne du conteneur `compose-backend`.
    *   **Quittez le shell du conteneur :**
        ```sh
        exit
        ```

5.  **Nettoyez :**
    ```bash
    docker compose down
    ```

#### **Exercice 7.3 : Utilisation de `build` avec Compose**

Créons une petite API Flask et utilisons Compose pour la builder et la lancer avec Nginx comme proxy.

1.  **Créez un sous-dossier `api` :**
    ```bash
    mkdir api
    cd api
    ```
2.  **Créez un fichier `app.py` simple :**
    ```python
    # compose-app/api/app.py
    from flask import Flask
    import os

    app = Flask(__name__)

    @app.route('/')
    def hello():
        target = os.environ.get('TARGET', 'World')
        message = f"Hello {target} from the API!\n"
        return message

    if __name__ == "__main__":
        # Écoute sur toutes les interfaces, port 5000 (standard pour Flask dev)
        app.run(host='0.0.0.0', port=5000)
    ```
3.  **Créez un fichier `requirements.txt` :**
    ```
    # compose-app/api/requirements.txt
    Flask==2.2.2 # Mettez une version récente de Flask
    ```
4.  **Créez un `Dockerfile` pour l'API :**
    ```dockerfile
    # compose-app/api/Dockerfile
    FROM python:3.9-slim

    WORKDIR /app

    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt

    COPY app.py .

    # Variable d'environnement par défaut
    ENV TARGET="Docker Compose"

    # Port sur lequel l'app écoute dans le conteneur
    EXPOSE 5000

    # Commande pour lancer l'app
    CMD ["python", "app.py"]
    ```
5.  **Revenez au dossier parent `compose-app` :**
    ```bash
    cd ..
    ```
6.  **Modifiez le fichier `docker-compose.yml` :**
    ```yaml
    # compose-app/docker-compose.yml
    version: '3.8'

    services:
      # Service API construit localement
      api:
        build: ./api # Chemin vers le contexte de build (contenant le Dockerfile)
        container_name: compose-api
        environment:
          # On peut surcharger la variable d'env ici si besoin
          # TARGET: "Mon Test"
          # Pas de 'ports' ici, Nginx y accédera via le réseau interne
        networks:
          - api-net

      # Service Nginx (utilisera une image standard)
      proxy:
        image: nginx:alpine
        container_name: compose-proxy
        ports:
          - "8083:80" # Port pour accéder via le navigateur
        volumes:
          # On va monter une conf Nginx personnalisée pour faire proxy
          - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro # :ro = read-only
        networks:
          - api-net
        depends_on:
          - api # S'assurer que l'API démarre avant Nginx (démarrage seulement)

    networks:
      api-net:
        driver: bridge
    ```
7.  **Créez le fichier de configuration Nginx `nginx.conf` :** Ce fichier dira à Nginx de transférer les requêtes vers notre service `api`.
    ```nginx
    # compose-app/nginx.conf
    server {
        listen 80;
        server_name localhost;

        location / {
            # Nom du service 'api' défini dans docker-compose.yml
            # Nginx utilisera la résolution DNS de Docker Compose
            proxy_pass http://api:5000; # Le port exposé par Flask DANS le conteneur
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```
8.  **Démarrez l'application (Compose va builder l'image `api`) :**
    ```bash
    docker compose up -d --build
    ```
    *   `--build` : Force Compose à reconstruire les images définies avec `build`, même si une version précédente existe. Utile après avoir modifié le Dockerfile ou le code source.
    *   *Résultat attendu :* Compose exécute les étapes du `Dockerfile` de l'API, puis démarre les deux conteneurs.

9.  **Testez :** Ouvrez votre navigateur sur `http://localhost:8083`.
    *   *Résultat attendu :* Vous devriez voir `Hello Docker Compose from the API!` (ou le message avec la variable `TARGET` si vous l'avez surchargée). Votre navigateur parle à Nginx (`proxy` sur le port 8083), Nginx utilise la résolution DNS pour trouver `api` sur le réseau `api-net` et lui transmet la requête sur le port 5000.

10. **Nettoyez :**
    ```bash
    docker compose down
    ```
    *   Vous pouvez aussi supprimer l'image API créée si vous le souhaitez : `docker rmi compose-app-api` (le nom est souvent `<nom_dossier>-<nom_service>`).

#### **Exercice 7.4 : Autres Commandes Compose Utiles**

Utilisez le `docker-compose.yml` de l'exercice 7.3.

1.  **Démarrez en arrière-plan :**
    ```bash
    docker compose up -d
    ```
2.  **Lister les services :**
    ```bash
    docker compose ps
    ```
3.  **Voir les logs de l'API seulement :**
    ```bash
    docker compose logs api
    ```
4.  **Exécuter une commande dans le service `api` :**
    ```bash
    docker compose exec api ls -l /app
    ```
5.  **Arrêter les services (sans les supprimer) :**
    ```bash
    docker compose stop
    docker compose ps # Devraient être en état 'exited'
    ```
6.  **Redémarrer les services :**
    ```bash
    docker compose start
    docker compose ps # Devraient être 'running'
    ```
7.  **Forcer la reconstruction de l'image `api` :**
    ```bash
    docker compose build api
    ```
8.  **Valider et afficher la configuration finale (utile pour le débogage) :**
    ```bash
    docker compose config
    ```
9.  **Arrêter et supprimer les conteneurs et réseaux :**
    ```bash
    docker compose down
    ```
10. **Arrêter et supprimer conteneurs, réseaux ET volumes nommés (si on en avait défini avec `volumes:`) :**
    ```bash
    # Pas de volumes nommés dans cet exemple précis, mais la commande est :
    # docker compose down -v
    ```

---

### **Synthèse du Chapitre 7**

Docker Compose est un outil indispensable pour travailler avec des applications multi-conteneurs, en particulier en développement et pour des déploiements simples.

*   Il utilise un fichier `docker-compose.yml` (format YAML) pour décrire les **services**, **réseaux**, et **volumes** de l'application.
*   Il simplifie énormément le cycle de vie : `docker compose up` pour tout démarrer, `docker compose down` pour tout arrêter et nettoyer.
*   Il crée automatiquement un **réseau `bridge` personnalisé**, permettant la **résolution DNS facile entre les services** via leur nom (ex: `http://api:5000`, `postgres://db:5432`).
*   Il peut **construire des images** à partir de Dockerfiles (`build:`).
*   Vous maîtrisez les commandes essentielles : `up`, `down`, `ps`, `logs`, `exec`, `stop`, `start`, `build`, `config`.

Nous avons mentionné les `volumes` à plusieurs reprises pour monter du code ou persister des données. Le prochain chapitre se concentrera spécifiquement sur la gestion des données avec Docker.

Parfait ! Abordons maintenant un sujet crucial pour toute application ayant besoin de conserver des données au-delà du cycle de vie d'un conteneur : la gestion des données avec Docker.

---

## **Chapitre 8 : Gestion des Données (Volumes et Bind Mounts)**

### **Objectifs de ce chapitre :**

*   Comprendre pourquoi la gestion des données est nécessaire avec les conteneurs.
*   Distinguer les deux mécanismes principaux : **Volumes** et **Bind Mounts**.
*   Comprendre les cas d'usage, avantages et inconvénients de chacun.
*   Maîtriser les commandes pour créer et gérer des volumes nommés.
*   Savoir utiliser les volumes et les bind mounts dans les commandes `docker run` et les fichiers `docker-compose.yml`.
*   Comprendre le concept de `tmpfs` mounts (stockage temporaire en mémoire).

---

### **Partie 1 : Concepts Clés (Le "Magistral")**

#### **8.1 Le Problème : La Nature Éphémère des Conteneurs**

Par défaut, lorsqu'un conteneur est supprimé (`docker rm`), toutes les données créées ou modifiées *à l'intérieur* de sa couche d'écriture sont **perdues définitivement**. C'est la nature éphémère des conteneurs.

Cependant, la plupart des applications ont besoin de **persister** des données :

*   **Bases de données :** Les fichiers de données doivent survivre aux redémarrages ou aux mises à jour du conteneur de la base de données.
*   **Fichiers uploadés par les utilisateurs :** Ces fichiers doivent être conservés même si le conteneur de l'application web est remplacé.
*   **Fichiers de configuration :** Vous pourriez vouloir injecter ou modifier des fichiers de configuration sans avoir à reconstruire l'image.
*   **Code source en développement :** Vous voulez que les modifications de votre code sur votre machine hôte soient immédiatement reflétées dans le conteneur pour un développement rapide, sans reconstruire l'image à chaque changement.

Docker offre principalement deux mécanismes pour gérer ces données persistantes ou partagées, en les stockant *en dehors* de la couche d'écriture du conteneur : les **Volumes** et les **Bind Mounts**.

#### **8.2 Les Volumes Docker**

*   **Quoi :** Les volumes sont le mécanisme **préféré et recommandé** pour persister les données générées et utilisées par les conteneurs Docker.
*   **Où sont-ils stockés ?** Les volumes sont gérés **par Docker lui-même**. Ils sont stockés dans une zone dédiée sur le système de fichiers de l'hôte (par exemple, `/var/lib/docker/volumes/` sur Linux), mais l'utilisateur n'est **pas censé manipuler directement** les fichiers dans cette zone. Docker s'occupe de leur gestion.
*   **Comment les utiliser :**
    *   **Volumes Anonymes :** Créés automatiquement par Docker si vous spécifiez juste un chemin dans le conteneur (ex: `docker run -v /var/lib/mysql ...`). Ils ont un nom long et aléatoire. Difficiles à référencer plus tard. **À éviter généralement.**
    *   **Volumes Nommés (Recommandé) :** Vous leur donnez un nom spécifique (ex: `docker run -v db-data:/var/lib/mysql ...`). C'est beaucoup plus facile à gérer, sauvegarder, partager entre conteneurs. C'est la méthode standard.
*   **Avantages :**
    *   **Gérés par Docker :** Plus facile à sauvegarder, migrer, gérer via les commandes Docker (`docker volume ls`, `create`, `inspect`, `rm`, `prune`).
    *   **Indépendants du système de fichiers de l'hôte :** Fonctionnent de la même manière sur Linux, Windows, macOS. Votre structure de dossiers sur l'hôte n'a pas d'importance.
    *   **Performance :** Peuvent offrir de meilleures performances pour les opérations d'I/O intensives sur certaines plateformes (car Docker peut optimiser le stockage).
    *   **Sécurité :** N'expose pas la structure de fichiers ou le contenu de l'hôte au conteneur (sauf le contenu du volume lui-même).
    *   **Pré-population :** Si vous montez un volume nommé sur un répertoire du conteneur qui contient déjà des fichiers dans l'image, Docker copie ces fichiers depuis l'image vers le volume la *première fois* qu'il est monté (utile pour les configurations par défaut).
    *   **Partage facile :** Plusieurs conteneurs peuvent utiliser le même volume nommé simultanément.
*   **Inconvénients :**
    *   Accès direct depuis l'hôte moins évident (il faut passer par un conteneur ou des outils Docker).
*   **Cas d'usage typiques :** Stockage de données de bases de données, fichiers de configuration gérés par l'application, données d'état, etc. Bref, toutes les données que le **conteneur doit persister**.

#### **8.3 Les Bind Mounts**

*   **Quoi :** Permettent de monter (rendre accessible) un **fichier ou un répertoire existant sur la machine hôte** directement dans un conteneur.
*   **Où sont-ils stockés ?** Les données résident directement sur le système de fichiers de l'hôte, à l'emplacement que *vous* spécifiez. Docker ne fait que créer un lien.
*   **Comment les utiliser :** Spécifier le chemin absolu (ou relatif par rapport au `docker-compose.yml`) sur l'hôte et le chemin dans le conteneur (ex: `docker run -v /chemin/sur/hote:/chemin/dans/conteneur ...`).
*   **Avantages :**
    *   **Accès direct :** Les fichiers sont directement accessibles et modifiables depuis l'hôte et le conteneur.
    *   **Développement rapide :** Idéal pour monter le code source pendant le développement. Vous modifiez le code sur l'hôte avec votre IDE, et les changements sont immédiatement visibles par l'application dans le conteneur (souvent utilisé avec des outils de rechargement à chaud).
    *   **Partage de configuration :** Facile pour injecter des fichiers de configuration depuis l'hôte vers le conteneur.
*   **Inconvénients :**
    *   **Dépendance de l'hôte :** Fortement lié à la structure de fichiers de l'hôte. Si le chemin source n'existe pas, Docker peut le créer (souvent comme un répertoire vide), ce qui peut être inattendu. Sur les versions plus récentes, une erreur peut être levée.
    *   **Portabilité limitée :** Une application configurée avec des bind mounts peut ne pas fonctionner telle quelle sur une autre machine si la structure de répertoires est différente.
    *   **Permissions :** Peut entraîner des problèmes de permissions complexes (l'UID/GID de l'utilisateur sur l'hôte peut ne pas correspondre à celui dans le conteneur).
    *   **Sécurité :** Le conteneur peut potentiellement modifier n'importe quoi dans le répertoire monté sur l'hôte (risque si le conteneur est compromis).
    *   **Performance :** Peut être moins performant que les volumes sur certaines plateformes pour beaucoup d'I/O.
    *   **Pas de pré-population :** Si vous montez un bind mount sur un répertoire du conteneur qui contenait des fichiers dans l'image, ces fichiers de l'image sont **masqués** par le montage. Le conteneur ne verra que le contenu du répertoire de l'hôte.
*   **Cas d'usage typiques :** Montage du code source en développement, injection de fichiers de configuration spécifiques à l'environnement, partage d'outils ou de fichiers entre l'hôte et le conteneur.

#### **8.4 Tableau Comparatif**

| Caractéristique       | Volume Nommé                                   | Bind Mount                                           |
| --------------------- | ---------------------------------------------- | ---------------------------------------------------- |
| **Gestion**           | Par Docker                                     | Par l'utilisateur sur l'hôte                         |
| **Emplacement Hôte**  | Zone Docker (`/var/lib/docker/volumes/...`)   | Chemin spécifique défini par l'utilisateur           |
| **Portabilité**       | Haute                                          | Basse (dépend de la structure hôte)                |
| **Performance I/O**   | Potentiellement meilleure                      | Potentiellement moins bonne (selon OS)             |
| **Sécurité**          | Moins de surface d'attaque sur l'hôte        | Peut exposer des parties de l'hôte                 |
| **Usage Principal**   | **Persistance des données d'application** (DB) | **Développement (code)**, Configs depuis l'hôte      |
| **Pré-population**    | Oui (copie depuis l'image au 1er montage)    | Non (masque le contenu de l'image)                  |
| **Création Auto.**    | Volume créé si non existant                    | Répertoire créé si non existant (comportement variable) |
| **Commande / Syntaxe**| `-v nom-volume:/chemin/conteneur`              | `-v /chemin/hote:/chemin/conteneur`                  |

`[Image : Schéma montrant un conteneur. Une flèche sort vers un disque "Volume Géré par Docker". Une autre flèche sort vers un dossier spécifique sur le "Système Hôte" marqué "Bind Mount".]`

#### **8.5 `tmpfs` Mounts**

*   **Quoi :** Un troisième type de montage qui stocke les données **uniquement en mémoire vive (RAM)** de l'hôte, et jamais sur le disque.
*   **Caractéristiques :** Extrêmement rapide, mais **totalement volatile**. Les données disparaissent dès que le conteneur s'arrête.
*   **Quand l'utiliser :** Pour stocker des données temporaires non critiques où la performance est essentielle (par exemple, des fichiers de cache internes, des secrets temporaires pendant l'exécution).
*   **Syntaxe :** `docker run --mount type=tmpfs,destination=/chemin/dans/conteneur ...` ou l'option plus ancienne `--tmpfs /chemin/dans/conteneur`.

---

### **Partie 2 : Commandes et Exercices**

#### **Exercice 8.1 : Utilisation des Volumes Nommés**

1.  **Créer un volume nommé :**
    ```bash
    docker volume create mes-donnees-app
    ```

2.  **Lister les volumes :**
    ```bash
    docker volume ls
    ```
    *   *Résultat attendu :* Vous devriez voir `mes-donnees-app` dans la liste (avec le driver `local`).

3.  **Inspecter le volume :**
    ```bash
    docker volume inspect mes-donnees-app
    ```
    *   *Résultat attendu :* Affiche le nom, le driver, le "Mountpoint" (le chemin réel sur l'hôte où Docker stocke les données - *ne pas y toucher directement*), et d'autres informations.

4.  **Lancer un conteneur qui utilise ce volume :** Montons le volume sur `/data` dans un conteneur Alpine et écrivons un fichier.
    ```bash
    docker run -it --rm \
      --name=volume-testeur \
      -v mes-donnees-app:/data \
      alpine sh
    ```
    *   `-v mes-donnees-app:/data` : Monte le volume nommé `mes-donnees-app` sur le répertoire `/data` dans le conteneur. Si `/data` n'existe pas, il est créé.
    *   Vous êtes maintenant dans le shell du conteneur.

5.  **À l'intérieur du conteneur `volume-testeur` :**
    *   Allez dans le répertoire monté : `cd /data`
    *   Créez un fichier : `echo "Données persistantes !" > mon_fichier.txt`
    *   Vérifiez qu'il existe : `ls -l`
    *   Affichez son contenu : `cat mon_fichier.txt`
    *   Quittez le conteneur : `exit` (le conteneur est supprimé grâce à `--rm`).

6.  **Lancez un *nouveau* conteneur utilisant le même volume :**
    ```bash
    docker run -it --rm \
      --name=volume-verificateur \
      -v mes-donnees-app:/appdata \
      alpine sh
    ```
    *   Notez qu'on monte le *même* volume `mes-donnees-app`, mais sur un point de montage *différent* (`/appdata`) dans ce nouveau conteneur.

7.  **À l'intérieur du conteneur `volume-verificateur` :**
    *   Allez dans le répertoire monté : `cd /appdata`
    *   Listez les fichiers : `ls -l`
    *   *Résultat attendu :* Vous devriez voir `mon_fichier.txt` ! Le fichier créé dans le premier conteneur est toujours là, car il a été écrit dans le volume qui persiste indépendamment des conteneurs.
    *   Affichez son contenu : `cat mon_fichier.txt`
    *   Quittez le conteneur : `exit`.

8.  **Supprimer le volume :**
    ```bash
    docker volume rm mes-donnees-app
    ```
    *   **Attention :** Cela supprime définitivement toutes les données stockées dans le volume !

9.  **Nettoyer les volumes non utilisés :**
    ```bash
    docker volume prune
    ```
    *   Supprime tous les volumes locaux *non attachés* à au moins un conteneur (même arrêté). Demande confirmation.

#### **Exercice 8.2 : Utilisation des Bind Mounts (Développement)**

1.  **Créez un dossier sur votre machine hôte et un fichier dedans :**
    ```bash
    # Sur votre machine hôte
    mkdir projet-code
    cd projet-code
    echo "<h1>Version 1 du Code</h1>" > index.html
    ```

2.  **Lancez un conteneur Nginx en montant ce dossier :**
    ```bash
    # Assurez-vous d'être dans le dossier 'projet-code' ou utilisez un chemin absolu
    # Syntaxe recommandée avec --mount (plus explicite)
    docker run -d --name dev-web \
      -p 8084:80 \
      --mount type=bind,source="$(pwd)",target=/usr/share/nginx/html \
      nginx:alpine

    # Syntaxe historique avec -v (fonctionne aussi, mais moins claire)
    # docker run -d --name dev-web \
    #  -p 8084:80 \
    #  -v "$(pwd)":/usr/share/nginx/html \
    #  nginx:alpine
    ```
    *   `--mount type=bind,source="$(pwd)",target=/usr/share/nginx/html` : Monte le répertoire courant (`$(pwd)` qui donne le chemin absolu) de l'hôte sur le répertoire `/usr/share/nginx/html` dans le conteneur.
    *   `-v "$(pwd)":/usr/share/nginx/html` : Syntaxe équivalente avec `-v`.

3.  **Accédez au serveur web :** Ouvrez `http://localhost:8084` dans votre navigateur.
    *   *Résultat attendu :* Vous devriez voir "Version 1 du Code". Nginx sert le fichier `index.html` depuis votre répertoire hôte.

4.  **Modifiez le fichier sur votre hôte (SANS arrêter/redémarrer le conteneur) :**
    ```bash
    # Sur votre machine hôte, dans le dossier projet-code
    echo "<h2>Version 2 - Mise à jour en direct !</h2>" > index.html
    ```

5.  **Rafraîchissez la page dans votre navigateur (`http://localhost:8084`).**
    *   *Résultat attendu :* Vous devriez maintenant voir "Version 2 - Mise à jour en direct !". Le conteneur Nginx voit instantanément les modifications faites sur le fichier de l'hôte grâce au bind mount. C'est la magie pour le développement !

6.  **Nettoyez :**
    ```bash
    docker stop dev-web
    docker rm dev-web
    cd ..
    rm -rf projet-code # Supprimez le dossier de test sur l'hôte
    ```

#### **Exercice 8.3 : Volumes vs Bind Mounts avec Docker Compose**

Combinons cela avec Docker Compose, en utilisant un volume pour les données d'une base de données "factice" et un bind mount pour la configuration Nginx.

1.  **Créez un dossier `compose-data-app` et allez dedans.**
    ```bash
    mkdir compose-data-app
    cd compose-data-app
    ```

2.  **Créez un fichier `nginx.conf` simple (juste pour l'exemple) :**
    ```nginx
    # compose-data-app/nginx.conf
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
        location /data/ {
            # Alias pour accéder aux données du volume depuis nginx (si nécessaire)
            alias /app-data/;
            autoindex on; # juste pour voir les fichiers
        }
    }
    ```

3.  **Créez le fichier `docker-compose.yml` :**
    ```yaml
    # compose-data-app/docker-compose.yml
    version: '3.8'

    services:
      web:
        image: nginx:alpine
        container_name: data-nginx
        ports:
          - "8085:80"
        volumes:
          # Bind Mount pour la configuration Nginx
          - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
          # Bind Mount pour le contenu HTML initial (optionnel)
          - ./html:/usr/share/nginx/html:ro
          # Volume Nommé monté sur /app-data (pourrait être utilisé par une autre app)
          - appdata:/app-data

      # Un simple conteneur pour simuler une app écrivant dans le volume
      data-writer:
        image: alpine
        container_name: data-writer
        # La commande crée un fichier dans /data toutes les 10s
        command: sh -c 'while true; do echo "Fichier créé le $(date)" > /data/fichier_$(date +%s).txt; sleep 10; done'
        volumes:
          # Monte le même volume nommé sur /data
          - appdata:/data

    volumes:
      # Déclaration du volume nommé
      appdata:
        driver: local
    ```

4.  **Créez un dossier `html` avec un fichier `index.html` :**
    ```bash
    mkdir html
    echo "<h1>Test Volumes et Bind Mounts</h1>" > html/index.html
    ```

5.  **Démarrez l'application :**
    ```bash
    docker compose up -d
    ```
    *   *Résultat attendu :* Compose crée le volume `appdata`, lance le conteneur `data-writer` qui commence à écrire des fichiers dans le volume (monté sur `/data`), et lance Nginx (`web`) avec la configuration montée via bind mount et le volume monté sur `/app-data`.

6.  **Vérifications :**
    *   Ouvrez `http://localhost:8085` : Vous devriez voir "Test Volumes et Bind Mounts" (servi via le bind mount `./html`).
    *   Ouvrez `http://localhost:8085/data/` (le `/` final est important pour `autoindex`) : Vous devriez voir la liste des fichiers `fichier_...txt` créés par `data-writer` dans le volume `appdata` et rendus accessibles par Nginx grâce au montage du volume et à la configuration `nginx.conf`. La liste devrait s'allonger si vous attendez et rafraîchissez.

7.  **Inspectez le volume :**
    ```bash
    docker volume ls # Vous devriez voir compose-data-app_appdata
    docker volume inspect compose-data-app_appdata
    ```

8.  **Nettoyez :**
    ```bash
    # L'option -v est importante pour supprimer le volume nommé déclaré dans Compose
    docker compose down -v
    ```
    *   Vérifiez avec `docker volume ls` que le volume `compose-data-app_appdata` a bien été supprimé.

---

### **Synthèse du Chapitre 8**

La gestion des données est essentielle pour les applications conteneurisées. Vous savez maintenant :

*   Que les données dans la couche d'écriture d'un conteneur sont **éphémères**.
*   Que les **Volumes** sont le mécanisme **préféré** pour la **persistance des données** gérées par Docker (`docker volume create`, `-v mon-volume:/data`). Ils sont portables et plus faciles à gérer.
*   Que les **Bind Mounts** sont idéaux pour le **développement** (monter le code source) ou pour **injecter des configurations** depuis l'hôte (`-v /hote/chemin:/conteneur/chemin`). Ils dépendent de la structure de l'hôte.
*   Comment utiliser les deux mécanismes avec `docker run` et `docker compose`.
*   Que les **volumes nommés** sont supérieurs aux volumes anonymes.
*   Que les `tmpfs` mounts existent pour du stockage temporaire en RAM.

Avec la maîtrise des réseaux et des volumes, nous sommes prêts à assembler une application plus complète.

Excellent ! Nous allons maintenant mettre en pratique tout ce que nous avons appris en construisant et en exécutant une application web simple mais complète, composée de plusieurs services, en utilisant Docker Compose.

---

## **Chapitre 9 : Exemple Complet d'Application (Application de Vote)**

### **Objectifs de ce chapitre :**

*   Mettre en pratique les concepts des chapitres précédents (Dockerfile, Réseaux, Volumes, Compose).
*   Construire une application multi-conteneurs réaliste (mais simple).
*   Voir comment les différents services interagissent via le réseau Docker.
*   Utiliser un volume nommé pour la persistance des données de la base de données.

---

### **Partie 1 : Présentation de l'Application**

Nous allons créer une application de vote très simple composée de plusieurs services :

1.  **`vote` (Frontend - Python/Flask) :** Une application web où les utilisateurs peuvent voter pour "Chiens" ou "Chats". Elle enregistre le vote dans une file d'attente Redis.
2.  **`redis` (Cache/Queue - Image Officielle) :** Une base de données en mémoire Redis utilisée comme file d'attente simple pour stocker les votes entrants.
3.  **`worker` (Traitement - Python) :** Un service qui lit les votes depuis Redis, les traite (ici, juste les enregistre), et les stocke dans une base de données PostgreSQL.
4.  **`db` (Base de données - Image Officielle) :** Une base de données PostgreSQL pour stocker les résultats finaux des votes de manière persistante.
5.  **`result` (Backend/Résultats - Node.js/Express) :** Une application web qui interroge la base de données PostgreSQL et affiche les résultats actuels des votes.

`[Image : Diagramme de l'architecture : Navigateur -> (vote app <-> redis <- worker -> db <- result app) <- Navigateur ]`

---

### **Partie 2 : Mise en Place du Projet**

1.  **Créez un dossier principal** pour l'application :
    ```bash
    mkdir voting-app
    cd voting-app
    ```
2.  Nous allons créer des **sous-dossiers** pour le code de chaque service personnalisé (`vote`, `worker`, `result`).

---

### **Partie 3 : Implémentation des Services**

#### **3.1 Service `vote` (Flask Frontend)**

1.  **Créez le dossier et les fichiers :**
    ```bash
    mkdir vote
    cd vote
    touch app.py requirements.txt Dockerfile templates/index.html
    ```
2.  **`vote/requirements.txt` :**
    ```txt
    Flask==2.2.*
    redis==4.3.*
    ```
3.  **`vote/templates/index.html` (HTML très basique) :**
    ```html
    <!DOCTYPE html>
    <html>
    <head>
        <title>Vote Chiens vs Chats</title>
        <style>
            body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 80vh; background-color: #f0f0f0; }
            .container { text-align: center; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            button { font-size: 1.5em; padding: 15px 30px; margin: 10px; cursor: pointer; border: none; border-radius: 5px; color: white; }
            .cats { background-color: #ff9900; } /* Orange */
            .dogs { background-color: #3399ff; } /* Blue */
            #message { margin-top: 20px; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Votez !</h1>
            <form method="POST" action="/">
                <button name="vote" value="cats" class="cats">Chats</button>
                <button name="vote" value="dogs" class="dogs">Chiens</button>
            </form>
            <div id="message">{{ message }}</div>
        </div>
    </body>
    </html>
    ```
4.  **`vote/app.py` (Application Flask) :**
    ```python
    from flask import Flask, render_template, request, g
    import redis
    import os
    import logging

    app = Flask(__name__)
    logging.basicConfig(level=logging.INFO)

    def get_redis():
        if 'redis' not in g:
            # Utilise le nom de service 'redis' défini dans docker-compose !
            redis_host = os.environ.get('REDIS_HOST', 'redis')
            logging.info(f"Connexion à Redis sur l'hôte: {redis_host}")
            try:
                g.redis = redis.Redis(host=redis_host, port=6379, db=0, socket_timeout=5, decode_responses=True)
                g.redis.ping() # Vérifie la connexion
                logging.info("Connexion Redis réussie.")
            except redis.exceptions.ConnectionError as e:
                logging.error(f"Erreur de connexion Redis: {e}")
                g.redis = None # Indique l'échec de la connexion
        return g.redis

    @app.route('/', methods=['GET', 'POST'])
    def index():
        message = ""
        r = get_redis()
        if not r:
            message = "Erreur: Impossible de se connecter à la base de données Redis."
            return render_template('index.html', message=message), 500

        if request.method == 'POST':
            vote = request.form['vote']
            try:
                # Ajoute le vote à la fin de la liste 'votes' dans Redis
                r.rpush('votes', vote)
                message = f"Merci d'avoir voté pour les {vote} !"
                logging.info(f"Vote enregistré pour: {vote}")
            except redis.exceptions.ConnectionError as e:
                message = f"Erreur lors de l'enregistrement du vote: {e}"
                logging.error(f"Erreur Redis lors du vote: {e}")
                return render_template('index.html', message=message), 500

        return render_template('index.html', message=message)

    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5000, debug=True)

    ```
5.  **`vote/Dockerfile` :**
    ```dockerfile
    FROM python:3.9-slim

    WORKDIR /app

    COPY requirements.txt .
    # Installation des dépendances
    RUN pip install --no-cache-dir -r requirements.txt

    COPY . .

    # Variable d'environnement pour spécifier l'hôte Redis (sera 'redis' via Compose)
    ENV REDIS_HOST=redis

    # Port exposé par Flask
    EXPOSE 5000

    # Commande pour lancer l'app Flask
    CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
    ```
6.  **Retournez au dossier principal :** `cd ..`

#### **3.2 Service `worker` (Python)**

1.  **Créez le dossier et les fichiers :**
    ```bash
    mkdir worker
    cd worker
    touch worker.py requirements.txt Dockerfile
    ```
2.  **`worker/requirements.txt` :**
    ```txt
    redis==4.3.*
    psycopg2-binary==2.9.* # Pour se connecter à PostgreSQL
    ```
3.  **`worker/worker.py` (Script Worker) :**
    ```python
    import redis
    import psycopg2
    import os
    import time
    import logging

    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

    # Fonction pour obtenir la connexion Redis (avec tentatives)
    def get_redis_connection():
        redis_host = os.environ.get('REDIS_HOST', 'redis')
        logging.info(f"Worker tentant de se connecter à Redis sur {redis_host}...")
        while True:
            try:
                r = redis.Redis(host=redis_host, port=6379, db=0, socket_timeout=5, decode_responses=True)
                r.ping()
                logging.info("Worker connecté à Redis.")
                return r
            except redis.exceptions.ConnectionError:
                logging.warning("Connexion Redis échouée, nouvelle tentative dans 5s...")
                time.sleep(5)

    # Fonction pour obtenir la connexion PG (avec tentatives)
    def get_db_connection():
        db_host = os.environ.get('POSTGRES_HOST', 'db')
        db_user = os.environ.get('POSTGRES_USER', 'postgres')
        db_password = os.environ.get('POSTGRES_PASSWORD', 'postgres')
        db_name = os.environ.get('POSTGRES_DB', 'postgres')
        conn_string = f"host={db_host} dbname={db_name} user={db_user} password={db_password}"
        logging.info(f"Worker tentant de se connecter à Postgres sur {db_host}...")
        while True:
            try:
                conn = psycopg2.connect(conn_string)
                logging.info("Worker connecté à Postgres.")
                return conn
            except psycopg2.OperationalError:
                logging.warning("Connexion Postgres échouée, nouvelle tentative dans 5s...")
                time.sleep(5)

    # Fonction pour initialiser la table si elle n'existe pas
    def init_db(conn):
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS votes (
                    id VARCHAR(255) PRIMARY KEY,
                    votes INT NOT NULL
                )
            """)
        conn.commit()
        logging.info("Table 'votes' initialisée ou déjà existante.")

    # Fonction principale du worker
    def run_worker():
        redis_conn = get_redis_connection()
        db_conn = get_db_connection()
        init_db(db_conn)

        logging.info("Worker démarré, en attente de votes...")
        while True:
            try:
                # Attend un vote de la liste 'votes' (bloquant avec timeout)
                # BLPOP retire et retourne le premier élément de la liste, ou None si timeout
                # Le timeout de 0 signifie attendre indéfiniment
                # Utiliser un timeout (ex: 1) pour éviter de bloquer indéfiniment si redis redémarre
                vote_data = redis_conn.blpop('votes', timeout=1)

                if vote_data:
                    # vote_data est un tuple ('nom_liste', 'valeur')
                    vote = vote_data[1]
                    logging.info(f"Vote reçu: {vote}")

                    # Mise à jour de la base de données
                    with db_conn.cursor() as cur:
                        # Insère ou met à jour le compteur pour l'option votée
                        cur.execute(
                            "INSERT INTO votes (id, votes) VALUES (%s, 1) "
                            "ON CONFLICT (id) DO UPDATE SET votes = votes.votes + 1",
                            (vote,)
                        )
                    db_conn.commit()
                    logging.info(f"Vote pour '{vote}' enregistré dans la base de données.")
                else:
                    # Pas de vote reçu pendant le timeout, on continue la boucle
                    pass

            except redis.exceptions.ConnectionError:
                logging.error("Perte de connexion Redis, tentative de reconnexion...")
                redis_conn = get_redis_connection() # Tente de se reconnecter
            except psycopg2.Error as e:
                logging.error(f"Erreur Postgres: {e}. Tentative de reconnexion...")
                # Tenter de fermer l'ancienne connexion si elle existe
                if db_conn and not db_conn.closed:
                    db_conn.close()
                db_conn = get_db_connection() # Tente de se reconnecter
                # Il faudrait peut-être relancer la transaction échouée
            except Exception as e:
                logging.error(f"Erreur inattendue: {e}")
                time.sleep(5) # Pause avant de continuer


    if __name__ == '__main__':
        run_worker()

    ```
4.  **`worker/Dockerfile` :**
    ```dockerfile
    FROM python:3.9-slim

    WORKDIR /app

    # Dépendances système pour psycopg2 (si nécessaire, dépend de l'image de base)
    # RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt

    COPY worker.py .

    # Variables d'environnement (seront définies dans Compose)
    ENV REDIS_HOST=redis
    ENV POSTGRES_HOST=db
    ENV POSTGRES_USER=postgres
    ENV POSTGRES_PASSWORD=postgres
    ENV POSTGRES_DB=postgres

    # Commande pour lancer le script worker
    CMD ["python", "worker.py"]
    ```
5.  **Retournez au dossier principal :** `cd ..`

#### **3.3 Service `result` (Node.js Backend)**

1.  **Créez le dossier et les fichiers :**
    ```bash
    mkdir result
    cd result
    touch server.js package.json Dockerfile views/index.ejs
    ```
2.  **`result/package.json` :**
    ```json
    {
      "name": "result-app",
      "version": "1.0.0",
      "description": "Affiche les résultats du vote",
      "main": "server.js",
      "scripts": {
        "start": "node server.js"
      },
      "dependencies": {
        "ejs": "^3.1.8",
        "express": "^4.18.1",
        "pg": "^8.7.3"
      }
    }
    ```
3.  **`result/views/index.ejs` (Template EJS simple) :**
    ```html
    <!DOCTYPE html>
    <html>
    <head>
        <title>Résultats du Vote</title>
        <style>
            body { font-family: sans-serif; padding: 20px; background-color: #e8f4f8; }
            h1 { text-align: center; color: #0056b3; }
            .results { max-width: 500px; margin: 20px auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .result-item { margin-bottom: 15px; }
            .label { display: inline-block; width: 80px; font-weight: bold; color: #333; }
            .bar-container { display: inline-block; width: calc(100% - 100px); background-color: #ddd; border-radius: 4px; overflow: hidden; height: 25px; vertical-align: middle;}
            .bar { height: 100%; color: white; text-align: right; padding-right: 5px; box-sizing: border-box; line-height: 25px; border-radius: 4px; transition: width 0.5s ease-in-out; }
            .cats .bar { background-color: #ff9900; }
            .dogs .bar { background-color: #3399ff; }
            #error { color: red; text-align: center; margin-top: 20px; }
            #total { text-align: center; margin-top: 20px; font-size: 1.1em; }
        </style>
    </head>
    <body>
        <h1>Résultats</h1>
        <div class="results">
            <% if (error) { %>
                <p id="error"><%= error %></p>
            <% } else { %>
                <% let totalVotes = (results.cats || 0) + (results.dogs || 0); %>
                <% let catsPercent = totalVotes === 0 ? 0 : (results.cats || 0) / totalVotes * 100; %>
                <% let dogsPercent = totalVotes === 0 ? 0 : (results.dogs || 0) / totalVotes * 100; %>

                <div class="result-item cats">
                    <span class="label">Chats:</span>
                    <div class="bar-container">
                        <div class="bar" style="width: <%= catsPercent %>%;"><%= results.cats || 0 %></div>
                    </div>
                </div>
                <div class="result-item dogs">
                    <span class="label">Chiens:</span>
                    <div class="bar-container">
                        <div class="bar" style="width: <%= dogsPercent %>%;"><%= results.dogs || 0 %></div>
                    </div>
                </div>
                <div id="total">Total des votes: <%= totalVotes %></div>
            <% } %>
        </div>
         <script>
            // Rechargement automatique toutes les 2 secondes
            setTimeout(function(){
               window.location.reload(1);
            }, 2000);
        </script>
    </body>
    </html>
    ```
4.  **`result/server.js` (Serveur Express) :**
    ```javascript
    const express = require('express');
    const { Pool } = require('pg');
    const path = require('path');

    const app = express();
    const port = process.env.PORT || 5001;

    // Configuration de la connexion à PostgreSQL (via variables d'env)
    const pool = new Pool({
      host: process.env.POSTGRES_HOST || 'db',
      user: process.env.POSTGRES_USER || 'postgres',
      password: process.env.POSTGRES_PASSWORD || 'postgres',
      database: process.env.POSTGRES_DB || 'postgres',
      // Tentatives de reconnexion (simpliste)
      connectionTimeoutMillis: 5000,
    });

    pool.on('error', (err, client) => {
      console.error('Erreur inattendue sur le client idle de la base de données', err);
      // Tenter une reconnexion ou une autre logique de récupération
    });

    app.set('view engine', 'ejs');
    app.set('views', path.join(__dirname, 'views'));

    app.get('/', async (req, res) => {
      let results = { cats: 0, dogs: 0 };
      let error = null;
      let client;

      try {
        console.log("Tentative de connexion au pool PG...");
        client = await pool.connect();
        console.log("Connecté au pool PG.");
        const dbResult = await client.query('SELECT id, votes FROM votes');
        console.log("Résultats de la requête:", dbResult.rows);
        dbResult.rows.forEach(row => {
          results[row.id] = parseInt(row.votes, 10);
        });
      } catch (err) {
        console.error('Erreur lors de la récupération des votes:', err);
        error = `Erreur de connexion à la base de données : ${err.message}`;
        // Ne pas rendre la page si la DB est inaccessible, ou afficher un message clair
      } finally {
        if (client) {
          client.release(); // Libère le client dans le pool
          console.log("Client PG libéré.");
        }
      }
      res.render('index', { results, error });
    });

    app.listen(port, () => {
      console.log(`Serveur de résultats démarré sur le port ${port}`);
    });
    ```
5.  **`result/Dockerfile` :**
    ```dockerfile
    FROM node:18-alpine

    WORKDIR /app

    # Copier package.json et package-lock.json (si existant)
    COPY package*.json ./

    # Installer les dépendances
    RUN npm install

    # Copier le reste du code de l'application
    COPY . .

    # Port exposé par l'application Node.js
    EXPOSE 5001

    # Variables d'environnement (seront définies dans Compose)
    ENV POSTGRES_HOST=db
    ENV POSTGRES_USER=postgres
    ENV POSTGRES_PASSWORD=postgres
    ENV POSTGRES_DB=postgres

    # Commande pour démarrer l'application
    CMD ["npm", "start"]
    ```
6.  **Retournez au dossier principal :** `cd ..`

---

### **Partie 4 : Le Fichier Docker Compose**

Maintenant, assemblons tout cela dans `docker-compose.yml` à la racine de `voting-app`.

1.  **Créez le fichier `docker-compose.yml` :**
    ```yaml
    # voting-app/docker-compose.yml
    version: '3.8'

    services:
      # Service de vote (Frontend)
      vote:
        build: ./vote # Construit à partir du Dockerfile dans ./vote
        container_name: voting-app-vote
        ports:
          - "5000:5000" # Expose le port 5000 de Flask sur l'hôte
        networks:
          - voting-net
        environment:
          - FLASK_DEBUG=1 # Active le mode debug de Flask (pour le dev)
          - REDIS_HOST=redis # Dit à Flask où trouver Redis
        # depends_on: # Pas strictement nécessaire ici, Flask/Redis gèrent la reconnexion
        #   - redis

      # Service Redis (Cache/Queue)
      redis:
        image: redis:6.2-alpine # Utilise une image Redis officielle
        container_name: voting-app-redis
        networks:
          - voting-net
        # On pourrait ajouter un volume pour la persistance Redis si nécessaire
        # volumes:
        #   - redis-data:/data

      # Service Worker (Traitement)
      worker:
        build: ./worker # Construit à partir du Dockerfile dans ./worker
        container_name: voting-app-worker
        networks:
          - voting-net
        environment:
          # Le worker a besoin de savoir où trouver Redis et Postgres
          - REDIS_HOST=redis
          - POSTGRES_HOST=db
          - POSTGRES_USER=postgres
          - POSTGRES_PASSWORD=postgres_password # Mot de passe sécurisé !
          - POSTGRES_DB=voting_db
        depends_on: # S'assurer que Redis et DB démarrent avant le worker
          - redis
          - db

      # Service Base de Données (PostgreSQL)
      db:
        image: postgres:14-alpine # Utilise une image Postgres officielle
        container_name: voting-app-db
        environment:
          # Variables pour initialiser la DB Postgres au premier démarrage
          POSTGRES_DB: voting_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres_password # Doit correspondre à celui utilisé par worker/result
        volumes:
          # Volume nommé pour persister les données de la base de données
          - db-data:/var/lib/postgresql/data
        networks:
          - voting-net

      # Service de Résultats (Backend)
      result:
        build: ./result # Construit à partir du Dockerfile dans ./result
        container_name: voting-app-result
        ports:
          - "5001:5001" # Expose le port 5001 de Node.js sur l'hôte
        networks:
          - voting-net
        environment:
          # Le service de résultat a besoin de savoir où trouver Postgres
          - POSTGRES_HOST=db
          - POSTGRES_USER=postgres
          - POSTGRES_PASSWORD=postgres_password # Doit correspondre
          - POSTGRES_DB=voting_db
        depends_on: # S'assurer que la DB démarre avant le service de résultat
          - db

    # Définition des réseaux
    networks:
      voting-net:
        driver: bridge # Réseau bridge personnalisé pour l'application

    # Définition des volumes nommés
    volumes:
      db-data: # Volume pour les données Postgres
      # redis-data: # Si on voulait persister Redis
    ```
    **Note sur la sécurité :** Ne jamais mettre de mots de passe en clair dans `docker-compose.yml` en production. Utilisez des secrets Docker ou des variables d'environnement injectées de manière sécurisée. Pour cet exercice, c'est acceptable.

---

### **Partie 5 : Exécution et Test**

1.  **Assurez-vous d'être à la racine du projet `voting-app`.**
2.  **Construisez et démarrez tous les services :**
    ```bash
    docker compose up -d --build
    ```
    *   `--build` : Force la reconstruction des images `vote`, `worker`, et `result`.
    *   Cela prendra un certain temps la première fois (téléchargement des images de base, installation des dépendances, etc.).

3.  **Vérifiez que tous les conteneurs tournent :**
    ```bash
    docker compose ps
    ```
    *   Vous devriez voir les 5 services (`vote`, `redis`, `worker`, `db`, `result`) avec l'état `running` ou `up`.

4.  **Testez l'application :**
    *   **Votez :** Ouvrez votre navigateur et allez sur `http://localhost:5000`. Cliquez plusieurs fois sur "Chats" ou "Chiens". Vous devriez voir le message de confirmation.
    *   **Regardez les logs (optionnel) :**
        ```bash
        docker compose logs -f vote # Voir les votes envoyés à Redis
        docker compose logs -f worker # Voir le worker récupérer les votes et les insérer en DB
        docker compose logs -f result # Voir les requêtes à la DB pour les résultats
        ```
    *   **Voyez les résultats :** Ouvrez une autre page ou onglet sur `http://localhost:5001`. Vous devriez voir le graphique des résultats se mettre à jour (la page se recharge toutes les 2 secondes). Il peut y avoir un léger délai entre le vote et l'apparition dans les résultats, le temps que le `worker` traite le vote.

5.  **Explorez :**
    *   Essayez d'arrêter le worker (`docker compose stop worker`), votez, puis redémarrez-le (`docker compose start worker`). Les votes devraient être traités une fois le worker redémarré (grâce à Redis).
    *   Arrêtez tout (`docker compose down`), puis redémarrez (`docker compose up -d`). Les résultats des votes devraient être conservés grâce au volume `db-data`.

---

### **Partie 6 : Nettoyage**

1.  **Arrêtez et supprimez les conteneurs, réseaux ET le volume de la base de données :**
    ```bash
    docker compose down -v
    ```
    *   L'option `-v` est essentielle ici pour supprimer le volume `db-data` et repartir de zéro la prochaine fois.

---

### **Synthèse du Chapitre 9**

Félicitations ! Vous avez construit et exécuté une application web multi-services complète en utilisant Docker et Docker Compose. Cet exercice a permis de consolider :

*   La création de **Dockerfiles** pour différents langages (Python, Node.js).
*   La définition de multiples **services** dans `docker-compose.yml`.
*   L'utilisation d'images **officielles** (`redis`, `postgres`) et d'images **construites localement** (`build:`).
*   La configuration de la **communication inter-services** via un **réseau personnalisé** et les noms de service (DNS).
*   L'utilisation de **variables d'environnement** pour la configuration.
*   La **persistance des données** critiques (base de données) à l'aide d'un **volume nommé**.
*   La gestion du cycle de vie de l'application avec `docker compose up`, `ps`, `logs`, `down -v`.

Cet exemple, bien que simple, illustre les principes fondamentaux que vous utiliserez pour conteneuriser des applications beaucoup plus complexes.

Parfait ! Maintenant que vous maîtrisez les mécanismes de Docker, il est temps de parler des bonnes pratiques pour créer des images efficaces, sécurisées et faciles à maintenir, et pour utiliser Docker de manière optimale.

---

## **Chapitre 10 : Bonnes Pratiques Docker**

### **Objectifs de ce chapitre :**

*   Identifier les pratiques clés pour écrire de bons Dockerfiles.
*   Comprendre comment optimiser la taille des images.
*   Appréhender les aspects de sécurité liés à Docker.
*   Savoir comment structurer efficacement les builds.
*   Utiliser les tags d'image de manière judicieuse.
*   Comprendre l'importance du nettoyage régulier.

---

### **10.1 Optimiser les Dockerfiles et la Taille des Images**

Des images légères se téléchargent plus vite, se déploient plus rapidement et ont une surface d'attaque réduite.

*   **Choisir une Image de Base Appropriée :**
    *   Préférez les images `alpine` (basées sur Alpine Linux, très légères) ou `slim` (variantes Debian/Ubuntu allégées) lorsque c'est possible. Elles contiennent moins d'outils et de librairies inutiles.
    *   **Exemple :** `python:3.9-alpine` est beaucoup plus petit que `python:3.9`.
    *   **Attention :** Alpine utilise `musl libc` au lieu de `glibc`, ce qui peut causer des incompatibilités avec certains binaires pré-compilés. Testez bien !

*   **Utiliser les Builds Multi-Étapes (Multi-Stage Builds) :**
    *   C'est l'une des techniques **les plus efficaces**. Séparez l'environnement de construction (avec SDK, compilateurs, outils de build) de l'environnement d'exécution final (avec seulement le runtime et l'application).
    *   Copiez uniquement les artefacts nécessaires (ex: le binaire compilé, le `.jar`, les fichiers statiques) de l'étape de build vers l'étape finale.
    *   **Référence :** Voir l'exemple conceptuel au Chapitre 3.

*   **Minimiser le Nombre de Couches :**
    *   Chaque instruction `RUN`, `COPY`, `ADD` crée une nouvelle couche. Regroupez les commandes `RUN` logiquement liées en une seule instruction en utilisant `&&`.
    *   Nettoyez les artefacts temporaires (caches de gestionnaires de paquets, fichiers téléchargés) **dans la même instruction `RUN`** où ils ont été créés. Sinon, ils restent dans la couche précédente même si supprimés dans une couche ultérieure.
    *   **Mauvais :**
        ```dockerfile
        RUN apt-get update
        RUN apt-get install -y curl
        RUN curl -o data.zip https://example.com/data.zip
        RUN unzip data.zip
        RUN rm data.zip
        RUN apt-get remove -y curl
        RUN apt-get clean
        RUN rm -rf /var/lib/apt/lists/*
        ```
        *(Trop de couches, artefacts temporaires non nettoyés dans la bonne couche)*
    *   **Bon :**
        ```dockerfile
        RUN apt-get update && \
            apt-get install -y --no-install-recommends curl unzip && \
            curl -o data.zip https://example.com/data.zip && \
            unzip data.zip && \
            rm data.zip && \
            apt-get purge -y --auto-remove curl unzip && \
            apt-get clean && \
            rm -rf /var/lib/apt/lists/*
        ```
        *(Une seule couche, nettoyage inclus. `--no-install-recommends` évite les paquets suggérés inutiles.)*

*   **Optimiser l'Ordre des Instructions pour le Cache :**
    *   Placez les instructions qui changent le moins souvent **en haut** du Dockerfile (ex: `FROM`, installation de dépendances système `RUN apt-get install...`).
    *   Placez les instructions qui changent fréquemment (comme `COPY . .` pour votre code source) **le plus bas possible**.
    *   **Exemple pour une app Node.js :** Copiez `package.json` et `package-lock.json` d'abord, lancez `npm install` (cette couche sera mise en cache tant que les dépendances ne changent pas), PUIS copiez le reste du code source (`COPY . .`).
        ```dockerfile
        FROM node:18-alpine
        WORKDIR /app
        # Copier d'abord les fichiers de dépendances
        COPY package*.json ./
        # Installer les dépendances (couche mise en cache)
        RUN npm install --production
        # Copier le reste du code (change souvent)
        COPY . .
        CMD ["node", "server.js"]
        ```

*   **Utiliser `.dockerignore` :**
    *   Excluez les fichiers et dossiers inutiles du contexte de build (envoyé au démon Docker) pour accélérer le build et éviter d'inclure accidentellement des secrets ou des fichiers volumineux.
    *   Exemples : `.git`, `node_modules`, `*.log`, `*.tmp`, `build/`, `dist/`, environnements virtuels (`.venv`, `venv`), fichiers IDE (`.idea`, `.vscode`).

### **10.2 Sécurité des Images et des Conteneurs**

*   **Ne pas Exécuter en tant que `root` :**
    *   Par défaut, les conteneurs s'exécutent souvent en tant qu'utilisateur `root`. C'est une mauvaise pratique de sécurité. Si le processus dans le conteneur est compromis, l'attaquant aura les privilèges `root` à l'intérieur du conteneur (même si limité par les capacités Docker).
    *   **Solution :** Utilisez l'instruction `USER` dans votre Dockerfile pour spécifier un utilisateur non-privilégié. Créez cet utilisateur et groupe au préalable si nécessaire (avec `RUN groupadd ... && useradd ...`).
    *   **Exemple :**
        ```dockerfile
        FROM ubuntu:latest
        # ... autres instructions (ex: apt-get install) ...
        RUN groupadd -r appuser && useradd -r -g appuser appuser
        # ... copier les fichiers de l'app, définir les permissions si besoin ...
        # chown -R appuser:appuser /app
        USER appuser
        WORKDIR /app
        CMD ["mon-app"]
        ```

*   **Utiliser des Images Officielles Vérifiées :**
    *   Privilégiez les images officielles sur Docker Hub (marquées "Docker Official Image"). Elles sont généralement mieux maintenues, scannées pour les vulnérabilités et suivent les bonnes pratiques.

*   **Scanner les Vulnérabilités :**
    *   Utilisez des outils pour scanner vos images Docker à la recherche de vulnérabilités connues dans les paquets système ou les dépendances d'application.
    *   Outils : `docker scan` (intégration Snyk dans Docker Desktop/CLI), Trivy, Clair, Grype, etc. Intégrez ces scans dans vos pipelines CI/CD.

*   **Minimiser la Surface d'Attaque :**
    *   N'installez que les paquets strictement nécessaires dans l'image finale (cf. multi-stage builds, images `alpine`/`slim`). Moins il y a de logiciels, moins il y a de vulnérabilités potentielles.
    *   N'exposez que les ports nécessaires (`EXPOSE` et `-p`).

*   **Gestion des Secrets :**
    *   **Ne jamais** intégrer de secrets (mots de passe, clés API, certificats) directement dans l'image Docker (ni dans le Dockerfile, ni dans les fichiers copiés). Les images peuvent être inspectées.
    *   **Solutions :**
        *   Variables d'environnement injectées au moment du `docker run` ou via Docker Compose (depuis des fichiers `.env` ou l'environnement de l'hôte). **Attention :** Facile, mais les variables d'environnement peuvent être inspectées (`docker inspect`).
        *   Systèmes de gestion de secrets dédiés (HashiCorp Vault, secrets cloud AWS/GCP/Azure, secrets Kubernetes).
        *   **Docker Secrets** (pour Docker Swarm et Compose) : Mécanisme sécurisé pour injecter des secrets sous forme de fichiers dans `/run/secrets/<nom_secret>` dans le conteneur.
        *   Montage de fichiers de secrets via des volumes (avec les bonnes permissions).

*   **Ne pas Faire Confiance aux Images sans Vérification :**
    *   Si vous utilisez des images non officielles, examinez leur Dockerfile (si disponible) ou leur historique pour comprendre ce qu'elles contiennent.

### **10.3 Gestion des Tags et Versioning**

*   **Éviter `:latest` en Production :**
    *   Le tag `latest` est muable et ne garantit pas une version spécifique. L'utiliser peut entraîner des déploiements imprévisibles si l'image sous-jacente change.
*   **Utiliser des Tags Sémantiques ou Spécifiques :**
    *   Utilisez des tags qui indiquent clairement la version (ex: `mon-app:1.2.3`, `mon-app:2.0`).
    *   Vous pouvez aussi utiliser des tags basés sur le hash Git (`mon-app:git-a1b2c3d`) pour une traçabilité parfaite.
*   **Utiliser des Tags Multiples :**
    *   Taguez la même image avec plusieurs tags si nécessaire (ex: `mon-app:1.2.3`, `mon-app:1.2`, `mon-app:1`). Cela permet aux utilisateurs de choisir leur niveau de spécificité. `docker tag` est votre ami ici.

### **10.4 Organisation et Maintenance**

*   **Nettoyer Régulièrement :**
    *   Utilisez `docker system prune` (avec précaution !) pour supprimer les conteneurs arrêtés, les réseaux non utilisés, les images dangling et le cache de build.
    *   Utilisez `docker container prune`, `docker image prune [-a]`, `docker volume prune`, `docker network prune` pour un nettoyage plus ciblé.
    *   Le manque d'espace disque est un problème courant avec Docker si on ne nettoie pas.
*   **Versionner les Dockerfiles :**
    *   Stockez vos Dockerfiles dans votre système de contrôle de version (Git) avec le code de votre application. Cela assure la reproductibilité et la traçabilité des builds.
*   **Documenter les Dockerfiles :**
    *   Utilisez des commentaires (`#`) pour expliquer les choix complexes, les commandes non évidentes ou les raisons d'installer certains paquets.

### **10.5 Bonnes Pratiques Docker Compose**

*   **Utiliser des Fichiers `.env` :**
    *   Pour gérer les configurations spécifiques à l'environnement (URLs de base de données, clés API en développement, etc.) sans les coder en dur dans `docker-compose.yml`. Compose charge automatiquement les variables d'un fichier `.env` dans le même répertoire.
    *   **Exemple `.env` :**
        ```env
        POSTGRES_PASSWORD=mon_mot_de_passe_dev
        TAG_IMAGE=development
        ```
    *   **Exemple `docker-compose.yml` :**
        ```yaml
        services:
          db:
            image: postgres:14
            environment:
              # Utilise la variable du fichier .env
              POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
          web:
            # Utilise la variable du fichier .env
            image: mon-app:${TAG_IMAGE:-latest} # :-latest = valeur par défaut si non définie
        ```
*   **Définir des `healthchecks` :**
    *   Pour s'assurer qu'un service est non seulement démarré mais aussi prêt à recevoir du trafic avant que les services dépendants ne s'y connectent (plus fiable que `depends_on` seul).
    *   Compose permet de définir une commande qui vérifie la santé du service.
    *   **Exemple (pour Postgres) :**
        ```yaml
        db:
          image: postgres:14
          # ... environment ...
          healthcheck:
            test: ["CMD-SHELL", "pg_isready -U postgres -d voting_db"]
            interval: 10s
            timeout: 5s
            retries: 5
        worker:
          # ... build, environment ...
          depends_on:
            db:
              condition: service_healthy # Attend que le healthcheck de 'db' réussisse
        ```
*   **Séparer les Fichiers Compose (Optionnel Avancé) :**
    *   Pour des configurations complexes, vous pouvez séparer la configuration de base, la configuration de développement (avec bind mounts, debuggers) et la configuration de production (optimisée, sans volumes de code) en utilisant plusieurs fichiers Compose et l'option `-f`. (`docker compose -f docker-compose.yml -f docker-compose.dev.yml up`)

---

### **Synthèse du Chapitre 10**

Adopter ces bonnes pratiques vous aidera à :

*   Créer des images **plus petites, plus rapides et plus sécurisées**.
*   Rendre vos builds **reproductibles et efficaces** grâce à l'optimisation du cache.
*   **Réduire les risques de sécurité** en évitant `root`, en scannant les vulnérabilités et en gérant correctement les secrets.
*   Maintenir un environnement Docker **propre et organisé**.
*   Utiliser Docker Compose de manière plus **robuste et flexible**.

Ces pratiques ne sont pas juste théoriques, elles ont un impact direct sur la performance, la sécurité et la maintenabilité de vos applications conteneurisées.

Nous arrivons à la fin de ce cours intensif. Prêt(e) pour la conclusion et les prochaines étapes ?

Parfait, terminons ce parcours avec une conclusion qui récapitule ce que nous avons accompli et ouvre la voie à la suite.

---

## **Chapitre 11 : Conclusion**

### **Objectifs de ce chapitre :**

*   Récapituler les compétences clés acquises durant ce cours.
*   Renforcer la compréhension des avantages fondamentaux de Docker.
*   Suggérer des pistes pour approfondir vos connaissances et aller plus loin.

---

Félicitations ! Vous êtes arrivé(e) au terme de ce cours intensif sur les fondamentaux de Docker. Si vous avez suivi les explications et réalisé les exercices, vous disposez maintenant d'une base solide pour travailler efficacement avec les conteneurs.

#### **Récapitulatif des Compétences Acquises**

Au cours de ces chapitres, nous avons couvert un large éventail de sujets essentiels :

1.  **Installation :** Vous savez installer Docker Desktop ou Docker Engine sur votre système d'exploitation et vérifier son bon fonctionnement.
2.  **Cycle de Vie des Conteneurs :** Vous maîtrisez les commandes pour créer (`run`), lister (`ps`), arrêter (`stop`), démarrer (`start`), inspecter (`inspect`, `logs`), interagir (`exec`) et supprimer (`rm`, `prune`) des conteneurs.
3.  **Création d'Images :** Vous comprenez la différence entre image et conteneur et savez créer vos propres images personnalisées, principalement via l'écriture de `Dockerfile` clairs et efficaces, en utilisant les instructions clés (`FROM`, `RUN`, `COPY`, `WORKDIR`, `CMD`, `ENTRYPOINT`, `EXPOSE`, `ENV`) et en comprenant le contexte de build et le cache. Vous avez également vu les concepts de multi-stage builds.
4.  **Gestion des Images :** Vous savez taguer (`tag`), télécharger (`pull`), partager (`push`) et supprimer (`rmi`, `prune`) des images, en interagissant avec des registres comme Docker Hub.
5.  **Logging :** Vous comprenez comment Docker gère les logs (stdout/stderr), comment les consulter (`docker logs`) et le rôle des logging drivers pour la centralisation.
6.  **Réseau :** Vous comprenez les bases des réseaux Docker (`bridge`, `host`), l'importance des réseaux définis par l'utilisateur pour la résolution DNS par nom de service, et comment publier des ports (`-p`).
7.  **Docker Compose :** Vous savez définir et gérer des applications multi-conteneurs de manière déclarative avec `docker-compose.yml`, simplifiant grandement le développement et les déploiements simples.
8.  **Gestion des Données :** Vous distinguez les **Volumes** (préférés pour la persistance) des **Bind Mounts** (utiles en développement) et savez les utiliser pour gérer les données de vos applications.
9.  **Exemple Complet :** Vous avez mis en pratique toutes ces notions en construisant une application de vote multi-services.
10. **Bonnes Pratiques :** Vous avez pris connaissance des recommandations pour créer des images optimisées, sécurisées et maintenables, et pour utiliser Docker de manière professionnelle.

#### **Pourquoi Docker ? Les Avantages Renforcés**

Ce parcours a, je l'espère, illustré concrètement les bénéfices majeurs de Docker :

*   **Cohérence des Environnements :** Fini le fameux "ça marche sur ma machine !". Docker garantit que votre application s'exécute de la même manière en développement, en test et en production.
*   **Portabilité :** Une image Docker construite sur une machine fonctionnera sur n'importe quelle autre machine disposant de Docker.
*   **Isolation :** Les conteneurs isolent les applications les unes des autres et du système hôte, améliorant la sécurité et évitant les conflits de dépendances.
*   **Efficacité des Ressources :** Les conteneurs sont bien plus légers que les machines virtuelles, permettant de densifier l'utilisation des serveurs.
*   **Déploiement Rapide et Scalabilité :** Les conteneurs démarrent quasi instantanément, facilitant les mises à jour rapides (rolling updates) et la mise à l'échelle horizontale (lancer plus d'instances).
*   **Productivité des Développeurs :** Simplification de la mise en place de l'environnement de développement, intégration facilitée dans les pipelines CI/CD.

#### **Prochaines Étapes : Où Aller Maintenant ?**

Docker est un écosystème vaste et en constante évolution. Maintenant que vous maîtrisez les bases, voici quelques pistes pour continuer votre apprentissage :

1.  **Orchestration à Grande Échelle :**
    *   **Kubernetes (k8s) :** L'orchestrateur de conteneurs leader du marché. Apprenez à déployer, gérer et mettre à l'échelle des applications conteneurisées sur des clusters de machines. C'est la suite logique pour les environnements de production complexes.
    *   **Docker Swarm :** L'outil d'orchestration intégré à Docker, plus simple que Kubernetes mais puissant pour de nombreux cas d'usage. Approfondissez son fonctionnement (services, scaling, rolling updates, secrets, configs).

2.  **Intégration Continue et Déploiement Continu (CI/CD) :**
    *   Apprenez à intégrer Docker dans vos pipelines CI/CD (avec Jenkins, GitLab CI, GitHub Actions, etc.) pour automatiser la construction, les tests et le déploiement de vos images Docker.

3.  **Réseau Avancé :**
    *   Explorez plus en détail les drivers `overlay` (pour le multi-hôtes), `macvlan`, et les concepts de service discovery avancés.

4.  **Stockage Avancé :**
    *   Découvrez les différents drivers de volumes (pour le stockage cloud NFS, Ceph, etc.) et les stratégies de sauvegarde et de restauration des volumes Docker.

5.  **Sécurité Approfondie :**
    *   Plongez dans les outils de scan de vulnérabilités (Trivy, Clair, etc.), la gestion avancée des secrets, les politiques de sécurité réseau (Network Policies), la sécurité du runtime (Falco, AppArmor, Seccomp).

6.  **Monitoring et Logging Centralisés :**
    *   Mettez en place des solutions de monitoring (Prometheus, Grafana) et de logging centralisé (Fluentd/Elasticsearch/Kibana - EFK, ou Fluentd/Loki/Grafana - PLG) pour observer vos applications conteneurisées en production.

7.  **Docker dans le Cloud :**
    *   Explorez l'intégration de Docker avec les services cloud spécifiques : Amazon ECS/EKS/ECR, Google GKE/Cloud Run/Artifact Registry, Azure AKS/ACR/Container Instances.

8.  **Optimisation Fine :**
    *   Apprenez à définir des limites de ressources (CPU, mémoire) pour vos conteneurs, à peaufiner les healthchecks, et à optimiser les performances de vos applications dans Docker.

#### **Le Mot de la Fin**

L'apprentissage de Docker ouvre de nombreuses portes dans le monde du développement logiciel et de l'administration système moderne. La clé est maintenant de **pratiquer** : conteneurisez vos propres projets, expérimentez avec différentes images et configurations, explorez les outils de l'écosystème.

N'hésitez pas à consulter la [documentation officielle de Docker](https://docs.docker.com/), qui est une ressource extrêmement riche et à jour.

J'espère que ce cours vous a été utile et vous a donné les outils et la confiance nécessaires pour utiliser Docker efficacement. Bonne continuation dans votre exploration du monde fascinant des conteneurs !