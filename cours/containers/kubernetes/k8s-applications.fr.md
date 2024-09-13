# KUBERNETES : Stratégie de mise à jour des Applications

### Stratégie

Voici quelques stratégies de mise à jour des applications

- RollingUpdate simple Déploiement
- Canary Déploiement
- Blue-Green Déploiement


![](images//kubernetes/rollingupdate.png){height="350px"}


### RollingUpdate


Caractéristiques du RollingUpdate :

- Mise à jour progressive :

    - Les pods sont mis à jour un par un ou par petits lots, plutôt que tous en même temps.
    - Cela permet de minimiser les temps d'arrêt et de garantir que le service reste disponible pendant la mise à jour.

- Paramètres configurables :

    - **maxUnavailable** : Définit le nombre maximum de pods qui peuvent être indisponibles pendant la mise à jour. Par exemple, maxUnavailable: 1 signifie qu'au maximum un pod peut être hors ligne à tout moment pendant la mise à jour.
    - **maxSurge** : Définit le nombre maximum de pods supplémentaires qui peuvent être créés au-delà du nombre souhaité de pods pendant la mise à jour. Par exemple, maxSurge: 1 signifie qu'un pod supplémentaire peut être créé pendant la mise à jour.

-Maintien de la disponibilité :

    - Le déploiement RollingUpdate garantit que certaines instances de l'application restent disponibles pour traiter les requêtes pendant la mise à jour.
    - Cela réduit le risque de temps d'arrêt et améliore l'expérience utilisateur.

- Facilité de retour en arrière :
    - Si un problème est détecté avec la nouvelle version, Kubernetes permet de revenir facilement à la version précédente des pods.
    - Vous pouvez utiliser la commande kubectl rollout undo pour revenir à une version antérieure du déploiement.

- Surveillance et gestion des erreurs :
    - Kubernetes surveille l'état des pods pendant la mise à jour. Si un pod ne parvient pas à démarrer ou à devenir sain, Kubernetes arrêtera la mise à jour et conservera les pods en cours d'exécution.
    - Vous pouvez surveiller la progression de la mise à jour avec la commande kubectl rollout status.

- Compatibilité avec les applications sans état :
    - La stratégie RollingUpdate est particulièrement bien adaptée aux applications sans état où les instances de pod sont interchangeables.
    - Pour les applications avec état, des stratégies supplémentaires peuvent être nécessaires pour gérer les états et les données.



### Blue Green


Caractéristiques du Blue-Green Deployment :

- Deux Environnements Distincts :
    - Environnement Blue : L'environnement de production actuel qui reçoit tout le trafic des utilisateurs.
    - Environnement Green : L'environnement où la nouvelle version de l'application est déployée et testée avant de recevoir du trafic.

- Isolation Complète :
    - Les environnements Blue et Green sont complètement isolés l'un de l'autre. Cela permet de tester la nouvelle version (Green) sans affecter l'environnement de production actuel (Blue).

- Redirection du Trafic :
    - Une fois que l'environnement Green est prêt et testé, le trafic est redirigé de l'environnement Blue vers l'environnement Green.
    - Cette redirection peut être effectuée au niveau du service, du load balancer ou du DNS.

- Facilité de Retour en Arrière :
    - Si un problème survient après la bascule vers l'environnement Green, il est facile de revenir à l'environnement Blue en redirigeant simplement le trafic vers l'ancien environnement.

- Minimisation des Temps d'Arrêt :
    - Le déploiement Blue-Green minimise les temps d'arrêt car la bascule du trafic entre les environnements est généralement rapide et transparente pour les utilisateurs.

- Test en Conditions Réelles :
    - L'environnement Green peut être testé dans des conditions réelles avant de recevoir le trafic de production. Cette approche permet de détecter et de corriger les problèmes potentiels avant la mise en production.

- Gestion des Données :
    - Les bases de données et les états partagés doivent être gérés avec soin pour s'assurer que les deux environnements peuvent accéder aux mêmes données sans conflit.
    - Des migrations de base de données peuvent être nécessaires, et il est essentiel de s'assurer que les deux versions de l'application sont compatibles avec le schéma de données.

- Ressources Supplémentaires :
    - Le déploiement Blue-Green nécessite des ressources supplémentaires car les deux environnements doivent fonctionner en parallèle pendant la phase de test et de transition.


### Canary Deployment

Si vous avez un ingress controller nginx faire du canary release est très simple.

Caractéristiques du Canary Deployment :


- Déploiement Graduel :
    - La nouvelle version de l'application est d'abord déployée à un petit pourcentage de l'ensemble des utilisateurs.
    - Le pourcentage de trafic dirigé vers la nouvelle version est progressivement augmenté.

- Test en Conditions Réelles :
    -La nouvelle version est testée en conditions réelles avec un sous-ensemble d'utilisateurs, ce qui permet de détecter les problèmes et de les corriger avant un déploiement complet.

- Réduction du Risque :
    - En cas de problème, il est facile de rediriger le trafic vers l'ancienne version, ce qui réduit le risque d'interruption de service pour l'ensemble des utilisateurs.

- Monitoring et Feedback :
    - Une surveillance étroite est nécessaire pour évaluer les performances et la stabilité de la nouvelle version.
    - Les métriques et les logs sont utilisés pour décider si le déploiement peut continuer ou s'il doit être annulé.

- Automatisation :
    - Les outils de déploiement continu (CD) peuvent automatiser le processus de déploiement Canary, y compris la redirection du trafic et la surveillance.

### Canary Deployment Exemple

Voir le lab dédié

