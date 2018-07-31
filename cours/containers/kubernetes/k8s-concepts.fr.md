# Kubernetes : Concepts et Objets  {-}

### Kubernetes : API Resources

- Pods

- Deployments

- DaemonSets

- Services

- Namespaces

- Ingress

- NetworkPolicy

- Volumes

### Kubernetes : POD

- Ensemble logique composé de un ou plusieurs conteneurs

- Les conteneurs d'un pod fonctionnent ensemble (instanciation et destruction) et sont orchestrés sur un même hôte

- Les conteneurs partagent certaines spécifications du Pod :
    - La stack IP (network namespace)
    - Inter-process communication (PID namespace)
    - Volumes

- C'est la plus petite unité orchestrable dans Kubernetes

### Kubernetes : POD

- Les Pods sont définis en YAML comme les fichiers `docker-compose` :

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

### Kubernetes : Deployment

- Permet d'assurer le fonctionnement d'un ensemble de Pods

- Version, Update et Rollback

- Souvent combiné avec un objet de type *service*

### Kubernetes : Deployment

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

### Kubernetes : DaemonSet

- assure que tous les noeuds exécutent une copie du pod. 

- utilisé pour des besoins particuliers comme:
  * l'exécution d'agents de collection de logs comme `fluentd` ou `logstash`
  * l'exécution de pilotes pour du matériel comme `nvidia-plugin`
  * l'exécution d'agents de supervision comme NewRelic agent, Prometheus node exporter

  P.S.: kubectl ne peut pas créer de DaemonSet

### Kubernetes : DaemonSet

```yaml

apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: newrelic-infra-agent
  labels:
    tier: monitoring
    app: newrelic-infra-agent
    version: v1
spec:
  template:
    metadata:
      labels:
        name: newrelic
    spec:
      # Filter to specific nodes:
      # nodeSelector:
      #  app: newrelic
      hostPID: true
      hostIPC: true
      hostNetwork: true
      containers:
        - resources:
            requests:
              cpu: 0.15
          securityContext:
            privileged: true
          image: newrelic/infrastructure
          name: newrelic
          command: [ "bash", "-c", "source /etc/kube-nr-infra/config && /usr/bin/newrelic-infra" ]
          volumeMounts:
            - name: newrelic-config
              mountPath: /etc/kube-nr-infra
              readOnly: true
            - name: dev
              mountPath: /dev
            - name: run
              mountPath: /var/run/docker.sock
            - name: log
              mountPath: /var/log
            - name: host-root
              mountPath: /host
              readOnly: true
      volumes:
        - name: newrelic-config
          secret:
            secretName: newrelic-config
        - name: dev
          hostPath:
              path: /dev
        - name: run
          hostPath:
              path: /var/run/docker.sock
        - name: log
          hostPath:
              path: /var/log
        - name: host-root
          hostPath:
              path: /
```

### Kubernetes : StatefulSet

Similaire au `Deployment`

- Les pods possèdent des identifiants uniques.

- chaque replica de pod est créé par ordre d'index

- Nécessite un `Persistent Volume` et un `Storage Class`.

- Supprimer un StatefulSet ne supprime pas le PV associé


### Kubernetes : StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 3 # by default is 1
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.27
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-storage-class"
      resources:
        requests:
          storage: 1Gi
```

### Kubernetes : Labels

- Système de clé/valeur

- Organiser les différents objets de Kubernetes (Pods, RC, Services, etc.) d'une manière cohérente qui reflète la structure de l'application

- Corréler des éléments de Kubernetes : par exemple un service vers des Pods

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

### Kubernetes : Storage Class

- permet de définir les différents types de stockage disponibles

- utilisé par les `Persistent Volumes` pour solliciter un espace de stockage au travers des `Persistent Volume Claims`

- 

### Kubernetes : Storage Class

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: slow
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  zones: us-east-1d, us-east-1c
  iopsPerGB: "10"
```

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
    - [Træfik](https://traefik.io/)
    - [nginx](https://github.com/kubernetes/ingress-nginx)
    - [Contour](https://github.com/heptio/contour/)
    - [more](https://github.com/mhausenblas/cn-ref#ingress-and-gateways)


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