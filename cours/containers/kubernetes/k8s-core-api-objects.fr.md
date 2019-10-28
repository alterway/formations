# Kubernetes : Concepts et Objets

### Kubernetes : API Resources

- Namespaces
- Pods
- Deployments
- DaemonSets
- Jobs
- Cronjobs

### Kubernetes : Namespaces

- Fournissent une séparation logique des ressources par exemple :
    - Par utilisateurs
    - Par projet / applications
    - Autres...
- Les objets existent uniquement au sein d'un namespace donné
- Évitent la collision de nom d'objets


### Kubernetes : Labels

- La commande `kubectl get pods`, par défaut, ne liste pas les labels. Il est possible de les voir en utilisant `--show-labels`:

```console
$ kubectl get pods --show-labels
NAME      READY     STATUS    RESTARTS   AGE       LABELS
nginx     1/1       Running   0          31s       app=nginx,env=prod
```

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

### Kubernetes : DaemonSet

- Assure que tous les noeuds exécutent une copie du pod sur tous les noeuds du cluster
- Ne connaît pas la notion de `replicas`.
- Utilisé pour des besoins particuliers comme :
    - l'exécution d'agents de collection de logs comme `fluentd` ou `logstash`
    - l'exécution de pilotes pour du matériel comme `nvidia-plugin`
    - l'exécution d'agents de supervision comme NewRelic agent, Prometheus node exporter

### Kubernetes : DaemonSet

```yaml
apiVersion: apps/v1
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

### Kubernetes : Job

- Crée des pods et s'assurent qu'un certain nombre d'entre eux se terminent avec succès.
- Peut éxécuter plusieurs pods en parallèle
- Si un noeud du cluster est en panne, les pods sont reschedulés vers un autre noeud.

### Kubernetes : Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  parallelism: 1
  completions: 1
  template:
    metadata:
      name: pi
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: OnFailure
```

### Kubernetes: Cron Job

- Un CronJob permet de lancer des Jobs de manière planifiée.
- la programmation des Jobs se définit au format `Cron`
- le champ `jobTemplate` contient la définition de l'application à lancer comme `Job`.

### Kubernetes : CronJob

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
    name: batch-job-every-fifteen-minutes
spec:
    schedule: "0,15,30,45 * * * *"
    jobTemplate:
        spec:
            template:
                metadata:
                    labels:
                        app: periodic-batch-job
                spec:
                    restartPolicy: OnFailure
                    containers:
                    -  name: pi
                       image: perl
                       command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
```
