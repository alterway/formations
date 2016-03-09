Supports de formation Osones  ![Build Status](https://travis-ci.com/Osones/formations.svg?token=sy6nX4pitZ2Pksd9gZmW&branch=master)
===============================

Supports de formation (sous forme de slides) écrits en Français et réalisés par Osones (https://osones.com/) pour ses offres de formation OpenStack et Docker.

Sont notamment abordés les sujets suivants : le cloud, sa philosophie, le projet OpenStack, l'utilisation d'OpenStack, le déploiement d'OpenStack, le principe des conteneurs, le projet Docker, l'utilisation de Docker, l'orchestration de conteneurs Docker.

Auteurs :
* Adrien Cunin <adrien.cunin@osones.com>
* Pierre Freund <pierre.freund@osones.com>
* Romain Guichard <romain.guichard@osones.com>
* Kevin Lefevre <kevin.lefevre@osones.com>


Intégration Continue
--------------------

Travis est en charge de builder régulièrement les supports de formation. Ceux ci sont écrits en markdown et sont buildés pour obtenir un support HTML et un support PDF

[Support PDF](http://formation.osones.com)  
[Support HTML Docker](http://docker.formation.osones.com)  
[Support HTML OpenStack](http://openstack.formation.osones.com)  

Installation de LaTeX (Ubuntu)
------------------------------

sudo apt-get install texlive-lang-french texlive

Générations des PDFs
--------------------

Cours :

        make

Un style (screen, handout ou print) pour les cours OpenStack :

        make course=openstack


Copyright et licence
--------------------
Tous les contenus originaux (Makefile, les fichiers dans cours/) sont :
* Copyright © 2014-2016 Osones
* Distribués sous licence Creative Commons BY-SA 4.0.

![Creative Commons BY-SA](http://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-sa.png)

https://creativecommons.org/licenses/by-sa/4.0/

Les autres fichiers du répertoire images/ sont soumis à leur copyright et licence respectifs.
