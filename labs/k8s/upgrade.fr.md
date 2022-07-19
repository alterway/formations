#  Mise a jour d’un cluster

<hr>
Machine : **master**, **worker-0**, **worker-1**
<hr>



Pour commencer, il faut mettre à jour kubeadm :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo apt-mark unhold kubeadm
sudo apt-get install kubeadm=1.21.14-0
sudo apt-mark hold kubeadm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Vérifions la version de kubeadm :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubeadm version

kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.21.14", ...}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nous devons maintenant drain le noeud master afin de pouvoir faire l’upgrade dessus :

`kubectl drain master --ignore-daemonsets`

Nous pouvons avoir un aperçu de l’upgrade de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo kubeadm upgrade plan

_____________________________________________________________________

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT        AVAILABLE
kubelet     3 x v1.21.14     v1.21.14

Upgrade to the latest stable version:

COMPONENT                 CURRENT    AVAILABLE
kube-apiserver            v1.21.14   v1.21.14
kube-controller-manager   v1.21.14   v1.21.14
kube-scheduler            v1.21.14   v1.21.14
kube-proxy                v1.21.14   v1.21.14
CoreDNS                   1.7.0      1.7.0
etcd                      3.4.13-0   3.4.13-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.21.14

Note: Before you can perform this upgrade, you have to update kubeadm to v1.21.14.

_____________________________________________________________________

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Nous pouvons maintenant upgrade les composants du cluster :


`sudo kubeadm upgrade apply v1.21.14`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
...
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.21.14". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nous pouvons remettre le noeud master en marche :


`kubectl uncordon master`

node/master uncordoned

Nous devons maintenant mettre à jour la kubelet et kubectl :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo apt-mark unhold kubectl kubelet
sudo apt-get install kubectl=1.21.14-00 kubelet=1.21.14-00
sudo apt-mark hold kubectl kubelet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enfin nous devons redémarrer la kubelet :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo systemctl daemon-reload
sudo systemctl restart kubelet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nous devons maintenant mettre à jour les workers :

A faire sur les noeud 1 et 2

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
training@worker-0$ sudo apt-mark unhold kubeadm
training@worker-0$ sudo apt-get install kubeadm=1.21.14-00
training@worker-0$ sudo apt-mark hold kubeadm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Comme pour le master, nous devons drain les noeuds workers :

Répéter les actions pour le noeud 2 noeud par noeud (pas en // )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl drain worker-0 --ignore-daemonsets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nous devons maintenant mettre a jour la configuration de notre worker-0 :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
training@worker-0$ sudo kubeadm upgrade node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks
[preflight] Skipping prepull. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enfin, comme pour le master nous devons mettre a jour la kubelet et kubectl :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
training@worker-0$ sudo apt-mark unhold kubectl kubelet
training@worker-0$ sudo apt-get install kubectl=1.21.14-00 kubelet=1.21.14-00
training@worker-0$ sudo apt-mark hold kubectl kubelet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

En prenant soin de redémarrer la kubelet :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
training@worker-0$ sudo systemctl daemon-reload
training@worker-0$ sudo systemctl restart kubelet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sans oublier de remettre le noeud en marche :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl uncordon worker-0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nous pouvons maintenant lister les noeuds :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get nodes

NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   22m   v1.21.14
worker-0   Ready     <none>   21m    v1.20.7
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Et lister les pods pour vérifier que tout est fonctionnel :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -A

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Note** : le CNI doit être mis à jour indépendamment


<hr>
