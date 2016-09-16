# Kubernetes

### Kubernetes : Composants

- kubelet : Service "agent" fonctionnant sur tous les nœuds et assure le fonctionnement des autres services

- kube-apiserver : API server qui permet la configuration d'objet Kubernetes (Pods, Service, Replication Controller, etc.)

- kube-proxy : Permet le forwarding TCP/UDP et le load balancing entre les services et les backend (Pods)

- kube-scheduler : Implémente les fonctionnalité de scheduling

- kube-controller-manager : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré

- kubectl : Client qui permet de piloter un cluster Kubernetes

### Kubernetes : Kubelet

- Service principal de Kubernetes

- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de K8s).
    - Applique les modifications si besoin (upgrade, rollback).

- Surveille l'état des services du cluster via l'API server (*kube-apiserver*).

- Dossier de manifest sur un noeud master :
```
ls /etc/kubernetes/manifests/
kube-apiserver.yaml  kube-controller-manager.yaml  kube-proxy.yaml  kube-scheduler.yaml  policy-controller.yaml
```

### Kubernetes : Kubelet

- Exemple du manifest *kube-proxy* :
```
apiVersion: v1
kind: Pod
metadata:
  name: kube-proxy
  namespace: kube-system
  annotations:
    rkt.alpha.kubernetes.io/stage1-name-override: coreos.com/rkt/stage1-fly
spec:
  hostNetwork: true
  containers:
  - name: kube-proxy
    image: quay.io/coreos/hyperkube:v1.3.6_coreos.0
    command:
    - /hyperkube
    - proxy
    - --master=http://127.0.0.1:8080
    - --proxy-mode=iptables
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  volumes:
  - hostPath:
      path: /usr/share/ca-certificates
    name: ssl-certs-host
```

### Kuberntes : kube-apiserver

- Les configuration d'objets (Pods, Service, RC, etc.) se font via l'API server

- Un point d'accès à l'état du cluster aux autres composant via une API REST

- Tous les composant sont reliés à l'API server

### Kubernetes : kube-scheduler

- Planifie les ressources sur le cluster

- En fonction de règles implicites (CPU, RAM, stockage disponible, etc.)

- En fonction de règles explicites (règles d'affinité et anti-affinité, labels, etc.)

### Kubernetes : kube-proxy

- 
- 
- 

### Kubernetes : 

- Ensemble logique composé de un ou plusieurs conteneurs

- Les conteneurs d'un pod fonctionnent ensemble (instanciation et destruction) et sont orchestrés sur un même hôte

- Les conteneurs partagent certaines spécifications du POD :
    - La stack IP (network namespace)
    - Inter-process communication (PID namespace)
    - Volumes

- C'est la plus petite unité orchestrable dans Kubernetes

### Kubernetes : POD

- Les PODs sont définis en YAML comme les fichiers `docker-compose`

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

### Kubernetes : Networking

- Overlay Network nécessaire (idem que ceux utilisables avec Docker) :
    - Flannel
    - Weaves
    - Calico

- Les conteneurs peuvent communiquer sans NAT

- Un nœuds peut accéder aux conteneurs des autres nœuds sans NAT

### Kubernetes : Volumes

- Fournir du stockage persistent aux PODs

- Fonctionnent de la même façon que les volumes Docker pour les volumes hôte :
    - EmptyDir ~= volumes docker
    - HostPath ~= volumes hôte

- Support de multiples backend de stockage :
    - GCE : PD
    - AWS : EBS
    - glusterFS
    - Ceph
    - iSCSI

### Kubernetes : Volumes

- On déclare d'abord le volume et on l'affecte à un service

```
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-persistent-storage
      mountPath: /data/redis
  volumes:
  - name: redis-persistent-storage
    emptyDir: {}
```

### Kubernetes : Labels

- Système de clé/valeur

- Organiser les différents objets de Kubernetes (PODs, RC, Services, etc.) d'une manière cohérente qui reflète la structure de l'application

- Corréler des éléments de Kubernetes : par exemple un service vers des PODs

### Kubernetes : Labels

- Exemple de label

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

### Kubernetes : Replication Controllers

- Permet de manager les PODs de manière homogène (version de PODs, nombres, etc.)

- Gère la durée de vie des PODs :  création et destruction

- Assure qu'un nombre minimum de PODs est présent à l'instant T sur l'infrastructure K8s (scaling)

### Kubernetes : Replication Controllers

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-controller
spec:
  replicas: 2
  selector:
    app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

### Kubernetes : Services

- Abstraction des PODs et RCs, sous forme d'une VIP de service

- Rendre un ensemble de PODs accessibles depuis l'extérieur

- Load Balancing entre les PODs d'un même service

### Kubernetes : Services

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCE

- Node Port forwarding : limitations

- IP Externes : le routage de l'IP publique vers le cluster est manuel

### Kubernetes : Services

- Exemple de service :

```
{
  "kind": "Service",
  "apiVersion": "v1",
  "metadata": {
    "name": "example-service"
  },
  "spec": {
    "ports": [{
      "port": 8765,
      "targetPort": 9376
    }],
    "selector": {
      "app": "example"
    },
    "type": "LoadBalancer"
  }
  }
```

### Kubernetes : Déploiements

- Simplifier les déploiements sous forme de groupes logiques

- Permet de définir un ensemble de PODs ainsi que leurs RCs

- Version, Update et Rollback

- Souvent combiné avec un objet de type *service*

### Kubernetes : Déploiements

```
apiVersion: v1
kind: Service
metadata:
  name: my-nginx-svc
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: nginx
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

### Kubernetes : Run

- WebUI

- Kubectl

- Objets: *Secret* et *ConfigMap* : paramétrages, plus sécurisés que les variables d'environnements

### Kubernetes : Conclusion

- Version 1.3 : stable en production

- Solution complète et une des plus utilisées

- Éprouvée par Google

- S'intègre parfaitement à CoreOS (support de *rkt* en cours) : Tectonic

