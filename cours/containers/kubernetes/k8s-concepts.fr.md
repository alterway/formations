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

### Kubernetes : Services {-}

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

### Kubernetes : Namespaces

- Fournissent une séparation logique des ressources par exemple :
    - Par utilisateurs
    - Par projet / applications
    - Autres...

- Les objets existent uniquement au sein d'un namespace donné

- Évitent la collision de nom d'objets