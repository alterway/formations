
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


### Kubernetes : Architecture

![Synthèse architecture](images/k8s-archi.png)


### Kubernetes : Composants du Control Plane

- `etcd`: magasin de données clé-valeur open source cohérent et distribué
- `kube-apiserver` : L'API Server est un composant qui expose l'API Kubernetes, l'API server qui permet la configuration d'objets Kubernetes (Pod, Service, Deployment, etc.)
- core services :
    - `kube-proxy` : Permet le forwarding TCP/UDP et le load balancing entre les services et les backends (Pods)
    - `kube-scheduler` : Implémente les fonctionnalités de scheduling
    - `kube-controller-manager` : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré
- Le control plane est aussi appelé "Master"

### Kubernetes : `etcd`

- Site : <https://etcd.io>
- Code : <https://github.com/etcd-io/etcd> 
- Base de données de type Clé/Valeur (_Key Value Store_)
- Stocke l'état d'un cluster Kubernetes
- Point sensible (stateful) d'un cluster Kubernetes
- Projet intégré à la CNCF (<https://github.com/etcd-io>)

### Kubernetes : `kube-apiserver`

Sans le `kube-apiserver` le cluster ne sert à rien. De plus, il est `LE SEUL` à interagir avec le cluster `etcd`, que ce soit en écriture ou en lecture.

- Les configurations d'objets (Pods, Service, RC, etc.) se font via l'API server
- Un point d'accès à l'état du cluster aux autres composants via une API REST
- Tous les composants sont reliés à l'API server
- Roles :
    - Reçoit les requêtes API faites au cluster
    - Authentifie les requêtes
    - Valide les requêtes
    - Récupère, Met à jour les données dans `etcd`
    - Transmet les réponses aux clients
    - Intéragit avec le kube-scheduler, le controller-manager, le kubelet, etc... 
    - C'est une API donc utilisable via des composants externes (kubectl, curl, lens, ...)

### Kubernetes : `kube-scheduler`

Le kube-scheduler est le composant responsable d'assigner les pods aux nœuds "worker" du cluster. Il choisit alors selon les contraintes qui lui sont imposées un nœud sur lequel les pods peuvent être démarrés et exécutés.

- Planifie les ressources sur le cluster
- En fonction de règles implicites (CPU, RAM, stockage disponible, etc.)
- En fonction de règles explicites (règles d'affinité et anti-affinité, labels, etc.)


### Kubernetes : `kube-controller-manager`

Le kube-controller-manager exécute et fait tourner les processus de contrôle du cluster.

- Boucle infinie qui contrôle l'état d'un cluster
- Effectue des opérations pour atteindre un état donné
- De base dans Kubernetes : replication controller, endpoints controller, namespace controller et serviceaccounts controller
- Processus de contrôle :
    - Node Controller : responsable de la gestion des nœuds du cluster et de leur cycle de vie
    - Replication Controller : responsable du maintien du nombre de pods pour chaque objet de réplication dans le cluster
    - Endpoints Controller : fait en sorte de joindre correctement les services et les pods 
    - Service Account & Token Controllers : Gestion des comptes et des tokens d'accès à l'API pour l'accès aux `namespaces` Kubernetes

### Kubernetes : `kube-proxy`

Le kube-proxy maintient les règles réseau sur les nœuds. Ces règles permettent la communication vers les pods depuis l'intérieur ou l'extérieur de votre cluster.

- Responsable de la publication de services
- Utilise *iptables*
- Route les paquets à destination des PODs et réalise le load balancing TCP/UDP


### Kubernetes : Kubelet

- Service principal de Kubernetes
- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de Kubernetes).
    - Applique les modifications si besoin (upgrade, rollback).
- Surveille l'état des services du cluster via l'API server (*kube-apiserver*).
  


### Kubernetes : Autres composants

- kubelet : Service "agent" fonctionnant sur tous les nœuds et assurant le fonctionnement des autres services
- kubectl : Ligne de commande permettant de piloter un cluster Kubernetes



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
- Quelques exemple d'implémentations : 
    - Calico : <https://projectcalico.docs.tigera.io/about/about-calico/>
    - Cilium : <https://github.com/cilium/cilium>
    - Flannel : <https://github.com/flannel-io/flannel#flannel>
    - Multus : Un  Multi Network plugin permet d'avoir des pods avec plusieurs interfaces
    - Weave Net : https://www.weave.works/oss/net/ 
    - Voir les autres : <https://kubernetes.io/docs/concepts/cluster-administration/networking/>

    

### Kubernetes : Aujourd'hui

- Version 1.30.x : stable en production
- Solution complète et une des plus utilisées
- Éprouvée par Google
- <https://kubernetes.io/releases/>


**1.31:**
    Latest Release:1.31.0 (released: 2024-08-13)  
    End of Life:2025-10-28  
    Patch Releases: n/a  
    Complete 1.31 [Schedule](https://kubernetes.io/releases/patch-releases/#1-31) and [Changelog](https://git.k8s.io/kubernetes/CHANGELOG/CHANGELOG-1.31.md)


    

    