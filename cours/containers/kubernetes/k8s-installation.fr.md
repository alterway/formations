# Kubernetes : Installation

### Kubernetes : Minikube

- Outil permettant de démarrer rapidement un cluster mono-node Kubernetes localement
- Execute Kubernetes dans une machine virtuelle
- Nécessite des outils de virtualisation (VirtualBox, VMware Fusion, KVM, etc...)
- Supporte plusieurs systèmes d'exploitation : Linux, Mac OS, Windows
- Installation : <https://github.com/kubernetes/minikube#Installation>


### Kubernetes : Minikube

- Création d'un cluster Kubernetes

```console
$ minikube get-k8s-versions
The following Kubernetes versions are available when using the localkube bootstrapper:
  - v1.16.1
  - v1.15.5
  - v1.14.3
  - v1.9.4
  - v1.9.0
```

### Kubernetes : Minikube

```console
$minikube start --kubernetes-version="v1.16.1"
Starting local Kubernetes v1.16.1 cluster...
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
Client Version: v1.16.1
Server Version: v1.16.1
```


### Kubernetes : Minikube

```console
$ kubectl get componentstatuses
NAME                      STATUS    MESSAGE              ERROR
controller-manager   Healthy      ok
scheduler                  Healthy      ok
etcd-0                       Healthy      {"health": "true"}
```

### Installation de Kubernetes


- De nombreuses ressources présentes pour le déploiement de Kubernetes dans un environnement de production

- Un des outils est [kubeadm](https://github.com/kubernetes/kubeadm) utilisé pour rapidement démarrer un cluster Kubernetes

### Installation de Kubernetes avec Kubeadm

- Certains pré-requis sont nécessaires avant d'installer Kubernetes :
    - Désactiver le swap
    - Assurer que les ports requis soient ouverts : <https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports>
    - Installer une Container Runtime compatible CRI

### Kubeadm

- Installer les composants Kubernetes (kubeadm, kubectl, kubelet) : <https://kubernetes.io/docs/setup/independent/install-kubeadm/>
- Exécuter `kubeadm init` sur le noeud master
- Exécuter `kubeadm join` sur les autres noeuds (avec le token fournir par la commande `kubeadm init`)
- Copier le fichier de configuration généré par `kubeadm init`
- Installer le plugin Réseau

### Kubeadm

En plus de l'installation de Kubernetes, Kubeadm peut :

- Renouveler les certificats du Control Plane
- Générer des certificats utilisateurs signés par Kubernetes
- Effectuer des upgrades de Kubernetes (`kubeadm upgrade`)

### Kubernetes managés "as a Service"

- Il existe des solutions managées pour Kubernetes sur les cloud publics :
    - Azure Kubernetes Service : <https://azure.microsoft.com/en-us/services/kubernetes-service/>
    - Google Kubernetes Engine : <https://cloud.google.com/kubernetes-engine/>
    - Elastic Kubernetes Services: <https://aws.amazon.com/eks/>
    - Docker Universal Control Plane : <https://docs.docker.com/ee/ucp/>

### Installation de Kubernetes

- Via Ansible : kubespray <https://github.com/kubernetes-sigs/kubespray>
- Via Terraform : <https://github.com/poseidon/typhoon>
- Il existe aussi des projets open source basés sur le langage Go :
    - kube-aws : <https://github.com/kubernetes-incubator/kube-aws>
    - kops : <https://github.com/kubernetes/kops>

### Introduction à Sonobuoy

- Outil de conformité de clusters Kubernetes
- Permet de facilement générer des données de diagnostics pour les applications déployées
- <https://github.com/heptio/sonobuoy/>

