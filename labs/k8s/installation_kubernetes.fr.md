# Installation de Kubernetes

## Installation avec Minikube

Machine : **master**

1. Commençons par l'installation du binaire Minikube :

```bash
training@master$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
training@master$ chmod +x minikube
training@master$ sudo mv minikube /usr/local/bin/
```

2. Nous pouvons donc vérifier l'installation de minikube :

```bash
training@master$ minikube version

minikube version: v1.14.1
commit: b0389943568c59c1d5a35f739c02f5127eee6e56
```

3. Maintenant que nous avons installé le binaire minikube, nous pouvons donc bootstrap un cluster Kubernetes :

```bash
training@master$ minikube start

😄  minikube v1.14.1 on Debian 10.6
✨  Automatically selected the docker driver
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.19.2 preload ...
    > preloaded-images-k8s-v6-v1.19.2-docker-overlay2-amd64.tar.lz4: 486.33 MiB
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🐳  Preparing Kubernetes v1.19.2 on Docker 19.03.8 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" by default
```

4. Parfait, nous pouvons à tout moment consulter le status de notre cluster minikube :

```bash
training@master$ minikube status

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

5. Comme tout cluster Kubernetes, nous pouvons le manipuler via kubectl. Lors de l'installation d'un cluster Kubernetes avec minikube, kubectl est automatiquement configuré pour utiliser le cluster généré (Meme si kubectl n'est pas installé durant le bootstrap du cluster). Il nous suffit donc d'installer kubectl :

```bash
training@master$ sudo apt-get install kubectl
```

6. Nous pouvons lister les pods de la facon suivante :

```bash
training@master$ kubectl get pods -A

NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-b2mcz            1/1     Running   0          25m
kube-system   etcd-minikube                      1/1     Running   0          26m
kube-system   kube-apiserver-minikube            1/1     Running   0          26m
kube-system   kube-controller-manager-minikube   1/1     Running   0          26m
kube-system   kube-proxy-4hq45                   1/1     Running   0          25m
kube-system   kube-scheduler-minikube            1/1     Running   0          26m
kube-system   storage-provisioner                1/1     Running   1          26m
```

7. Nous allons déployer un pod base sur l'image nginx à titre d'exemple :

```bash
training@master$ kubectl run --image=nginx:latest test-pod

pod/test-pod created
```

8. On peut à tout moment, stopper le cluster minikube :

```bash
training@master$ minikube stop

✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 nodes stopped.
```

9. Enfin, si on souhaite détruire notre cluster Kubernetes, nous pouvons le faire de la façon suivante (après avoir stoppé le cluster via la commande ci-dessus) :

```bash
training@master$ rm -rf ~/.minikube
```

## Installation avec Kubeadm

Machines : **master**, **worker**

1. Nous allons commencer par installer l'outil Kubeadm, la Kubelet et Kubectl sur les **deux machines**. Pour ce faire  :

```bash
training@master$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
training@master$ sudo su -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list'
training@master$ sudo apt-get update
training@master$ sudo apt-get install -y kubelet=1.18.10-00 kubeadm=1.18.10-00 kubectl=1.18.10-00
training@master$ sudo apt-mark hold kubelet kubeadm kubectl
```

2. Une fois ces outils installés, nous allons utiliser Kubeadm pour initialiser un cluster Kubernetes avec un noeud master. Ainsi, nous pouvons exécuter la commande suivante sur le noeud **master** :

> Note : Remplacer INTERNAL_MASTER_IP par l'IP interne du noeud master.

```bash
training@master$ sudo kubeadm init --apiserver-advertise-address INTERNAL_MASTER_IP

...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:
...
```

3. Nous avons donc installé un premier noeud master Kubernetes. Nous allons maintenant configurer la CLI kubectl pour pouvoir l'utiliser :

```bash
training@master$ mkdir -p $HOME/.kube
training@master$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
training@master$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

4. Nous allons maintenant installer un add-on reseaux pour nos pods. Il existe plusieurs plugins repondant à ce besoin : Calico, Canal, Weave, Flannel etc. Pour cette exercice, nous allons installer le plugin weave, de la façon suivante :

```bash
training@master$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

> Note : Si on souhaite utiliser les network policies (que nous explorerons plus tard), il faut utiliser un plugin supportant cette fonctionnalite. (Il faut éviter flannel notamment)

5. Nous allons maintenant ajouter un noeud worker a notre cluster. Pour ce faire, nous allons utiliser la commande suivante sur le noeud **worker**:

```bash
training@worker$ sudo kubeadm join INTERNAL_MASTER_IP:6443 --token TOKEN --discovery-token-ca-cert-hash DISC_TOKEN

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

6. Nous pouvons lister les noeuds de la façon suivante afin de nous assurer que le noeud worker a bien rejoint le cluster (le noeud worker est NotReady pour quelques secondes) :

```bash
training@master$ kubectl get nodes

NAME     STATUS   ROLES    AGE     VERSION
master   Ready    master   25m     v1.19.3
worker   Ready    <none>   2m24s   v1.19.3
```

7. Nous allons deployer un pod redis pour tester l'installation de notre cluster :

```bash
training@master$ kubectl run --image redis test-pod

pod/test-pod created
```

8. Une petite liste des pods en cours d'exécution pour s'assurer que tout fonctionne bien :

```bash
training@master$ kubectl get pods
```

9. Supprimons maintenant notre pod :

```bash
training@master$ kubectl delete pod test-pod

NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          34s
```

## Mise a jour d'un cluster

1. Pour commencer, il faut mettre à jour kubeadm :

```bash
training@master$ sudo apt-mark unhold kubeadm
training@master$ sudo apt-get install kubeadm=1.19.3-00
training@master$ sudo apt-mark hold kubeadm
```

2. Vérifions la version de kubeadm :

```bash
training@master$ kubeadm version

kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:47:53Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
```

3. Nous devons maintenant drain le noeud master afin de pouvoir faire l'upgrade dessus :

```bash
training@master$ kubectl drain master --ignore-daemonsets
```

4. Nous pouvons avoir un aperçu de l'upgrade de la façon suivante :

```bash
training@master$ sudo kubeadm upgrade plan

...
Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT        AVAILABLE
kubelet     2 x v1.18.10   v1.19.3

Upgrade to the latest stable version:

COMPONENT                 CURRENT    AVAILABLE
kube-apiserver            v1.18.10   v1.19.3
kube-controller-manager   v1.18.10   v1.19.3
kube-scheduler            v1.18.10   v1.19.3
kube-proxy                v1.18.10   v1.19.3
CoreDNS                   1.6.7      1.7.0
etcd                      3.4.3-0    3.4.13-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.19.3

_____________________________________________________________________
...
```

5. Nous pouvons maintenant upgrade les composants du cluster :

```bash
training@master$ sudo kubeadm upgrade apply v1.19.3

...
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.19.3". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
```

6. Nous pouvons remettre le noeud master en marche :

```bash
training@master$ kubectl uncordon master

node/master uncordoned
```

7. Nous devons maintenant mettre à jour la kubelet et kubectl :

```bash
training@master$ sudo apt-mark unhold kubectl kubelet
training@master$ sudo apt-get install kubectl=1.19.3-00 kubelet=1.19.3-00
training@master$ sudo apt-mark hold kubectl kubelet
```

8. Enfin nous devons redémarrer la kubelet :

```bash
training@master$ sudo systemctl daemon-reload
training@master$ sudo systemctl restart kubelet
```

9. Nous devons maintenant mettre à jour le worker :

```bash
training@worker$ sudo apt-mark unhold kubeadm
training@worker$ sudo apt-get install kubeadm=1.19.3-00
training@worker$ sudo apt-mark hold kubeadm
```

10. Comme pour le master, nous devons drain le noeud worker :

```bash
training@master$ kubectl drain worker --ignore-daemonsets
```

11. Nous devons maintenant mettre a jour la configuration de notre worker :

```bash
training@worker$ sudo kubeadm upgrade node

[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks
[preflight] Skipping prepull. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
```

12. Enfin, comme pour le master nous devons mettre a jour la kubelet et kubectl :

```bash
training@worker$ sudo apt-mark unhold kubectl kubelet
training@worker$ sudo apt-get install kubectl=1.19.3-00 kubelet=1.19.3-00
training@worker$ sudo apt-mark hold kubectl kubelet
```

13. En prenant soin de redémarrer la kubelet :

```bash
training@worker$ sudo systemctl daemon-reload
training@worker$ sudo systemctl restart kubelet
```

14. Sans oublier de remettre le noeud en marche :

```bash
training@master$ kubectl uncordon worker
```

15. Nous pouvons maintenant lister les noeuds :

```bash
training@master$ kubectl get nodes

NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   22m   v1.19.3
worker   Ready    <none>   21m   v1.19.3
```

16. Et lister les pods pour verifier que tout est fonctionnel :

```bash
training@master$ kubectl get pods -A

NAMESPACE     NAME                             READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-jhcg9          1/1     Running   0          7m44s
kube-system   coredns-f9fd979d6-mjfzf          1/1     Running   0          7m44s
kube-system   etcd-master                      1/1     Running   1          11m
kube-system   kube-apiserver-master            1/1     Running   0          11m
kube-system   kube-controller-manager-master   1/1     Running   0          11m
kube-system   kube-proxy-4mvtr                 1/1     Running   0          14m
kube-system   kube-proxy-lkvxn                 1/1     Running   0          13m
kube-system   kube-scheduler-master            1/1     Running   0          11m
kube-system   weave-net-t2h8r                  2/2     Running   0          24m
kube-system   weave-net-zxg6p                  2/2     Running   1          23m
```

> Note : le CNI doit etre mis à jour independemment
