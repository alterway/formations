Supports de formation Osones  [![Build Status](https://travis-ci.org/Osones/formations.svg?branch=master)](https://travis-ci.org/Osones/formations)
============================

Supports de formation (sous forme de slides) écrits en Français et réalisés par Osones (https://osones.com/) pour ses offres de formation.

Sont notamment abordés les sujets suivants : le cloud, sa philosophie, le projet OpenStack, l'utilisation d'OpenStack, le déploiement d'OpenStack, le principe des conteneurs, le projet Docker, l'utilisation de Docker, l'orchestration de conteneurs Docker.

Auteurs :
* Adrien Cunin <adrien.cunin@osones.com>
* Pierre Freund <pierre.freund@osones.com>
* Romain Guichard <romain.guichard@osones.com>
* Kevin Lefevre <kevin.lefevre@osones.com>
* Jean-François Taltavull <jft@osones.com>

Build gérés par la CI :
* [Supports PDF](http://formations.osones.com/pdf)
* [Support HTML OpenStack](http://formations.osones.com/openstack.html)
* [Support HTML Docker](http://formations.osones.com/docker.html)

Fonctionnement
--------------

Les supports de formation (slides) sont écrits en Markdown. Chaque fichier dans `cours/` est un module indépendant.

`cours.list` définit les cours à partir des modules.

Il est possible de générer ces slides sous différents formats :
1. HTML / reveal.js
2. PDF à partir du HTML / reveal.js
3. PDF à partir de LaTeX / Beamer

Deux méthodes de build sont disponibles :
* build.sh : supporte 1. et 2.
* Makefile : supporte 1. et 3.

Build.sh
---------

Le build se fait dans des containers Docker.
L'utilisation de containers Docker ne vise qu'à fournir un environnement stable (version des paquets fixes)
et de ne pas "encrasser" le système hôte avec des paquets dont l'utilisation est faible.

Les Dockerfiles des images Docker sont disponibles ici :

- [revealjs-builder](https://github.com/Osones/docker-images/tree/master/revealjs-builder)
- [wkhtmltopdf](https://github.com/Osones/docker-images/tree/master/wkhtmltopdf)

Un daemon Docker est donc le seul prérequis pour le build via `build.sh`

```
bash build.sh
```

Pour visualiser :

- Lire les fichiers dans `cours/output-html/*.html` avec votre navigateur
- Les PDF se trouvent dans `output-pdf/`

OU

```
docker run -d \
            -p 80:8001 \
            -v $PWD/images:/revealjs/images \
            -v $PWD/cours/output-html/$(cours).html:/revealjs/index.html \
            -v $PWD/cours/output-html/revealjs/css/theme:/revealjs/css/theme \
            vsense/revealjs
```

- Les slides sont ensuite accessibles sur http://localhost

Build Makefile
--------------

Le build se fait entièrement en local.
* Voir le header du Makefile pour les dépendances nécessaires.
* Voir `make help` pour l'utilisation.

Quelques exemples :

    make openstack.pdf
    make docker-handout.pdf
    make docker-print.pdf
    make openstack.html


Copyright et licence
--------------------
Tous les contenus originaux (Makefile, scripts, fichiers dans `cours/`) sont :
* Copyright © 2014-2016 Osones
* Distribués sous licence Creative Commons BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/)

![Creative Commons BY-SA](http://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-sa.png)

Les autres fichiers du répertoire `images/` sont soumis à leur copyright et licence respectifs.
