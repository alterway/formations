# Kubernetes : Concepts et Objets

### Kubernetes : API Resources

- Pods
- Deployments
- DaemonSets
- Services
- Namespaces
- Ingress
- NetworkPolicy
- Volumes

### Kubernetes : Pod

- Ensemble logique composé de un ou plusieurs conteneurs
- Les conteneurs d'un pod fonctionnent ensemble (instanciation et destruction) et sont orchestrés sur un même hôte
- Les conteneurs partagent certaines spécifications du Pod :
    - La stack IP (network namespace)
    - Inter-process communication (PID namespace)
    - Volumes
- C'est la plus petite et la plus simple unité dans Kubernetes

### Kubernetes : Pod

- Les Pods sont définis en YAML comme les fichiers `docker-compose` :

```yaml
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

```yaml
apiVersion: apps/v1
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
        image: nginx:stable
        ports:
        - containerPort: 80
```


### Kubernetes : Services

- Abstraction des Pods et Replication Controllers, sous forme d'une VIP de service
- Rendre un ensemble de Pods accessibles depuis l'extérieur
- Load Balancing entre les Pods d'un même service

### Kubernetes : Services

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCP
    - Azure Kubernetes Service
    - OpenStack
- `NodePort` : chaque noeud du cluster ouvre un port  statique et redirige le trafic vers le port indiqué
- `ClusterIP` : IP dans le réseau privé Kubernetes (VIP)
- `LoadBalancer` :  expose le service à l'externe en utilisant le loadbalancer d'un cloud provider (AWS, Google, Azure)
- `ExternalIP`: le routage de l'IP publique vers le cluster est manuel



### Kubernetes : Services

![](images/services.png)


### Kubernetes : Services

- Exemple de service (on remarque la sélection sur le label et le mode d'exposition):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  type: NodePort
  ports:
  - port: 80
  selector:
    app: guestbook
    tier: frontend
```

### Kubernetes : Services

Il est aussi possible de mapper un service avec un nom de domaine en spécifiant le paramètre `spec.externalName`.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```


### Kubernetes: Ingress

- L'objet `Ingress` permet d'exposer un service à l'extérieur d'un cluster Kubernetes
- Il permet de fournir une URL visible permettant d'accéder un Service Kubernetes
- Il permet d'avoir des terminations TLS, de faire du _Load Balancing_, etc...
- Pour utiliser un `Ingress`, il faut un controlleur Ingress. Il existe plusieurs offres sur le marché:
    - Nginx Controller : <https://github.com/kubernetes/ingress-nginx>
    - Traefik : <https://github.com/containous/traefik>
    - Istio: <https://github.com/istio/istio>
    - Linkerd: <https://github.com/linkerd/linkerd>
    - Contour: <https://www.github.com/heptio/contour/>


### Kubernetes : Ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: osones
spec:
  rules:
  - host: blog.osones.com
    http:
      paths:
      - path: /
        backend:
          serviceName: osones-nodeport
          servicePort: 80
```

### Kubernetes : Ingress Controller

Pour utiliser un `Ingress`, il faut un Ingress Controller. Il existe plusieurs offres sur le marché :

  - Traefik : <https://github.com/containous/traefik>
  - Istio : <https://github.com/istio/istio>
  - Linkerd : <https://github.com/linkerd/linkerd>
  - Contour : <https://www.github.com/heptio/contour/>
  - Nginx Controller : <https://github.com/kubernetes/ingress-nginx>


### Kubernetes : DaemonSet

- Assure que tous les noeuds exécutent une copie du pod sur tous les noeuds du cluster
- Ne connaît pas la notion de `replicas`.
- Utilisé pour des besoins particuliers comme:
  * l'exécution d'agents de collection de logs comme `fluentd` ou `logstash`
  * l'exécution de pilotes pour du matériel comme `nvidia-plugin`
  * l'exécution d'agents de supervision comme NewRelic agent, Prometheus node exporter

  NB : kubectl ne peut pas créer de DaemonSet


### Kubernetes : DaemonSet

```yaml
apiVersion: apps/v1beta2
kind: DaemonSet
metadata:
  name: ssd-monitor
  spec:
  selector:
    matchLabels:
      app: ssd-monitor
  template:
    metadata:
      labels:
        app: ssd-monitor
  spec:
    nodeSelector:
    disk: ssd
    containers:
    - name: main
      image: luksa/ssd-monitor
```


### Kubernetes : StatefulSet

- Similaire au `Deployment`
- Les pods possèdent des identifiants uniques.
- Chaque replica de pod est créé par ordre d'index
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
      app: nginx
  serviceName: "nginx"
  replicas: 3
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


### Kubernetes : Labels

- Système de clé/valeur
- Organiser les différents objets de Kubernetes (Pods, RC, Services, etc.) d'une manière cohérente qui reflète la structure de l'application
- Corréler des éléments de Kubernetes : par exemple un service vers des Pods


### Kubernetes : Labels

- Exemple de label :

```yaml
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

### Kubernetes : Labels

- La commande `kubectl get pods`, par défaut, ne liste pas les labels. Il est possible de les voir en utilisant `--show-labels`:

```console
$ kubectl get pods --show-labels
NAME      READY     STATUS    RESTARTS   AGE       LABELS
nginx     1/1       Running   0          31s       app=nginx,env=prod
```

### Kubernetes : Namespaces

- Fournissent une séparation logique des ressources par exemple :
    - Par utilisateurs
    - Par projet / applications
    - Autres...
- Les objets existent uniquement au sein d'un namespace donné
- Évitent la collision de nom d'objets

