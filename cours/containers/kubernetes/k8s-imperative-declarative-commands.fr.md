# Méthode déclarative et impérative pour créer des objets Kubernetes

### déclaratif vs impératif

![](images/kubernetes/imperative-declarative-k8s.jpg){height="400x"}


### La méthode déclarative

L'approche déclarative consiste à décrire l'état désiré des ressources. Vous déclarez ce que vous voulez obtenir, et Kubernetes s'occupe de mettre en place et de maintenir cet état.

- Consiste à définir un objet dans un fichier yaml puis à créer l'objet avec la commande kubectl apply ou kubectl create
- Recommandé pour garder un historique de tous les objets créés, puis de faire du versionning
- Il facilite également le travail entre équipe.

- Avantages :
    - Simplicité: Plus facile à comprendre et à maintenir que les commandes impératives.
    - Reproductibilité: Les fichiers de configuration peuvent être versionnés et utilisés pour recréer un environnement à tout moment.
    - Idéal pour l'automatisation: Parfaitement adapté aux outils d'intégration continue et de déploiement continu (CI/CD).
    - Détection des dérives: Kubernetes compare l'état actuel du cluster à l'état désiré défini dans les fichiers de configuration et effectue les modifications nécessaires pour rétablir la conformité.
- Inconvénients:
    - Moins de flexibilité pour certaines opérations: Certaines opérations peuvent nécessiter des commandes impératives pour être effectuées.



### La méthode impérative

L'approche impérative consiste à donner des instructions directes à Kubernetes pour effectuer des actions spécifiques. On décrit comment réaliser une tâche, pas seulement le résultat final.

- Permet la création rapide des ressources à l'aide d'une commande
- Gain un temps considérable lors de l'examen
- Recommandé dans des environnements de lab ou pour tester une commande 

- Avantages :
    - Flexibilité: Grande liberté dans la façon de gérer les ressources.
    - Contrôle précis: Possibilité d'effectuer des actions très spécifiques.
- Inconvénients :
    - Erreur humaine: Le risque d'erreur est plus élevé car chaque action doit être spécifiée manuellement.
    - Difficulté de suivi: Il peut être difficile de retracer les modifications apportées à un état donné du cluster.
    - Moins adapté aux environnements complexes: La gestion manuelle de nombreuses ressources peut devenir rapidement fastidieuse et source d'erreurs.




### La méthode impérative

- Creation d'un pod NGINX: 
  
```bash
kubectl run nginx --image=nginx
```

- Générez le fichier YAML du manifeste d'un pod (-o yaml), sans le créer (--dry-run): 

```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml
```

- Générer un déploiement avec 4 réplicas: 

```bash
kubectl create deployment nginx --image=nginx --replicas=4
```

### La méthode impérative

- Mise à l'échelle d'un déploiement à l'aide de la commande `kubectl scale`: 
  
```bash
kubectl scale deployment nginx --replicas=4
```

- Il est possible aussi d'enregistrer la définition YAML dans un fichier et de le modifier: 

```bash
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml
```

- Ensuite mettre à jour le fichier YAML avec les réplicas ou tout autre champ avant de créer le déploiement.


### La méthode impérative

- Créer un service nommé redis-service de type ClusterIP pour exposer le pod redis sur le port 6379: 
  
```bash
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
```

- Créer un service nommé nginx de type NodePort pour exposer le port 80 du pod nginx sur le port 30080 des nœuds: 
  
```bash
kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml
```

- Cela utilisera automatiquement les labels du pod comme sélecteurs, sans possibilité de spécifier le port du nœud. Avec le fichier généré, ajoutez le port de nœud manuellement avant de créer le service avec le pod. 
- Ou:
  
```bash
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml
```

Ceci n'utilisera pas les labels des pods comme sélecteurs. 


### Quand utiliser quelle méthode ?

- Méthode impérative:
    - Pour des tâches ponctuelles ou des dépannages.
    - Lorsque vous avez besoin d'un contrôle très précis sur les ressources.
- Méthode déclarative:
    - Pour la gestion quotidienne des ressources.
    - Pour automatiser les déploiements et les mises à jour.
    -  Pour construire des pipelines CI/CD.
  


     
  


