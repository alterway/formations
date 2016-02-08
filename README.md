Supports de formation OpenStack  ![Build Status](https://travis-ci.com/Osones/formation-openstack.svg?token=7ppXKZyxcmMnfH2RMRnd&branch=master)
===============================

Supports de formation (sous forme de slides) sur OpenStack écrits en Français et réalisés par Osones (https://osones.com/).
Sont notamment abordés les sujets suivants : le cloud, le projet OpenStack, l'utilisation d'OpenStack, le déploiement d'OpenStack, et les manières de tirer partie d'une infrastructure IaaS.

Auteurs :
* Adrien Cunin <adrien.cunin@osones.com>
* Pierre Freund <pierre.freund@osones.com>

Installation de LaTeX (Ubuntu)
------------------------------

       sudo apt-get install texlive-lang-french texlive

Générations des PDFs
--------------------

Tous :

       make

Un style (screen, handout ou print) :

       make style.pdf

Copyright et licence
--------------------
Tous les contenus originaux (Makefile, les fichiers dans latex/) sont :
* Copyright © 2014 Osones
* Distribués sous licence Creative Commons BY-SA 4.0.

![Creative Commons BY-SA](http://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-sa.png)

https://creativecommons.org/licenses/by-sa/4.0/

Les autres fichiers du répertoire images/ sont soumis à leur copyright et licence respectifs.
