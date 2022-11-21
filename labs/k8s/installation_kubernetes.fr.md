# Création d'un cluster Kubernetes

## Installation avec Minikube

<hr>
Machine : **master**
<hr>

1. Commençons par l'installation du binaire Minikube :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

2. Nous pouvons donc vérifier l'installation de minikube :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
minikube version

minikube version: v1.15.1
commit: 23f40a012abb52eff365ff99a709501a61ac5876
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


1. Maintenant que nous avons installé le binaire minikube, nous pouvons donc bootstrap un cluster Kubernetes :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
minikube start

😄  minikube v1.20.0 sur Darwin 11.2.3
✨  Choix automatique du pilote docker. Autres choix:
👍  Démarrage du noeud de plan de contrôle minikube dans le cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.20.2 preload ...
    > preloaded-images-k8s-v10-v1...: 491.71 MiB / 491.71 MiB  100.00% 5.96 MiB
    > gcr.io/k8s-minikube/kicbase...: 358.10 MiB / 358.10 MiB  100.00% 4.10 MiB
    > gcr.io/k8s-minikube/kicbase...: 358.10 MiB / 358.10 MiB  100.00% 4.71 MiB
🔥  Creating docker container (CPUs=2, Memory=4000MB) ...
🐳  Préparation de Kubernetes v1.20.2 sur Docker 20.10.6...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Parfait, nous pouvons à tout moment consulter le statut de notre cluster minikube :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
minikube status

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



1. Il est possible d'installer d'autres clusters en utilisant le flag profile

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
minikube start --profile <nom-du-cluster>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


6. Comme tout cluster Kubernetes, nous pouvons le manipuler via kubectl. Lors de l'installation d'un cluster Kubernetes avec minikube, kubectl est automatiquement configuré pour utiliser le cluster généré (Même si kubectl n'est pas installé durant le bootstrap du cluster). Il nous suffit donc d'installer kubectl :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

7. Nous pouvons lister les pods de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -A
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-b2mcz            1/1     Running   0          25m
kube-system   etcd-minikube                      1/1     Running   0          26m
kube-system   kube-apiserver-minikube            1/1     Running   0          26m
kube-system   kube-controller-manager-minikube   1/1     Running   0          26m
kube-system   kube-proxy-4hq45                   1/1     Running   0          25m
kube-system   kube-scheduler-minikube            1/1     Running   0          26m
kube-system   storage-provisioner                1/1     Running   1          26m
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

1. Nous allons déployer un pod base sur l'image nginx à titre d'exemple :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl run --image=nginx:latest test-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
pod/test-pod created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. On peut à tout moment, stopper le cluster minikube :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
minikube stop
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 nodes stopped.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Enfin, si on souhaite détruire notre cluster Kubernetes, nous pouvons le faire de la façon suivante (après avoir stoppé le cluster via la commande ci-dessus) :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
rm -rf ~/.minikube

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

## Installation avec Kubeadm

<hr>
Machines : **master**, **worker-0**, **worker-1**
<hr>

Mettre à jour le fichier /etc/hosts en renseignant les IP des trois VM. **Prenez soin de remplacer les adresses IP par celles de vos VM.**

exemple :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
# /etc/hosts file
10.10.4.80 master
10.10.4.81 worker-0
10.10.4.82 worker-1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


⚠️ <font color=red>Si kubeadm est déjà installé sur vos instances, Veuillez passer au point 3.</font>


Le contenu du fichier /etc/hosts doit être identique sur les trois machines.

1. Installer et activer Docker

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo apt-get update

sudo apt-get install docker.io

sudo systemctl enable docker

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Nous allons commencer par installer l’outil Kubeadm, la Kubelet et Kubectl sur les trois machines. Pour ce faire :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get update

sudo apt-get install -y kubelet=1.19.11-00 kubeadm=1.19.11-00 kubectl=1.19.11-00

sudo apt-mark hold kubelet kubeadm kubectl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Une fois ces outils installés, nous allons utiliser Kubeadm pour initialiser un cluster Kubernetes avec le noeud master. Ainsi, nous pouvons exécuter la commande suivante sur le noeud master uniquement:


3.1 (Préparation de l'environnement) Installation de la completion pour kubectl

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

source ~/.bashrc

# test 
k get nodes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



3.2 Installation du cluster kubernetes 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo kubeadm init 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:
...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Un token sera généré à l'issue du processus d'initialisation. Il est important de le sauvegarder car il servira à connecter les worker nodes au cluster

 

4. Nous avons donc installé un premier noeud master Kubernetes. Nous allons maintenant configurer la CLI kubectl pour pouvoir l’utiliser depuis le master:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Nous allons maintenant installer un add-on réseaux pour nos pods sur le master. Il existe plusieurs plugins répondant à ce besoin : Calico, Canal, Weave, Flannel etc. Pour cette exercice, nous allons installer le plugin weave, de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Note** : Si on souhaite utiliser les network policies (que nous explorerons plus tard), il faut utiliser un plugin supportant cette fonctionnalité. (Il faut éviter flannel notamment)



6. Nous allons maintenant ajouter les deux noeuds worker à notre cluster. Pour ce faire, nous allons utiliser la commande suivante sur les noeuds worker worker-0 et worker-1:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
training@worker$ sudo kubeadm join INTERNAL_MASTER_IP:6443 --token TOKEN --discovery-token-ca-cert-hash DISC_TOKEN
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

7. Nous pouvons lister les noeuds de la façon suivante afin de nous assurer que les noeuds worker ont bien rejoint le cluster (les noeuds worker sont NotReady pour quelques secondes) :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get nodes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME     STATUS   ROLES    AGE     VERSION
master   Ready    master   25m     v1.19.3
worker-0   Ready    <none>   2m24s   v1.19.3
worker-1   Ready    <none>   1m24s   v1.19.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


8. Nous allons déployer un pod redis pour tester l’installation de notre cluster :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl run --image redis test-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
pod/test-pod created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


9. Une petite liste des pods en cours d’exécution pour s’assurer que tout fonctionne bien :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          34s

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

10. Supprimons maintenant notre pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete pod test-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>
