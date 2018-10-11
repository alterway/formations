### Kubernetes : Minikube

- Outil permettant de démarrer rapidement un cluster mono-node Kubernetes localement
- Execute Kubernetes dans une machine virtuelle
- Nécessite des outils de virtualisation (VirtualBox, VMware Fusion, KVM, etc...)
- Supporte plusieurs systèmes d'exploitation : Linux, Mac OS, Windows
- Installation : <https://github.com/kubernetes/minikube#Installation>

### Kubernetes : Minikube

- Création d'un cluster Kubernetes

```console
$minikube get-k8s-versions
The following Kubernetes versions are available when using the localkube bootstrapper: 
	- v1.10.0
	- v1.9.4
	- v1.9.0
	- v1.8.0
```

```console
$minikube start --kubernetes-version="v1.11.1"
Starting local Kubernetes v1.11.1 cluster...
Starting VM...
Getting VM IP address...
[...]
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.
```

### Kubernetes : Minikube

- Effectuer un diagnostic basique du cluster

```console
$ kubectl version
Client Version: v1.11.1
Server Version: v1.11.1
```
```console
$ kubectl get componentstatuses
NAME                      STATUS    MESSAGE              ERROR
controller-manager   Healthy      ok                   
scheduler                  Healthy      ok                   
etcd-0                       Healthy      {"health": "true"}
```

### Kubernetes : Kubectl

- le seul (ou presque) outil pour interagir avec des clusters Kubernetes
- utilise un fichier de configuration pour communiquer avec l'API de Kubernetes
- Configuration dans `~/.kube/config`
- le fichier de config contient :
    - l'adresse de l'APIServer
    - les chemins des certificats TLS utilisés pour l'authentification

- fichier `kubeconfig` peut être passé en paramètre de kubectl avec `--kubeconfig`

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

- afficher les noeuds du cluster :

```console
$ kubectl get node
NAME                  STATUS    ROLES     AGE       VERSION
prod-k8s-master-1     Ready     master    7d        v1.11.2
prod-k8s-master-2     Ready     master    7d        v1.11.2
prod-k8s-master-3     Ready     master    7d        v1.11.2
prod-k8s-node-1       Ready     node      7d        v1.11.2
prod-k8s-node-2       Ready     node      7d        v1.11.2
prod-k8s-node-3       Ready     node      7d        v1.11.2
prod-k8s-node-4       Ready     node      7d        v1.11.2
prod-k8s-node-5       Ready     node      7d        v1.11.2
prod-k8s-node-6       Ready     node      7d        v1.11.2
```

### Kubernetes : Kubectl

- afficher les _namespaces_

```console
kubectl get namespaces
```

- par défaut, kubectl utilise le _namespace_ `default`
- il est possible de sélectionner un _namespace_ avec l'option `-n` ou `--namespace`

```console
kubectl get -n kube-system get pods
```

### Kubernetes : Kubectl

- affficher les pods (pour le namespace _default_)

```console
$ kubectl get pods
NAME                                  READY     STATUS    RESTARTS   AGE
debug-59d7bc59f-t8nrh                 1/1       Running   0          5d
debug9-95b9d5c89-kjk27                1/1       Running   0          7d
helloworld-ingress-7dcfb78b88-8d7vh   1/1       Running   0          2d
```

### Kubernetes : Kubectl

- afficher les services (pour le namespace par défaut)

```console
kubectl get services
kubectl get svc
```

### Kubernetes : Kubernetes Dashboard

- Interface graphique web pour les clusters Kubernetes
- Permet de gérer les différents objets Kubernetes créés dans le cluster
- Installé par défaut dans minikube

### Kubernetes : Kubernetes Dashboard
![Kubernetes Dashboard](https://raw.githubusercontent.com/kubernetes/website/master/static/images/docs/ui-dashboard.png)

### Kubernetes : Kubernetes Dashboard
![Logs in Kubernetes Dashboard](https://raw.githubusercontent.com/kubernetes/website/master/static/images/docs/ui-dashboard-logs-view.png)


### Kubernetes : ConfigMaps

- Objet Kubernetes permettant stocker séparer les fichiers de configuration
- Il peut être créé d'un ensemble de valeurs ou d'un fichier resource Kubernetes (YAML ou JSON)
- Un `ConfigMap` peut sollicité par plusieurs `pods`


### Kubernetes : ConfigMaps

```yaml
apiVersion: v1
data:
    redis-config: |
      maxmemory 2mb
      maxmemory-policy allkeys-lru
kind: ConfigMap
metadata:
  name: redis-config
  namespace: default
```

### Kubernetes : Secrets

- Objet Kubernetes de type `secret` utilisé pour stocker des informations sensibles comme les mots de passe, les _tokens_, les clés SSH...
- Similaire à un `ConfigMap`, à la seule différence que le contenu des entrées présentes dans le champ `data` sont encodés en base64.
- Il est possible de directement créer un `Secret` spécifique à l'authentification sur un registre Docker privé.

### Kubernetes : Secrets

```console
kubectl create secret docker-registry mydockerhubsecret \
--docker-username="employeeusername" --docker-password="employeepassword" \
--docker-email="employee.email@organization.com"
```


### Kubernets : Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
	name: private-pod
	spec:
	imagePullSecrets:
	- name: mydockersecret
	containers:
	- image: privateregistry/privateimage:tag
	  name: main
```


### Kubernetes : Introduction to Helm

- Une application conçue pour faciliter l'installation et la gestion des applications sur Kubernetes.
- Il utilise un format de paquetage appelé `Charts`.
- Il est comparable à apt/yum/homebrew.
- Plusieurs charts existent déjà sur le répertoire officiel : `https://github.com/kubernetes/charts`.

### Kubernetes : Introduction to Helm

- `Tiller` : Serveur Helm. Il interagit avec l'APIServer de Kubernetes pour installer, mettre à jour et supprimer les ressources Kubernetes.
- `Chart` : Contient toutes les ressources définies et nécessaires pour éxecuter une application dans Kubernetes.
- `Release` : Une instance d'un chart helm s'éxécutant dans un cluster Kubernetes.
- `Repository` : répertoire ou espace (public ou privé) où sont regroupés les `charts`.

