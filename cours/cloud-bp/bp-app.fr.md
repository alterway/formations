# Architectures cloud-ready

## Concevoir une application destinée au Cloud

### Les motivations

-   S'appuyer sur les services du cloud et se concentrer sur le métier
-   Permettre l'élasticité
-   Rester agile jusqu'au déploiement
-   Mises en production : entrer dans le cercle vertueux
-   Optimiser la facture cloud

### 12-factor : la référence

“The Twelve-Factor App” <https://12factor.net/>

-   Publié par Heroku
-   Suivre (tout) le code dans un VCS
-   Configuration

### Penser son application “cloud ready” 1/3

Cf. les design tenets du projet OpenStack et Twelve-Factor <https://12factor.net/>

-   Architecture distribuée plutôt que monolithique
    -   Facilite le passage à l’échelle
    -   Limite les domaines de *failure*
-   Couplage faible entre les composants

### Penser son application “cloud ready” 2/3

-   Bus de messages pour les communications inter-composants
-   Stateless : permet de multiplier les routes d’accès à l’application
-   Dynamicité : l’application doit s’adapter à son environnement et se reconfigurer lorsque nécessaire
-   Permettre le déploiement et l’exploitation par des outils d’automatisation

### Penser son application “cloud ready” 3/3

-   Limiter autant que possible les dépendances à du matériel ou du logiciel spécifique qui pourrait ne pas fonctionner dans un cloud
-   Tolérance aux pannes (*fault tolerance*) intégrée
-   Ne pas stocker les données en local, mais plutôt :
    -   Base de données
    -   Stockage objet
-   Utiliser des outils standards de journalisation

### Modularité

-   Philosophie Unix (KISS)
-   Multiples composants de taille raisonnable
-   Couplage faible et interface documentée

### Passage à l’échelle

-   Vertical vs Horizontal
-   Scale up/down vs Scale out/in
-   Plusieurs petites instances plutôt qu’une grosse instance

### Stateful vs stateless

-   Beaucoup de stateful dans les applications legacy
-   Nécessite de partager l’information d’état lorsque plusieurs workers
-   Le stateless élimine cette contrainte

### Tolérance aux pannes

-   L’infrastructure n’est pas hautement disponible
-   L’API d’infrastructure est hautement disponible
-   L’application doit anticiper et réagir aux pannes

### Patterns de déploiement

-   Blue-Green
-   Rolling update

### Stockage des données

-   Base de données relationnelles
-   Base de données NoSQL
-   Stockage bloc
-   Stockage objet
-   Stockage éphémère
-   Cache, temporaire

### Production de logs

-   Enrichir les logs
-   Rester "applicatif"
-   Backend de traitement dans la conf

### Exemple en python

app.py:
```
#!/usr/bin/python
# -*- coding: utf-8 -*-

import logging

log = logging.getLogger('mycompany.myapp.maintask')
log.info('Main worker started')
```
appLog.conf:
```
[logger_myapp]
qualname=mycompany.myapp
level=INFO
handlers=console
propagate=0
```

### Logging flow

![](images/cloud-bp/logging_flow.png){height="250px"}

### Migration des applications legacy

-   Rappel des enjeux
-   Migrer ou non : critères de décision

### Design Tenets d’OpenStack (exemple) 1/2

1.  Scalability and elasticity are our main goals
2.  Any feature that limits our main goals must be optional
3.  Everything should be asynchronous. If you can’t do something asynchronously, see \#2
4.  All required components must be horizontally scalable

### Design Tenets d’OpenStack (exemple) 2/2

5.  Always use shared nothing architecture (SN) or sharding. If you can’t Share nothing/shard, see \#2
6.  Distribute everything. Especially logic. Move logic to where state naturally exists.
7.  Accept eventual consistency and use it where it is appropriate.
8.  Test everything. We require tests with submitted code. (We will help you if you need it)

<https://wiki.openstack.org/wiki/BasicDesignTenets>

