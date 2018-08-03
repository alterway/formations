### Kubernetes : Minikube

- outil permettant de démarrer rapidement un cluster _1 noeud_ Kubernetes localement pour développer des applications.
- éxecute Kubernetes dans une machine virtuelle
- nécessite des outils de virtualisation (VirtualBox, VMware Fusion, KVM, etc...)
- offre plusieurs version de Kubernetes à éxecuter
- Supporte plusieurs systèmes d'exploitation : Linux, Mac OS, Windows
- Installation : <https://github.com/kubernetes/minikube#Installation>

### Kubernetes : Minikube

- Création d'un cluster Kubernetes

```console
$minikube get-k8s-versions
The following Kubernetes versions are available when using the localkube bootstrapper: 
	- v1.10.0
	- v1.9.4
	- v1.9.0
	- v1.8.0
	- v1.7.5
	- v1.7.4
```

```console
$minikube start --kubernetes-version="v1.11.1"
Starting local Kubernetes v1.11.1 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Downloading kubeadm v1.11.1
Downloading kubelet v1.11.1
Finished Downloading kubeadm v1.11.1
Finished Downloading kubelet v1.11.1
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.
```

### Kubernetes : Minikube

- effectuer un diagnostic basique du cluster

```console
$ kubectl version
Client Version: v1.11.1
Server Version: v1.11.1
```
```console
$kubectl get componentstatuses 
NAME                      STATUS    MESSAGE              ERROR
controller-manager   Healthy      ok                   
scheduler                  Healthy      ok                   
etcd-0                       Healthy      {"health": "true"}
```