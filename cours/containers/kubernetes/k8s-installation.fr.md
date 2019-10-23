# Kubernetes : Installation

### Installation de Kubernetes

- De nombreuses ressources présentes pour le déploiement de Kubernetes dans un environnement de production

- Un des outils est [kubeadm](https://github.com/kubernetes/kubeadm) utilisé pour rapidement démarrer un cluster Kubernetes

### Installation de Kubernetes avec Kubeadm

- Certains pré-requis sont nécessaires avant d'installer Kubernetes :
    - Désactiver le swap
    - Assurer que les ports requis soient ouverts : <https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports>
    - Installer une Container Runtime compatible CRI

### Installation de Kubernetes

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

### Installation de Kubernetes

- Il existe des solutions managées pour Kubernetes :
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

