# KUBERNETES : Installation

### Kubernetes Local : Poste Personnel


| Solution      | Description                                                                 | Avantages                                                                                      | Inconvénients                                                                                   |
|---------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| Minikube      | Outil officiel pour installer un cluster Kubernetes local sur une machine. | - Facile à installer et à configurer<br>- Compatible avec la majorité des environnements<br>- Supporte divers hyperviseurs et conteneurs | - Peut être lourd en ressources<br>- Nécessite une VM pour fonctionner                         |
| Kind          | Kubernetes IN Docker (KinD) utilise Docker pour exécuter des clusters.      | - Léger et rapide<br>- Simple à configurer<br>- Idéal pour les tests CI/CD                      | - Moins de fonctionnalités avancées<br>- Dépend de Docker                                      |
| MicroK8s      | Distribution légère de Kubernetes par Canonical.                            | - Facile à installer<br>- Léger et optimisé<br>- Idéal pour les environnements de développement | - Moins de flexibilité dans la configuration<br>- Utilise des snaps (peut ne pas plaire à tout le monde) |
| K3s           | Distribution allégée de Kubernetes par Rancher.                             | - Très léger et rapide<br>- Idéal pour les environnements IoT et edge<br>- Moins de ressources requises | - Moins de fonctionnalités intégrées<br>- Moins documenté que Minikube                         |
| Docker Desktop| Inclut une option pour exécuter Kubernetes directement.                     | - Facile à utiliser pour les développeurs habitués à Docker<br>- Intégration transparente avec Docker | - Peut être lourd en ressources<br>- Moins flexible que Minikube ou Kind                       |


     

### Kubernetes Local : Minikube

- Installation : <https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download>

- Créer un cluster
    - minikube start

- Les cluster sont ajoutés automatiquement au fichier ~/.kube/config 
- Les cluster sont supprimés automatiquement au fichier ~/.kube/config avec la commande `minikube delete [--all]`

- Supporte de nombreux drivers

    - (HyperKit, Hyper-V, KVM, VirtualBox, but also Docker and many others)

- Beaucoup de plugins 

     

### Kubernetes Local : k3s   

Pré-requis :
- Linux 
- Raspberry
  
- Installation : <https://docs.k3s.io/installation>

ou plus simplement : `curl -sfL https://get.k3s.io | sh -`

     

- K3s est conçu pour être très léger, nécessitant seulement environ 512 Mo de RAM pour fonctionner. Cela le rend idéal pour les environnements avec des ressources limitées.

     


### Kubernetes Local : kind 

- Kubernetes-in-Docker
- Il faut un serveur docker
- Fonctionne aussi avec podman
- Créer un cluster
     - `kind create cluster`
- Possibilité de créer plusieurs clusters
- Possibilité de créer des clusters de plusieurs noeuds (avec un fichier de config yaml)

     

### Kubernetes Local : Docker Desktop

- Installation : <https://www.docker.com/products/docker-desktop/>

- Licence obligatoire si autre utilisation que personnelle (<https://www.docker.com/pricing/>)



![docker desktop](images/docker-desktop.svg){height="300px"}

    

### Installation de Kubernetes 


- De nombreuses ressources présentes pour le déploiement de Kubernetes dans un environnement de production

- Un des outils est [kubeadm](https://github.com/kubernetes/kubeadm) utilisé pour rapidement démarrer / configurer un cluster Kubernetes

### Installation de Kubernetes avec kubeadm

- Certains pré-requis sont nécessaires avant d'installer Kubernetes :
    - Désactiver le `swap` (Support **alpha** depuis la 1.22)
    - Assurer que les ports requis soient ouverts : <https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports>
    - Installer une Container Runtime compatible CRI (containerd, CRI-O, Docker, ...)

### kubeadm

- Installer les composants Kubernetes (kubeadm, kubectl, kubelet) : <https://kubernetes.io/docs/setup/independent/install-kubeadm/>
- Exécuter : 
     - `kubeadm init` sur le noeud `master`(control plane)
     - `kubeadm join` sur les autres noeuds (worker) (avec le token fournit par la commande `kubeadm init`)
- Copier le fichier de configuration généré par `kubeadm init`
- Installer le plugin Réseau
- Optionnellement:  Tester le déploiement d'un pod


### kubeadm demo


<iframe width="560" height="315" src="https://www.youtube.com/embed/jwBK9b5X1rk?si=t8Q_aGaTV6zcr5u6" title="kubeadm" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>


### kubeadm fonctionnalités

- En plus de l'installation de Kubernetes, kubeadm peut :

    - Génération des fichiers de configuration: Crée les fichiers de configuration nécessaires pour les composants du cluster.
    - Gestion des certificats: Génère et distribue les certificats nécessaires pour sécuriser les communications entre les composants du cluster.
    - Gestion des tokens: Crée des tokens d'authentification pour les nœuds qui rejoignent le cluster.
    - Vérification de la configuration: Valide que le système et les configurations sont compatibles avec Kubernetes.
    - Mises à jour et modifications: Facilite les mises à jour des versions de Kubernetes et les modifications de la configuration du cluster.

 
### Kubernetes managés "as a Service" Majeurs

- Plateformes Cloud Majeures :
    - Amazon Elastic Kubernetes Service (EKS):
        - Documentation : https://aws.amazon.com/fr/eks/
        - Offre une solution entièrement gérée pour déployer, gérer et mettre à l'échelle des clusters Kubernetes sur AWS.
    - Google Kubernetes Engine (GKE):
        - Documentation : https://cloud.google.com/kubernetes-engine
        - Propose une plateforme hautement disponible et entièrement gérée pour exécuter des applications conteneurisées sur Google Cloud Platform.
    - Azure Kubernetes Service (AKS):
        - Documentation : https://azure.microsoft.com/fr-fr/services/kubernetes-service/
        - Permet de déployer et gérer des clusters Kubernetes sur Azure avec une intégration profonde avec les autres services Azure.


### Kubernetes managés "as a Service" Populaires

-  Autres Plateformes Populaires :
    - DigitalOcean Kubernetes:
        - Documentation : https://www.digitalocean.com/products/kubernetes/
        - Offre une solution simple et abordable pour déployer des clusters Kubernetes sur DigitalOcean.
    - Rancher Kubernetes Engine (RKE):
        - Documentation : https://rancher.com/docs/rke/latest/en/
        - Solution open-source pour gérer des clusters Kubernetes multi-cloud et sur site.
    - Platform9 Managed Kubernetes:
        - Documentation : https://platform9.com/docs/
        - Plateforme de gestion de Kubernetes hybride et multi-cloud.
    - Red Hat OpenShift:
        - Documentation : https://www.openshift.com/
        - Plateforme containerisée complète basée sur Kubernetes, offrant une large gamme de fonctionnalités pour les entreprises.
    - Scaleway Kapsule : 
        - Documentation : https://www.scaleway.com/fr/kubernetes-kapsule/
    - Alibaba Container Service for Kubernetes (ACK) 
        -  Documentation : https://www.alibabacloud.com/fr/product/kubernetes

### Installateurs de Kubernetes

- Via Ansible : `kubespray` <https://github.com/kubernetes-sigs/kubespray>
- Via Terraform : <https://github.com/poseidon/typhoon>
- Il existe d'autres projets open source basés sur le langage Go :
    - kube-aws : <https://github.com/kubernetes-incubator/kube-aws>
    - kops : <https://github.com/kubernetes/kops>
    - rancher : <https://rancher.com/docs/rancher/v2.5/en/>
    - tanzu : <https://github.com/vmware-tanzu>
    - clusterAPI : <https://cluster-api.sigs.k8s.io/>

    
### Conformité kubernetes

Voici quelques outils permettant de certifier les déploiements des cluster kubernetes en terme de sécurité et de respects des standard

- Sonobuoy 
    - <https://github.com/vmware-tanzu/sonobuoy>
- Popeye
    - <https://github.com/derailed/popeye>
- kube-score
    - <https://github.com/zegl/kube-score>
- kube-bench
    - <https://github.com/aquasecurity/kube-bench>
- Kube-hunter:
    - <https://github.com/aquasecurity/kube-hunter>

   

