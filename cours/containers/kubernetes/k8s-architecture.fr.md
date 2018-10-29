# Kubernetes : Architecture

### Kubernetes : Composants

- Kubernetes est écrit en Go, compilé statiquement.
- Un ensemble de binaires sans dépendances
- Faciles à conteneuriser et à packager
- Peut se déployer uniquement avec des conteneurs sans dépendances d'OS

### Kubernetes : Composants

- kube-apiserver : API server qui permet la configuration d'objet Kubernetes (Pods, Service, Replication Controller, etc.)
- kube-proxy : Permet le forwarding TCP/UDP et le load balancing entre les services et les backend (Pods)
- kube-scheduler : Implémente les fonctionnalités de scheduling
- kube-controller-manager : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré

### Kubernetes : Composants

- kubelet : Service "agent" fonctionnant sur tous les nœuds et assure le fonctionnement des autres services
- kubectl : Client qui permet de piloter un cluster Kubernetes

### Kubernetes : Kubelet

- Service principal de Kubernetes
- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de Kubernetes).
    - Applique les modifications si besoin (upgrade, rollback).
- Surveille l'état des services du cluster via l'API server (*kube-apiserver*).


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

### Kubernetes : kubelet

```console
root@ubuntu-xenial:~# ls -lh /etc/kubernetes/manifests/
total 16K
-rw------- 1 root root 2.0K Sep 23 20:04 etcd.yaml
-rw------- 1 root root 3.2K Sep 23 20:04 kube-apiserver.yaml
-rw------- 1 root root 2.5K Sep 23 20:04 kube-controller-manager.yaml
-rw------- 1 root root 1.1K Sep 23 20:04 kube-scheduler.yaml
```

### Kubernetes : network-policy-controller

- Implémente l'objet NetworkPolicy
- Contrôle la communication entre les Pods
- Externe à Kubernetes et implémenté par la solution de Networking choisie :
    - Calico : <https://projectcalico.org/>
    - Flannel : <https://coreos.com/flannel>
    - Romana : <https://romana.io/>
    - Weave : <https://www.weave.works/oss/net/>
    - more :  <https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model>

### Kubernetes : Aujourd'hui

- Version 1.11.x : stable en production
- Solution complète et une des plus utilisées
- Éprouvée par Google
- S'intègre parfaitement à d'autres _Container Runtime Interfaces (CRI)_ comme containerd, cri-o, rktlet, frakti, etc...


