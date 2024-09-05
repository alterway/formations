# KUBERNETES : Installation

### Kubernetes Local : Poste Personnel


| Solution      | Description                                                                 | Avantages                                                                                      | Inconvénients                                                                                   |
|---------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| Minikube      | Outil officiel pour installer un cluster Kubernetes local sur une machine. | - Facile à installer et à configurer<br>- Compatible avec la majorité des environnements<br>- Supporte divers hyperviseurs et conteneurs | - Peut être lourd en ressources<br>- Nécessite une VM pour fonctionner                         |
| Kind          | Kubernetes IN Docker (KinD) utilise Docker pour exécuter des clusters.      | - Léger et rapide<br>- Simple à configurer<br>- Idéal pour les tests CI/CD                      | - Moins de fonctionnalités avancées<br>- Dépend de Docker                                      |
| MicroK8s      | Distribution légère de Kubernetes par Canonical.                            | - Facile à installer<br>- Léger et optimisé<br>- Idéal pour les environnements de développement | - Moins de flexibilité dans la configuration<br>- Utilise des snaps (peut ne pas plaire à tout le monde) |
| K3s           | Distribution allégée de Kubernetes par Rancher.                             | - Très léger et rapide<br>- Idéal pour les environnements IoT et edge<br>- Moins de ressources requises | - Moins de fonctionnalités intégrées<br>- Moins documenté que Minikube                         |
| Docker Desktop| Inclut une option pour exécuter Kubernetes directement.                     | - Facile à utiliser pour les développeurs habitués à Docker<br>- Intégration transparente avec Docker | - Peut être lourd en ressources<br>- Moins flexible que Minikube ou Kind                       |


### Installation de Kubernetes 


- De nombreuses ressources présentes pour le déploiement de Kubernetes dans un environnement de production

- Un des outils est [kubeadm](https://github.com/kubernetes/kubeadm) utilisé pour rapidement démarrer / configurer un cluster Kubernetes

### Installation de Kubernetes avec kubeadm

- Certains pré-requis sont nécessaires avant d'installer Kubernetes :
    - Désactiver le swap (Support **alpha** depuis la 1.22)
    - Assurer que les ports requis soient ouverts : <https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports>
    - Installer une Container Runtime compatible CRI (containerd, CRI-O, Docker)

### kubeadm (1)

- Installer les composants Kubernetes (kubeadm, kubectl, kubelet) : <https://kubernetes.io/docs/setup/independent/install-kubeadm/>
- Exécuter : 
     - `kubeadm init` sur le noeud master
     - `kubeadm join` sur les autres noeuds (avec le token fournit par la commande `kubeadm init`)
- Copier le fichier de configuration généré par `kubeadm init`
- Installer le plugin Réseau
- Optionnellement:  Tester le dploiement d'un pod

### kubeadm (2)

En plus de l'installation de Kubernetes, kubeadm peut :

- Renouveler les certificats du Control Plane
- Générer des certificats utilisateurs signés par Kubernetes
- Effectuer des upgrades de Kubernetes (`kubeadm upgrade`)

### Kubernetes managés "as a Service"

- Il existe des solutions managées pour Kubernetes sur les cloud publics :
    - AWS Elastic Kubernetes Services (EKS): <https://aws.amazon.com/eks/>
    - Azure Kubernetes Service (AKS): <https://azure.microsoft.com/en-us/services/kubernetes-service/>
    - Docker Universal Control Plane : <https://docs.docker.com/ee/ucp/>
    - Google Kubernetes Engine : <https://cloud.google.com/kubernetes-engine/>
    - Scaleway Kapsule : <https://www.scaleway.com/fr/kubernetes-kapsule/>
    - Alibaba Container Service for Kubernetes (ACK) <https://www.alibabacloud.com/fr/product/kubernetes>

### Installation de Kubernetes

- Via Ansible : `kubespray` <https://github.com/kubernetes-sigs/kubespray>
- Via Terraform : <https://github.com/poseidon/typhoon>
- Il existe d'autres projets open source basés sur le langage Go :
    - kube-aws : <https://github.com/kubernetes-incubator/kube-aws>
    - kops : <https://github.com/kubernetes/kops>
    - rancher : <https://rancher.com/docs/rancher/v2.5/en/>
    - tanzu : <https://github.com/vmware-tanzu>

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

