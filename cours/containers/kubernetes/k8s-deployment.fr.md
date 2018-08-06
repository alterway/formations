### Kubernetes : Création d'objets Kubernetes

- Les objets Kubernetes sont créés sous la forme de fichiers JSON ou YAML et envoyés à l'APIServer
- possible d'utiliser la commande `kubectl run`, mais limitée aux `Deployments` et aux `Jobs`
- L'utilisation de fichiers YAML permet de les stocker dans un système de contrôle de version comme git, mercurial, etc...
- La documentation de référence pour l'API Kubernetes <https://kubernetes.io/docs/reference/#api-reference>

### Kubernetes : Création d'objets Kubernetes

- Pour créer un object Kubernetes depuis votre fichier YAML, utilisez la commande `kubectl create` :

```console
kubectl create -f object.yaml
```

- il est possible de créer des objets Kubernetes à partir d'une URL :

```console
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/guestbook/frontend-deployment.yaml
```

- Pour les supprimer exécuter simplement : 

```console
kubectl delete -f object.yaml
```