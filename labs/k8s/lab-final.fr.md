# Lab final


<hr>

## A vous de jouer !

<hr>

1. Créer un namespace nommé **kubeops**


2. Créer un pod avec les caractéristiques suivantes :

|                                     |                             |
|-------------------------------------|-----------------------------|
| Nom                                 | : webserver                 |
| Nom du conteneur                    | : webserver                 |
| Image                               | : dernière version de nginx |
| Namespace                           | : kubeops                   |


    - Sur quel nœud se trouve votre pod ?

    - Connectez-vous au conteneur du pod et vérifiez son OS avec la commande cat /etc/os-release

    - Vérifiez les logs du pod


3. Ajoutez un nouveau conteneur du nom de webwatcher au pod créé précédemment, avec une image : afakharany/watcher:latest.

    - Vérifiez que les deux conteneurs sont « running » dans le pod.

    - Connectez-vous au conteneur webwatcher et affichez le contenu du fichier /etc/hosts
 

4. Lancez un Deployment nommé « nginx-deployment » avec 2 réplicas comprenant un conteneur nommé "nginxcont" dans le namespace "kubeops" avec l'image Nginx version 1.17.10 et définissez le port 80 comme port d'exposition.



5. Augmentez le nombre de réplicas du déploiement à 4 avec la commande kubectl scale



6. Mettez à jour l’image de votre application à une nouvelle version nginx :1.9.1 avec la commande kubectl set image et observez l’évolution de la mise à jour de l’application



7. Faites un Rollback de votre mise à jour du déploiement



8. Exposez votre application avec un service de type Nodeport sur le port 30000 des workers



9. Créez un Daemonset nommé prometheus-daemonset conteneur nommé prometheus dans le namespace "kubeops" avec l'image prom/node-exporter et définissez le port 9100 comme port d'exposition.



10. Le Daemonset précédemment créé est présent sur tous les nœuds du cluster. Nous ne souhaitons plus qu’il tourne sur le nœud node2. Trouvez la bonne stratégie pour que prometheus-daemonset ne soit présent que sur le node1 et le master



11. Cet exercice vise à montrer l’utilisation d’un secret et d’un configmap.

    - Création du secret :
        - Générez un certificat en exécutant le script certs.sh. Créez un secret de type tls avec les fichiers générés avec la commande `kubectl create secret tls nginx-certs --cert=tls.crt --key=tls.key`


    - Faites un kubectl describe pour vérifier le secret créé


    - Création du configmap
        - Les ConfigMaps peuvent être créés de la même manière que les secrets. Il peut être créer à l’aide d’un fichier YAML, ou via la commande kubectl create configmap pour le créer à partir de la ligne de commande.

    - Afin de personnaliser la configuration de votre serveur nginx, créez un configmap avec le fichier de configuration nginx-custom.conf avec la commande suivante : `kubectl create configmap nginx-config --from-file nginx-custom.conf`
 
 
    - Création d’un déploiement
        - Créez un déploiement du nom de nginx d’un réplica avec une image nginx :1.9.1. Créez un volume avec le secret et un deuxième volume avec le configmap dans les spec de votre application. Définir les ports 80 et 443 comme ports d’exposition, puis montez les volumes dans le conteneur avec comme mountPath « /certs » pour le certificat et « /etc/nginx/conf.d » pour la configuration nginx

 

    - Testez votre application en l’exposant via un service

12. Nous souhaitons déployer une base de données mysql sur le cluster. Créez un déploiement « mysql-database » avec 1 réplica comprenant un conteneur nommé « database » avec la dernière version de Mysql.



    - Votre application doit afficher une erreur car il lui manque le mot de passe root de mysql.

    - Redéployez l’application en passant le mot de passe root de mysql en variable d’environnement avec les valeurs comme suit : MYSQL_ROOT_PASSWORD=test.



13. Utilisateurs et droits dans Kubernetes

    - Générez un certificat pour un utilisateur du nom de dev. Ajoutez les informations d'identification de l'utilisateur dev à notre fichier kubeconfig. Puis vérifiez si dev a le droit de lister les pods en mettant la commande : `kubectl --user=dev get pods`

    - Créez un Role qui autorise à lister les pods puis liez le Role à l’utilisateur dev. Vérifiez à présent si dev peut lister les pods.

    - Vous remarquerez que dev est limité au namespace dans lequel le Role a été créé. Vous décidez de lui permettre de lister les pods de tous les namespaces. Mettez en place une solution appropriée.


14. Créez un pod static avec une image redis. Rajoutez un request de 100Mi RAM et 100m CPU puis une limite à 200Mi RAM et 150m CPU



15. Installez le helm chart de wordress disponible sur ce lien. Modifier le type de service par défaut définit dans le fichier values.yaml en NodePort.

