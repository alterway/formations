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

- Mettre à jour un objet Kubernetes en écrasant la configuration existante:

```console
kubectl replace -f object.yaml
```

### Kubernetes : Labels

- Système de clé/valeur

- Organiser les différents objets de Kubernetes (Pods, ReplicationControllers, Services, etc.) d'une manière cohérente qui reflète la structure de l'application

- Corréler des éléments de Kubernetes : par exemple un service vers des Pods

- une ressource Kubernetes peut avoir plusieurs labels.

### Kubernetes : Labels

- Exemple de label :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
    env: prod
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

### Kubernetes: Labels

- La commande `kubectl get pods`, par défaut, ne liste pas les labels. Il est possible de les voir en utilisant `--show-labels`:

```console
$ kubectl get pods --show-labels
NAME      READY     STATUS    RESTARTS   AGE       LABELS
nginx        1/1              Running     0                    31s          app=nginx,env=prod
```

### Kubernetes : Update, Rollbacks

*TBD*
