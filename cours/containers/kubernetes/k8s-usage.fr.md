
### Kubernetes : Kubectl

- Le seul (ou presque) outil pour interagir avec des clusters Kubernetes
- Utilise un fichier de configuration pour communiquer avec l'API de Kubernetes
- Le(s) fichier(s) se trouve(nt) par défaut dans `~/.kube/config`
- Le fichier de config. contient :
    - L'adresse(URI) de l'APIServer
    - Les chemins des certificats TLS utilisés pour l'authentification

- Fichier `kubeconfig` peut être passé en paramètre de kubectl avec le _flag_ `--kubeconfig`


### Kubeconfig

Un seul fichier pour gérer tous ses clusters avec trois informations :

- Serveurs (IP, CA Cert, Nom)
- Users (Nom, Certificat, Clé)
- Context, association d'un user et d'un serveur

Stocké par défaut dans ~/.kube/config

### Kubernetes : Kubectl

- Afficher la liste des ressources API supportées par le serveur:

```console
$ kubectl api-resources
NAME                             SHORTNAMES   APIGROUP                       NAMESPACED   KIND
bindings                                                         true         Binding
componentstatuses         cs                            false        ComponentStatus
configmaps                     cm                          true         ConfigMap
endpoints                        ep                           true         Endpoints
events                             ev                           true         Event
limitranges                     limits                      true         LimitRange
namespaces                    ns                           false        Namespace
nodes                              no                          false        Node
persistentvolumeclaims  pvc                        true         PersistentVolumeClaim
persistentvolumes           pv                          false        PersistentVolume
pods                                po                           true         Pod
```

### Kubernetes : Kubectl

- Afficher les noeuds du cluster :

```console
kubectl get nodes
```

- Ces commandes sont équivalentes:

```console
kubectl get no
kubectl get nodes
```

### Kubernetes : Kubectl

- Afficher les _namespaces_

```console
kubectl get ns
kubectl get namespaces
```

- Par défaut, kubectl utilise le _namespace_ `default`
- Il est possible de sélectionner un _namespace_ avec l'option `-n` ou `--namespace`

```console
kubectl -n kube-system get pods
```

### Kubernetes : Kubectl

- Afficher les pods (pour le namespace _default_)

```console
kubectl get pods
kubectl get pod
```

### Kubernetes : Kubectl

- Afficher les services (pour le _namespace_ `default`):

```console
kubectl get services
kubectl get svc
```

### Kubernetes : Création d'objets Kubernetes

- Les objets Kubernetes sont créés sous la forme de fichiers JSON ou YAML et envoyés à l'APIServer
- Possible d'utiliser la commande `kubectl run`, mais limitée aux `Deployments` et aux `Jobs`
- L'utilisation de fichiers YAML permet de les stocker dans un système de contrôle de version comme git, mercurial, etc...
- La documentation de référence pour l'API Kubernetes <https://kubernetes.io/docs/reference/#api-reference>

### Kubernetes : Création d'objets Kubernetes

- Pour créer un object Kubernetes depuis votre fichier YAML, utilisez la commande `kubectl create` :

```console
kubectl create -f object.yaml
```

- Il est possible de créer des objets Kubernetes à partir d'une URL :

```console
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/guestbook/frontend-deployment.yaml
```

### Kubernetes : Création d'objets Kubernetes

- Pour les supprimer exécuter simplement :

```console
kubectl delete -f object.yaml
```

- Mettre à jour un objet Kubernetes en écrasant la configuration existante:

```console
kubectl replace -f object.yaml
```

### Kubernetes : Kubernetes Dashboard

- Interface graphique web pour les clusters Kubernetes
- Permet de gérer les différents objets Kubernetes créés dans le(s) cluster(s).
- Installé par défaut dans minikube


### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/ui-dashboard.png)


### Kubernetes : Kubernetes Dashboard

- Pour déployer le Dashboard, éxecuter la commande suivante:

```console
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

- Pour accéder au Dashboard, il faut établir une communication entre votre poste et le cluster Kubernetes :

```console
$ kubectl proxy
```

- Now access Dashboard at:

<http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/>


### Kubernetes : Introduction to Helm

- Une application conçue pour faciliter l'installation et la gestion des applications sur Kubernetes.
- Il utilise un format de paquetage appelé `Charts`.
- Il est comparable à apt/yum/homebrew.
- Plusieurs charts existent déjà sur le répertoire officiel : `https://github.com/kubernetes/charts`.


### Kubernetes : Introduction to Helm

- `Tiller` : Serveur Helm. Il interagit avec l'APIServer de Kubernetes pour installer, mettre à jour et supprimer les ressources Kubernetes.
- `Chart` : Contient toutes les ressources définies et nécessaires pour éxecuter une application ou un service à  l'intérieur de cluster Kubernetes. Un chart est pratiquement un regroupement de ressources Kubernetes pré-configurées.
- `Release` : Une instance d'un chart helm s'éxécutant dans un cluster Kubernetes.
- `Repository` : répertoire ou espace (public ou privé) où sont regroupés les `charts`.


### Kubernetes : Introduction to Helm

- Installer Helm (sur une distribution Linux):
- Deployer tiller : `helm init`
- Voir la liste des `charts` disponibles sur les répertoire officiel : `helm search`
- Afficher la liste des `charts` disponibles pour _prometheus_ : `helm search prometheus`
- Afficher les options disponibles dans un `chart` Helm:  `helm inspect stable/prometheus`

