# Création d'un cluster Kubernetes

## Installation avec Kubeadm

verification de la version 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

kubeadm version

kubeadm version: &version.Info{Major:"1", Minor:"27", GitVersion:"v1.27.9", GitCommit:"d15213f69952c79b317e635abff6ff4ec81475f8", GitTreeState:"clean", BuildDate:"2023-12-19T13:39:19Z", GoVersion:"go1.20.12", Compiler:"gc", Platform:"linux/amd64"}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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



1. Nous allons utiliser Kubeadm pour initialiser un cluster Kubernetes avec le noeud master. 


1.1 (Préparation de l'environnement) Installation de la completion pour kubectl

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

source ~/.bashrc

# test 
k version
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



1.2 Installation du cluster kubernetes 

Machine : **master**

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

Notez la commande de join :

exemple :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubeadm join 10.10.3.243:6443 --token m03nzv.vtfeaij5yu876u7z \
	--discovery-token-ca-cert-hash sha256:2da9df40f55f901d221d30cf0574264bcd4c62b7c38200498e99e2797a55753f
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

2. Nous avons donc installé un premier noeud master Kubernetes. Nous allons maintenant configurer la CLI kubectl pour pouvoir l’utiliser depuis le master:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


3. Nous allons maintenant installer un add-on réseaux pour nos pods sur le master. Il existe plusieurs plugins répondant à ce besoin : Calico, Canal, Weave, Flannel etc. Pour cette exercice, nous allons installer le plugin weave, de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Vérification :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
ubuntu@master:~$ k get nodes
NAME     STATUS     ROLES           AGE     VERSION
master   NotReady   control-plane   3m34s   v1.27.9
ubuntu@master:~$ k get nodes
NAME     STATUS   ROLES           AGE     VERSION
master   Ready    control-plane   4m18s   v1.27.9
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Note** : Si on souhaite utiliser les network policies (que nous explorerons plus tard), il faut utiliser un plugin supportant cette fonctionnalité. (Il faut éviter flannel notamment)


Machines : **worker-0**, **worker-1**
4. Nous allons maintenant ajouter les deux noeuds worker à notre cluster. Pour ce faire, nous allons utiliser la commande suivante sur les noeuds worker worker-0 et worker-1:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubeadm join INTERNAL_MASTER_IP:6443 --token TOKEN --discovery-token-ca-cert-hash DISC_TOKEN
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Nous pouvons lister les noeuds de la façon suivante afin de nous assurer que les noeuds worker ont bien rejoint le cluster (les noeuds worker sont NotReady pour quelques secondes) :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get nodes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME     STATUS   ROLES    AGE     VERSION
master   Ready    master   25m     v1.19.3
worker-0   Ready    <none>   2m24s   v1.19.3
worker-1   Ready    <none>   1m24s   v1.19.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


6. Nous allons déployer un pod redis pour tester l’installation de notre cluster :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl run --image redis test-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
pod/test-pod created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


7. Une petite liste des pods en cours d’exécution pour s’assurer que tout fonctionne bien :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          34s

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

8. Supprimons maintenant notre pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete pod test-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>
