# Examen Blanc pour le passage de la certification CKA


## Objectifs
La certification CKA assure l’expertise dans l’administration et l’installation de Kubernetes d’une personne.

L’examen (3h) est présenté sous la forme de 24 questions à réaliser lors de TP sur plusieurs cluster Kubernetes soit à domicile soit en centre de formation officiel.

## Un exemple d'examen

1. Installer et configurer 2 VMS pour créer un cluster Kubernetes avec un master et un worker en utilisant Kubeadm.

2. Créer un namespace nommé awcc.

3. Lancer un pod nommé "revisionpod" comprenant un conteneur nommé "revisionconteneur" dans le namespace awcc avec la dernière image Ubuntu disponible.

4. Lancer un Deployment nommé "awccnginx" avec 3 replicas comprenant un conteneur nommé "nginxcont" dans le namespace "awcc" avec l'image Nginx version 1.17.10  et  définir le port 80 comme port d'exposition.

5. Exposer votre Deployment "awccnginx" avec un service kubernetes de type NodePort sur un port aléatoire dans le namespace "awcc"

6. Mettre à jour le Deployment "awccnginx" vers la dernière version Nginx "latest" puis vérifier le statut du rollout.

7. Vérifier l'état des services du control plane avec la commande Kubectl adéquate.

8. Modifier votre Deployment "awccnginx" pour faire fonctionner le conteneur "nginxcont"  avec l'utilisateur root (id : 0)

9. Ajouter un label "awcc" avec la valeur "machinetest" au noeud worker puis vérifier que le label est bien configuré en affichant les labels configurés sur le worker. 
    
10.Créer un volume persistant de type "hostPath" nommé "awccpv" d'une capacité de 10Gi. Le host path doit être configuré sur "/data/awcc" et le mode d'écriture doit être de type ReadWriteOnce

11. Faire un backup de ETCD sous la forme d'un snapshot et vérifier les infos du snapshot et sa taille.

12. Lancer un Deployment nommé "awccdouble" avec 2 replicas comprenant deux conteneurs nommés "awccun" avec la dernière version de Nginx et "awccdeux" avec la dernière version de Redis dans le namespace "awcc".

13. Lancer un pod nommé "awcclog" contenant un conteneur nommé "redis" avec la dernière version de Redis dans le NS "awcc" puis afficher les logs du pods.

14. Relever l'adresse ip du pod "awcclog" de la question 13.

15. Modifier le pod "awcclog" et ajouter un Init Container avec la dernière image Busybox qui execute la commande shell suivante : *echo "bonjour awcc".*

16. Créer un pod static nommé "nginx-static" avec la dernière version de Nginx

17. Créer un daemonset nommé "fluentd-elasticsearch". Son conteneur aura pour nom: fluentd-elasticsearch et pour image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2

18. Récupérez l’utilisation des ressources CPU et Memory des noeuds dans un fichier du nom de "node-usage.txt"

19. Quel est le pod utilisant le plus de ressource Memory dans le namespace awcc? Récupérez cette donnée dans un fichier du nom de "super-pod.txt".

20. Ajouter un label "game" avec la valeur "win " au noeud master. Créer un pod "redis-game" avec une image redis en vous assurant qu’il soit schedulé sur le master.

21. Nous souhaitons déployer une base de données mysql sur le cluster dans le namespace awcc. Créez premièrement un secret nommé « mysql-secret ». Il définira la valeur du mot de passe root de mysql comme suit : MYSQL_ROOT_PASSWORD=test. Créez ensuite un déploiement «mysql-database» avec 1 replica comprenant un conteneur nommé « database » avec la dernière version de Mysql, et recevant comme variable d’environnement le secret « mysql-secret ».

22. Lancer un pod nommé "revisionconfigmap" comprenant un conteneur nommé "revisionconfigmap" dans le namespace awcc avec la dernière image Ubuntu disponible. Ajouter un fichier de configuration sous la forme d'un configmap dans /etc/toto nommé ma.conf avec le contenu suivant : "hello = true"


<hr>
