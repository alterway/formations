# Méthode déclarative et impérative pour créer des objets Kubernetes

### La méthode déclarative

- Consiste à définir un objet dans un fichier yaml puis à créer l'objet avec la commande kubectl apply ou kubectl create
- Recommandé pour garder un historique de tous les objets créés, puis de faire du versionning
- Il facilite également le travail entre équipe.


### La méthode impérative

- Permet la création rapide des ressources à l'aide d'une commande
- Gain un temps considérable lors de l'examen
- Recommandé dans des environnements de lab ou pour tester une commande 


### La méthode impérative

- Creation d'un pod NGINX: 
  
```console
kubectl run nginx --image=nginx
```

- Générez le fichier YAML du manifeste d'un pod (-o yaml), sans le créer (--dry-run): 

```console
kubectl run nginx --image=nginx --dry-run=client -o yaml
```

- Générer un déploiement avec 4 répliques: 

```console
kubectl create deployment nginx --image=nginx --replicas=4
```

### La méthode impérative

- Mise à l'échelle d'un déploiement à l'aide de la commande `kubectl scale`: 
  
```console
kubectl scale deployment nginx --replicas=4
```

- Il est possible aussi d'enregistrer la définition YAML dans un fichier et de le modifier: 

```console
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml
```

- Ensuite mettre à jour le fichier YAML avec les répliques ou tout autre champ avant de créer le déploiement.


### La méthode impérative

- Créez un service nommé redis-service de type ClusterIP pour exposer le pod redis sur le port 6379: 
  
```console
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
```

- Créez un service nommé nginx de type NodePort pour exposer le port 80 du pod nginx sur le port 30080 des nœuds: 
  
```console
kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml
```

- Ceci utilisera automatiquement les labels du pod comme sélecteurs, sans possibilité de spécifier le port du nœud. Avec le fichier généré, ajoutez le port de nœud manuellement avant de créer le service avec le pod. 
- Ou:
  
```console
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml
```

Ceci n'utilisera pas les labels des pods comme sélecteurs. 