
# KUBERNETES : Architecture

### Kubernetes : Composants

- Kubernetes est écrit en Go, compilé statiquement.
  
- Un ensemble de binaires sans dépendances
  
- Faciles à conteneuriser et à packager
  
- Peut se déployer uniquement avec des conteneurs sans dépendance d'OS
  
- k3d, kind, minikube, docker...

### Kubernetes : Les noeuds (Nodes)

- Les noeuds qui exécutent les conteneurs embarquent  :

    - Un "container Engine" (Docker, CRI-O, containerd...)
  
    - Une "kubelet" (node agent)
  
    - Un kube-proxy (un composant réseau nécessaire mais pas suffisant)
  
- Ancien nom des noeuds : **Minions**


### Kubernetes : Architecture

![Synthèse architecture](images/k8s-archi.png)


### Kubernetes : Composants du Control Plane

- `etcd`: magasin de données clé-valeur open source cohérent et distribué

- `kube-apiserver` : L'API Server est un composant qui expose l'API Kubernetes, l'API server qui permet la configuration d'objets Kubernetes (Pod, Service, Deployment, etc.)

- core services :

    - `kube-scheduler` : Implémente les fonctionnalités de scheduling
    - `kube-controller-manager` : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré
    - `kube-cloud-controller-manager` : Est un composant important du plan de contrôle (control plane) de Kubernetes, spécifiquement conçu pour interagir avec l'infrastructure cloud sous-jacente
    - `kube-proxy` : Permet le forwarding TCP/UDP et le load balancing entre les services et les backends (Pods)

- Le control plane est aussi appelé "Master"

![](images//kubernetes/control-plane.webp){height="250px"}

### Kubernetes : `etcd`

- Site : <https://etcd.io>
- Code : <https://github.com/etcd-io/etcd> 
- Base de données de type Clé/Valeur distribuée (_Distributed Key Value Store_) 
- Haute disponibilité: etcd est conçu pour être hautement disponible, même en cas de panne de certains nœuds
- Cohérence forte: etcd garantit que toutes les données sont cohérentes entre tous les nœuds.
- API simple: etcd offre une API simple et facile à utiliser pour interagir avec les données.
- Surveillance: etcd fournit des outils de surveillance pour suivre l'état du cluster.
- Stocke l'état d'un cluster Kubernetes
- Point sensible (stateful) d'un cluster Kubernetes
- Projet intégré à la CNCF (<https://github.com/etcd-io>)


![](images//kubernetes/etcd.svg){height="240px"}

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

![](images//kubernetes/kube-api-server-ezgif.com-crop.gif){height="200px"}


### Kubernetes : `kube-scheduler`

Le kube-scheduler est le composant responsable d'assigner les pods aux nœuds "worker" du cluster. Il choisit alors selon les contraintes qui lui sont imposées un nœud sur lequel les pods peuvent être démarrés et exécutés.

- Planifie les ressources sur le cluster
- En fonction de règles implicites (CPU, RAM, stockage disponible, etc.)
- En fonction de règles explicites (règles d'affinité et anti-affinité, labels, etc.)

![](images//kubernetes/kubescheduler.png){height="300px"}



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


![](images//kubernetes/control-loop.svg){height="250px"}



### Kubernetes : `kube-cloud-controller-manager`

- Fonction principale :

    - Le CCM agit comme une interface entre Kubernetes et le fournisseur de cloud spécifique (comme AWS, Google Cloud, Azure, etc.). Il permet à Kubernetes de gérer les ressources spécifiques au cloud de manière indépendante du reste du cluster.
    - Séparation des responsabilités :
        - Avant l'introduction du CCM, le contrôleur de nœud (node controller), le contrôleur de route (route controller) et le contrôleur de service (service controller) étaient intégrés au contrôleur de gestion Kubernetes (kube-controller-manager). Le CCM a extrait ces fonctionnalités spécifiques au cloud pour les gérer séparément.
    - Contrôleurs spécifiques au cloud : Le CCM implémente plusieurs contrôleurs qui interagissent avec l'API du fournisseur de cloud :
        - Node Controller : Vérifie si les nœuds ont été supprimés dans le cloud après avoir cessé de répondre.
        - Route Controller : Configure les routes dans l'infrastructure cloud pour que les pods sur différents nœuds puissent communiquer.
        - Service Controller : Crée, met à jour et supprime les load balancers du cloud.

![](images//kubernetes/Kubernetes-Architecture-Diagram-Explained.png){height="280px"}


### Kubernetes : `kube-proxy`

Le kube-proxy maintient les règles réseau sur les nœuds. Ces règles permettent la communication vers les pods depuis l'intérieur ou l'extérieur de votre cluster.

- Responsable de la publication de services

- Route les paquets à destination des PODs et réalise le load balancing TCP/UDP

- 3 modes de proxyfication :

     - Userspace mode
  
     - IPtables mode
  
     - IPVS (IP Virtual Server) mode


**Remarque**: Par défaut, Kube-proxy fonctionne sur le port 10249. Vous pouvez utiliser un ensemble d'endpoints exposés par Kube-proxy pour l'interroger et obtenir des informations.

Pour voir quel mode est utilisé :

Sur un des noeuds executer la commande :

```bash
curl -v localhost:10249/proxyMode;echo

# ex: retourne iptables
```

Certains plugins réseaux, tel que **Cilium**, permettent de ne plus utiliser **kube-proxy** et de le remplacer par un composant du CNI 

### Kubernetes : `kube-proxy` Userspace mode

![](images//kubernetes/services-userspace-overview.svg){height="400px"}

- Userspace mode est ancien et inefficace. 
- Le paquet est comparé aux règles iptables puis transféré au pod **kube-Proxy**, qui fonctionne comme une application pour transférer le paquet aux pods backend.
- Kube-proxy fonctionne sur chaque nœud en tant que processus dans l'espace utilisateur. 
- Il distribue les requêtes entre les pods pour assurer l'équilibrage de charge et intercepte la communication entre les services. 
- Malgré sa portabilité et sa simplicité, le surcoût de traitement des paquets dans l'espace utilisateur le rend moins efficace pour les charges de trafic élevées.


### Kubernetes : `kube-proxy` IPtables mode

![](images//kubernetes/services-iptables-overview.svg){height="400px"}

- Le mode iptables est préférable car il utilise la fonctionnalité iptables du noyau, qui est assez mature. 
- kube-proxy gère les règles iptables en fonction du fichier YAML du service de Kubernetes.
- Pour gérer le trafic des services, Kube-proxy configure des règles iptables sur chaque nœud.
- Il achemine les paquets vers les pods pertinents en utilisant du NAT (Network Address Translation) iptables. 
- Ce mode fonctionne bien avec des volumes de trafic modestes et est plus efficace que le mode espace utilisateur.

### Kubernetes : `kube-proxy` IPVS mode


![](images//kubernetes/services-ipvs-overview.svg){height="400px"}

- IPVS mode équilibre la charge en utilisant la fonctionnalité IPVS du noyau Linux. Par rapport au mode IPtables, il offre une meilleure évolutivité et des performances améliorées.
  
- IPVS est le mode recommandé pour les installations à grande échelle car il peut gérer de plus gros volumes de trafic avec efficacité. **IPtable Non !**



### Kubernetes : Kubelet

Elle, Il, iel ?  😉

- Agent principal du nœud : Kubelet est le principal agent qui s'exécute sur chaque nœud (machine) d'un cluster Kubernetes.
- Gestion des pods : Elle est responsable de la création, de la mise à jour et de la suppression des pods sur ce nœud, en suivant les instructions du plan de contrôle Kubernetes.
- Communication avec l'API Kubernetes : Kubelet communique en permanence avec l'API Kubernetes pour recevoir les mises à jour de configuration et les commandes.
- Exécution des conteneurs : Il utilise un runtime de conteneur (comme Docker ou containerd) pour lancer et gérer les conteneurs à l'intérieur des pods.
- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de Kubernetes).
    - Applique les modifications si besoin (upgrade, rollback).
- Surveillance de l'état des pods : Kubelet surveille en permanence l'état des pods et des conteneurs, et signale tout problème au plan de contrôle.
- Gestion des ressources : Il gère l'allocation des ressources (CPU, mémoire) aux pods et assure que les limites de ressources ne sont pas dépassées.
- Intégration avec le système d'exploitation : Kubelet s'intègre avec le système d'exploitation hôte pour gérer les réseaux, les volumes et autres fonctionnalités du système.


![](images//kubernetes/CRI.png){height="300px"}




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
    - **Calico** : <https://projectcalico.docs.tigera.io/about/about-calico/>
    - **Cilium** : <https://github.com/cilium/cilium>
    - **Flannel** : <https://github.com/flannel-io/flannel#flannel>
    - **Multus** : Un  Multi Network plugin permet d'avoir des pods avec plusieurs interfaces
    - **Weave Net** : https://www.weave.works/oss/net/ 
    - Voir les autres : <https://kubernetes.io/docs/concepts/cluster-administration/networking/>

    

### Kubernetes : Aujourd'hui

Les versions de Kubernetes sont exprimées sous la forme x.y.z, où x est la version majeure, y est la version mineure et z est la version du correctif, conformément à la terminologie du Semantic Versioning.

- Version 1.35.x : stable en production
- Solution complète
- Éprouvée par Google
- <https://kubernetes.io/releases/>


**1.35**

**Latest Release:**1.35.0 (released: 2025-12-17)

**End of Life:**2027-02-28

Complete 1.35 [Schedule](https://kubernetes.io/releases/patch-releases/#1-35) and [Changelog](https://git.k8s.io/kubernetes/CHANGELOG/CHANGELOG-1.35.md)




![Top expectation](images/kubernetes/k2024.avif){height="350px"}


