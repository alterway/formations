
# KUBERNETES : Architecture

### Kubernetes : Composants

- Kubernetes est écrit en Go, compilé statiquement.
- Un ensemble de binaires sans dépendances
- Faciles à conteneuriser et à packager
- Peut se déployer uniquement avec des conteneurs sans dépendance d'OS
  - k3d, kind, minikube, docker...

### Kubernetes : Les noeuds (Nodes)

- Les noeuds qui exécutent les conteneurs sont composés de
  - Un "container Engine" (Docker, CRI-O, containerd...)
  - Une "kubelet" (node agent)
  - Un kube-proxy (un composant réseau nécessaire mais pas suffisant)
- Ancien non des noeuds : **Minions**


### Kubernetes : Composants du Control Plane

- etcd: magasin de données clé-valeur open source cohérent et distribué
- kube-apiserver : API server qui permet la configuration d'objets Kubernetes (Pod, Service, Deployment, etc.)
- core services :
  - kube-proxy : Permet le forwarding TCP/UDP et le load balancing entre les services et les backends (Pods)
  - kube-scheduler : Implémente les fonctionnalités de scheduling
  - kube-controller-manager : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré
- Le control plane est aussi appelé "Master"

### Kubernetes : etcd

- Base de données de type Clé/Valeur (_Key Value Store_)
- Stocke l'état d'un cluster Kubernetes
- Point sensible (stateful) d'un cluster Kubernetes
- Projet intégré à la CNCF

### Kubernetes : kube-apiserver

- Les configurations d'objets (Pods, Service, RC, etc.) se font via l'API server
- Un point d'accès à l'état du cluster aux autres composants via une API REST
- Tous les composants sont reliés à l'API server

### Kubernetes : kube-scheduler

- Planifie les ressources sur le cluster
- En fonction de règles implicites (CPU, RAM, stockage disponible, etc.)
- En fonction de règles explicites (règles d'affinité et anti-affinité, labels, etc.)

### Kubernetes : kube-proxy

- Responsable de la publication de services
- Utilise *iptables*
- Route les paquets à destination des PODs et réalise le load balancing TCP/UDP

### Kubernetes : kube-controller-manager

- Boucle infinie qui contrôle l'état d'un cluster
- Effectue des opérations pour atteindre un état donné
- De base dans Kubernetes : replication controller, endpoints controller, namespace controller et serviceaccounts controller

### Kubernetes : Autres composants

- kubelet : Service "agent" fonctionnant sur tous les nœuds et assurant le fonctionnement des autres services
- kubectl : Ligne de commande permettant de piloter un cluster Kubernetes

### Kubernetes : Kubelet

- Service principal de Kubernetes
- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de Kubernetes).
    - Applique les modifications si besoin (upgrade, rollback).
- Surveille l'état des services du cluster via l'API server (*kube-apiserver*).
  
### Kubernetes : Architecture

![Synthèse architecture](images/components-of-kubernetes.svg)


### Kubernetes : Architecture détaillée

![Architecture détaillée](images/k8s-arch4-thanks-luxas.png)

### Kubernetes : Cluster Architecture

![Cluster architecture](images/k8s-arch2.png)

### Kubernetes: Network

Kubernetes n'implémente pas de solution réseau par défaut, mais s'appuie sur des solutions tierces qui implémentent les fonctionnalités suivantes:

- Chaque pods reçoit sa propre adresse IP
- Tous les nœuds doivent pouvoir se joindre, sans NAT
- Les pods peuvent communiquer directement sans NAT
- Les pods et les nœuds doivent pouvoir se rejoindre, sans NAT
- Chaque pod est conscient de son adresse IP (pas de NAT)
- Kubernetes n'impose aucune implémentation particulière

### Kubernetes : Aujourd'hui

- Version 1.22.x : stable en production
- Solution complète et une des plus utilisées
- Éprouvée par Google


