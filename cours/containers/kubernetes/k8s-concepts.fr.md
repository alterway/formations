# Kubernetes : Concepts et Objets

### Kubernetes : Concepts

- Networking

- Volumes

- Cloud Providers : Load Balancer

### Kubernetes : API Resources

- PODs

- Deployments

- Ingress et Ingress controller

- NetworkPolicy

- Namespaces

- Services

### Kubernetes : POD

- Ensemble logique composé de un ou plusieurs conteneurs

- Les conteneurs d'un pod fonctionnent ensemble (instanciation et destruction) et sont orchestrés sur un même hôte

- Les conteneurs partagent certaines spécifications du POD :
    - La stack IP (network namespace)
    - Inter-process communication (PID namespace)
    - Volumes

- C'est la plus petite unité orchestrable dans Kubernetes

### Kubernetes : POD

- Les PODs sont définis en YAML comme les fichiers `docker-compose` :

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

- Les conteneurs peuvent communiquer sans NAT

- Un nœud peut accéder aux conteneurs des autres nœuds sans NAT

- Nécessite une solution tierce :
    - Canal : Flannel + Calico
    - Weaves
    - OpenShift
    - OpenContrail
    - Romana

- Ces solutions implémentent [CNI](https://github.com/containernetworking/cni) (Container Network Interface)

### Kubernetes : CNI

- Projet de la CNCF

- Spécifications sur la configuration d'interfaces réseaux des conteneurs

- Ensemble de plugins [core](https://github.com/containernetworking/plugins/releases) ainsi que [tierce partie](https://github.com/containernetworking/cni#3rd-party-plugins)

- Docker n'utilise pas CNI mais [CNM](https://github.com/docker/libnetwork/blob/master/docs/design.md) (Containter Network Model) et son implémentation _libnetwork_.

### Kubernetes : Volumes

- Fournir du stockage persistent aux PODs

- Fonctionnent de la même façon que les volumes Docker pour les volumes hôte :
    - EmptyDir ~= volumes docker
    - HostPath ~= volumes hôte

- Support de multiples backend de stockage :
    - GCE : PD
    - AWS : EBS
    - glusterFS / NFS
    - Ceph
    - iSCSI

### Kubernetes : Volumes

- On déclare d'abord le volume et on l'affecte à un service :

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

### Kubernetes : Namespaces

- Fournissent une séparation logique des ressources par exemple :
    - Par utilisateurs
    - Par projet / applications
    - Autres...

- Les objets existent uniquement au sein d'un namespace donné

- Évitent la collision de nom d'objets

### Kubernetes : Labels

- Système de clé/valeur

- Organiser les différents objets de Kubernetes (PODs, RC, Services, etc.) d'une manière cohérente qui reflète la structure de l'application

- Corréler des éléments de Kubernetes : par exemple un service vers des PODs

### Kubernetes : Labels

- Exemple de label :

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

### Kubernetes : Services

- Abstraction des PODs et Replication Controllers, sous forme d'une VIP de service

- Rendre un ensemble de PODs accessibles depuis l'extérieur

- Load Balancing entre les PODs d'un même service

### Kubernetes : Services

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCE

- Node Port forwarding : limitations

- ClusterIP : IP dans le réseau privé Kubernetes (VIP)

- IP Externes : le routage de l'IP publique vers le cluster est manuel

### Kubernetes : Services

- Exemple de service (on remarque la sélection sur le label):

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

### Kubernetes : Deployments

- Permet d'assurer le fonctionnement d'un ensemble de PODs

- Version, Update et Rollback

- Souvent combiné avec un objet de type *service*

### Kubernetes : Deployments

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

### Kubernetes : Ingress Resource

- Définition de règles de routage applicatives (HTTP/HTTPS)

- Traffic load balancing, SSL termination, name based virtual hosting

- Définies dans l'API et ensuite implémentées par un Ingress Controller

```
            internet    |   internet
                |       |       |
          ------------  |  [ Ingress ]
          [ Services ]  |  --|-----|--
                        |  [ Services ]
```

### Kubernetes : Ingress Resource

- Exemple :

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: default
  name: traefik
  annotations:
    kubernetes.io/ingress.class: "traefik"
spec:
  rules:
    - host: traefik.archifleks.net
      http:
        paths:
          - backend:
              serviceName: traefik-console
              servicePort: 8080
```

### Kubernetes : Ingress Controller

- Routeur applicatif de bordure (L7 Load Balancer)

- Implémente les Ingress Resources

- Plusieurs implémentations :
    - [Træfɪk](https://traefik.io/)
    - [nginx](https://github.com/kubernetes/contrib/tree/master/ingress/controllers)

### Kubernetes : NetworkPolicy

- Contrôle la communication entre les PODs au sein d'un namespace

- Pare-feu entre les éléments composant une application :

```
apiVersion: extensions/v1beta1
kind: NetworkPolicy
metadata:
 name: test-network-policy
 namespace: default
spec:
 podSelector:
  matchLabels:
    role: db
 ingress:
  - from:
     - namespaceSelector:
        matchLabels:
         project: myproject
     - podSelector:
        matchLabels:
         role: frontend
    ports:
     - protocol: tcp
       port: 6379
```

### Kubernetes : Run et administration

- WebUI (Kubernetes Dashboard)

- Kubectl (Outil CLI)

- Objets: *Secret* et *ConfigMap* : paramétrages, plus sécurisés que les variables d'environnements

### Kubernetes : Aujourd'hui

- Version 1.11 : stable en production

- Solution complète et une des plus utilisées

- Éprouvée par Google

- S'intègre parfaitement à CoreOS (support de *rkt* et Tectonic, la solution commerciale) et Atomic