# Concevoir une application pour le Cloud

### La référence : les 12 facteurs

“The Twelve-Factor App” <https://12factor.net/fr/>

-   Publié par Heroku <https://www.heroku.com/what/>
-   Ecrit par des développeurs, des architectes et des ops
-   Recueil de préconisations techniques issues d'expériences terrain
-   Destiné aux développeurs et aux personnes en charge du déploiement et du Run
-   Applicable quel que soit le langage de programmation

### Les 12 facteurs en détails (1/2)

1. Base de code : unique, suivie dans un VCS, plusieurs déploiements
2. Dépendances : les isoler et les déclarer explicitement
3. Configuration : différencier les environnements via les variables de conf.
4. Services externes : les traiter comme des ressources attachées
5. Build, release, run : séparer strictement les étapes d’assemblage et d’exécution
6. Processus : exécuter l’application comme un ou plusieurs processus sans état

### Les 12 facteurs en détails (2/2)

7. Ports : exporter les services de l'application via des ports TCP
8. Mise à l'échelle : utiliser le modèle de processus
9. Jetable : maximisez la robustesse avec des démarrages rapides et des arrêts  en douceur
10. Parité dev/prod : gardez les différents environnements aussi proches que possible
11. Logs : les traiter comme des flux d’évènements
12. Processus d’administration et de maintenance : les lancer comme des processus _one-off_

### Penser son application “cloud ready” 1/3

-   Une base de code unique suivie dans un VCS (Git,...)
-   Une configuration par environnement
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
    -   Stockage bloc
    -   Stockage objet
-   Utiliser des outils de journalisation standards

### Modularité

-   Philosophie Unix (Keep It Simple Stupid)
-   Multiples composants de taille raisonnable
-   Couplage faible et interface documentée

### Passage à l’échelle

-   Pets versus Cattle
-   Vertical vs Horizontal
-   Scale up/down vs Scale out/in
-   Plusieurs petites instances plutôt qu’une seule grosse

### Stateful vs stateless

-   Beaucoup de stateful dans les applications legacy
-   Nécessite de partager l’information d’état lorsque plusieurs workers
-   Le stateless élimine cette contrainte

### Tolérance aux pannes

-   Les APIs du cloud sont hautement disponibles
-   Le cloud ne garantit pas la haute disponibilté de l'application
-   L’application prend en charge sa propre tolérance aux pannes

### Modèles de déploiement

-   Blue-Green *(attention aux quotas)*
-   Rolling
-   Canary

![](images/cloud-bp/deployment-strategies.png){height="150px"}

### Stockage des données

-   Base de données relationnelle
-   Base de données NoSQL
-   Stockage bloc
-   Stockage objet
-   Stockage éphémère

### Gestion des logs

-   Rester "applicatif"
-   Enrichir les logs
-   Ne pas présupposer le backend de traitement ->  dans la conf

### Exemple en python

appLog.conf:
```
[logger_myapp]
qualname=mycompany.myapp
level=INFO
handlers=console
propagate=0
```

app.py:
```
#!/usr/bin/python
# -*- coding: utf-8 -*-
import logging
log = logging.getLogger('mycompany.myapp.maintask')
log.info('Main worker started')
```
```
2018-12-24 22:20:02 INFO appuser Main worker started
```

### Logging flow

![](images/cloud-bp/logging_flow.png){height="250px"}

### Migration des applications legacy

-   Rappel des enjeux
-   Migrer ou non : critères de décision

