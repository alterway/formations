### Kubernetes : Minikube

- Outil permettant de démarrer rapidement un cluster _1 noeud_ Kubernetes localement pour développer des applications.
- Execute Kubernetes dans une machine virtuelle
- Nécessite des outils de virtualisation (VirtualBox, VMware Fusion, KVM, etc...)
- Offre plusieurs version de Kubernetes à éxecuter
- Supporte plusieurs systèmes d'exploitation : Linux, Mac OS, Windows
- Installation : <https://github.com/kubernetes/minikube#Installation>

### Kubernetes : Minikube

- Création d'un cluster Kubernetes

```console
$ minikube get-k8s-versions
The following Kubernetes versions are available when using the localkube bootstrapper:
	- v1.10.0
	- v1.9.4
	- v1.9.0
	- v1.8.0
	- v1.7.5
	- v1.7.4
```

```console
$ minikube start --kubernetes-version="v1.11.1"
Starting local Kubernetes v1.11.1 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Downloading kubeadm v1.11.1
Downloading kubelet v1.11.1
Finished Downloading kubeadm v1.11.1
Finished Downloading kubelet v1.11.1
Setting up certs...
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

- Le seul (ou presque) outil pour interagir avec des clusters Kubernetes
- Utilise un fichier de configuration pour communiquer avec l'API de Kubernetes
- Le(s) fichier(s) se trouve(nt) par défaut dans `~/.kube/config`
- Le fichier de config. contient :
    - L'adresse(URI) de l'APIServer
    - Les chemins des certificats TLS utilisés pour l'authentification

- Fichier `kubeconfig` peut être passé en paramètre de kubectl avec le _flag_ `--kubeconfig`

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

- Ces commandes sont équivalentes :

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
kubectl get -n kube-system get pods
```

### Kubernetes : Kubectl

- Afficher les pods (pour le namespace _default_)

```console
kubectl get pods
kubectl get pod
```

### Kubernetes : Kubectl

- Afficher les services (pour le _namespace_ `default`)

```console
kubectl get services
kubectl get svc
```

### Kubernetes : Kubernetes Dashboard

- Interface graphique web pour les clusters Kubernetes
- Permet de gérer les différents objets Kubernetes créés dans le(s) cluster(s).
- Installé par défaut dans minikube

### Kubernetes : Kubernetes Dashboard
![Kubernetes Dashboard](images/kubernetes/ui-dashboard.png)

### Kubernetes : Kubernetes Dashboard
![Logs in Kubernetes Dashboard](images/kubernetes/ui-dashboard-logs-view.png)


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
- Il est possible de directement créer un `Secret` à partir d'une

### Kubernetes : Secrets

```console
$ kubectl create secret docker-registry mydockerhubsecret \
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
- `Chart` : Contient toutes les ressources définies et nécessaires pour éxecuter une application ou un service à  l'intérieur de cluster Kubernetes. Un chart est pratiquement un regroupement de ressources Kubernetes pré-configurées.
- `Release` : Une instance d'un chart helm s'éxécutant dans un cluster Kubernetes.
- `Repository` : répertoire ou espace (public ou privé) où sont regroupés les `charts`. 

### Kubernetes : Introduction to Helm 

- Installer Helm (sur une distribution Linux):`curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash`
- Deployer tiller : `helm init`
- Voir la liste des `charts` disponibles sur les répertoire officiel:
	`helm search`
- Afficher la liste des `charts` disponibles pour _prometheus_ :
	`helm search prometheus`
- Afficher les options disponibles dans un `chart` Helm:
	`helm inspect stable/prometheus`
