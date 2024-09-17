# KUBERNETES : Concepts et Objets

### Kubernetes : Core API Resources

- Namespaces
- Labels
- Annotations
- Pods
- Deployments
- DaemonSets
- Jobs
- Cronjobs
- Services

### Kubernetes : `Namespaces`

- Fournissent une séparation logique des ressources :
    - Par utilisateurs
    - Par projet / applications
    - Autres...
- Les objets existent uniquement au sein d'un namespace donné
- Évitent la collision de nom d'objets
- Font partie du fqdn du service (DNS) (mon-service.mon-namespace.svc.cluster.local)
- Quotas et limites: Vous pouvez définir des quotas et des limites sur les ressources (CPU, mémoire, nombre de pods, etc.) au niveau du namespace pour contrôler l'utilisation des ressources.
- Défaut: Le namespace `default` existe par défaut dans chaque cluster Kubernetes.


### Kubernetes : `Labels`

- Système de clé/valeur
- Organisent, filtrent, selectionnent les différents objets de Kubernetes (Pods, RC, Services, etc.) d'une manière cohérente qui reflète la structure de l'application
- Corrèlent des éléments de Kubernetes : par exemple un service vers des Pods
- Ils contiennent des informations d'identification utilisées par les requêtes qui utilisent un sélecteur ou dans les sections de sélecteurs dans les définitions d'objets
- Le nom dans la clé est limité à 63 caractères et le suffixe à 253 caractères
- La valeur ne peut dépasser 63 caractères
- La valeur doit commencer un aplhanum ou être vide
- La valeur peut contenir des `~` `.` et `alphanum`
- Arbitraires: Vous pouvez définir n'importe quelle paire clé-valeur.
- Immuables: Une fois créés, les labels ne peuvent pas être modifiés directement. Pour les changer, il faut créer un nouveau déploiement ou un nouveau pod.
- Multiples: Un objet peut avoir plusieurs labels.


### Kubernetes : `Labels`

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

### Kubernetes : `Labels`

- La commande `kubectl get pods`, par défaut, ne liste pas les labels. 
  
- Il est possible de les voir en utilisant `--show-labels`:

```console
$ kubectl get pods --show-labels
NAME      READY     STATUS    RESTARTS   AGE       LABELS
nginx     1/1       Running   0          31s       app=nginx,env=prod
```


- Lister des ressources par l'utilisation de labels

```console

kubectl get po -A -l k8s-app=kube-dns
# ou 
kubectl get pods --selector=k8s-app=dns

kubectl get po -A -l k8s-app=kube-dns -l pod-template-hash=6d4b75cb6d
# equivalent
kubectl get po -A -l k8s-app=kube-dns,pod-template-hash=6d4b75cb6d
# ou
kubectl get po -A --selector=8s-app=kube-dns,pod-template-hash=6d4b75cb6d

# Lister les valeurs d'un label 
kubectl get pods -L k8s-app

# Lister to les labels d'un object

kubectl get deploy --show-labels
kubectl get deploy,po --show-labels

# Utiliser la forme négative

kubectl get po -A -l k8s-app!=kube-dns

```

### Kubernetes : `Annotations`

- Système de clé/valeur
- Ce sont des informations qui ne sont pas utilisées pour l'identification de ressources.
- Les annotations ne sont pas utilisées en interne par kubernetes
- Stockage de données personnalisées: Pour stocker des informations spécifiques à votre application ou à votre infrastructure.
- Elles peuvent être utilisées par des outils externes ou librairies (ex: cert-manager, ingress-controller...)
- Le nom dans la clé est limitée à 63 caractères et le suffixe à 253 caractères
- Arbitraires: Vous pouvez définir n'importe quelle paire clé-valeur.
- Mutables: Les annotations peuvent être modifiées après la création de l'objet.
- Multiples: Un objet peut avoir plusieurs annotations.

### Kubernetes : `Annotations`

- exemple d'annotation

```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: theClusterIssuer
    kubernetes.io/tls-acme: "true"
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
```

### Kubernetes : `Pod`

- Un Pod n'est pas un processus, c'est un environnement pour les containers
    - Un pod ne peut pas être redémarré
    - Il ne peut pas se "planter", les containers d'un pod "oui"
- C'est, donc, Ensemble logique composé de un ou plusieurs conteneurs
- Les conteneurs d'un pod fonctionnent ensemble (instanciation et destruction) et sont orchestrés sur un même hôte
- Les conteneurs partagent certaines spécifications du Pod :
    - La stack IP (network namespace)
    - Inter-process communication (PID namespace)
    - Volumes
    - IP: Le pod lui-même dispose d'une adresse IP unique, que tous les conteneurs du pod peuvent utiliser.
    - Cycle de vie: Les conteneurs d'un pod sont créés et détruits en même temps
    - Node: Tous les conteneurs d'un pod sont généralement co-localisés sur le même nœud du cluster Kubernetes.
- C'est la plus petite et la plus simple unité dans Kubernetes

En savoir plus : <https://kubernetes.io/fr/docs/concepts/workloads/pods/pod/>



### Kubernetes : `Pod`

![pods](images/pods.png)

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

### Kubernetes : `Pod`

Dans les statuts du pod on trouve la notion de phase d'exécution

- Phases :
    - `Pending`: accepté par le cluster, les container ne sont pas initialisé
    - `Running`: Au moins un des containers est en cours de démarrage, d'exécution ou de redémarrage
    - `Succeeded`: Tous les containers se sont arrêtés avec un "exit code" à 0 (zéro); Le pod ne sera pas redémarré
    - `Failed`: Tous les containers se sont arrêtés et au moins un a un exit code différent de 0
    - `Unknown`: L'état du pod ne peut pas être déterminé


```console
$ kubectl get pods -o wide
```

en sortie :

```console
NAME                  READY   STATUS    RESTARTS   AGE   IP           NODE      
xx-79c5968bdc-6lcfq   1/1     Running   0          84m   10.244.0.6   kind-cp   
yy-ss7nk              1/1     Running   0          84m   10.244.0.5   kind-cp

```

### Kubernetes : `Pod`

dans les statuts du pod on trouve la notion de Conditions d'état des pods

- Conditions :
    - `PodScheduled`: Un nœud a été sélectionné avec succès pour "lancer" le pod, et la planification est terminée.
    - `ContainersReady`: Tous les containers sont prêts
    - `Initialized`: Les "Init containers sont démarrés"
    - `Ready`: Le pod est capable de répondre aux demandes ; par conséquent, il doit être inclus dans le service et les répartiteurs de charge.

```console
$ kubectl describe pods <POD_NAME>
```

en sortie

```console
...
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
...
```

### Kubernetes : `Pod`

États des containers (States)

Les containers peuvent avoir seulement 3 états

- États:
    - `Waiting`: Les processus requis sont en cours d'exécution pour un démarrage réussi
    - `Running`: Le container est en cours d'exécution
    - `Terminated`: L'exécution du conteneur s'est déroulée et s'est terminée par un succès ou un échec.


```console
$ kubectl get pods <POD_NAME> -o jsonpath='{.status}' | jq
```

### Kubernetes : `Deployment`

- Permet d'assurer le fonctionnement d'un ensemble de Pods
- Gère les Version, Update et Rollback
- Il est lié avec l'object ReplicaSet qui gère le cycle de vie et la mise à l'échelle des pods
- Souvent combiné avec un objet de type **service**

![deployment](images/deployment.png)



### Kubernetes : `Deployment`

```plaintext
+--------------------+
| Deployment         |
|                    |
| Name: my-deployment|
| Selector: app=web  |
+--------------------+
          |
          | matches
          v
+--------------------+
| ReplicaSet         |
|                    |
| Selector: app=nginx|
+--------------------+
          |
          | matches
          v
+--------------------+
| Pod                |
|                    |
| Labels: app=nginx  |
+--------------------+
```



### Kubernetes : `Deployment`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
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

ou en ligne de commande

```console
kubectl create deployment my-deployment --image=nginx:latest --replicas=3
```


### Kubernetes : `DaemonSet`

- Assure que tous les noeuds exécutent une copie du pod sur tous les noeuds du cluster
- Ne connaît pas la notion de `replicas`.
- Utilisé pour des besoins particuliers comme :
    - l'exécution d'agents de collection de logs comme `fluentd` ou `logstash`
    - l'exécution de pilotes pour du matériel comme `nvidia-plugin`
    - l'exécution d'agents de supervision comme NewRelic agent, Prometheus node exporter
  

### Kubernetes : `DaemonSet`

![daemonset](images/daemonset.png)

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

### Kubernetes : `StatefulSet`

- Similaire au `Deployment` mais les noms des composants sont prédictibles
- Les pods possèdent des identifiants uniques.
- Chaque replica de pod est créé par ordre d'index
- Nécessite un `Persistent Volume` et un `Storage Class`.
- Supprimer un StatefulSet ne supprime pas le PV associé


![statefulset](images/statefulset.png){width="500"}


### Kubernetes : `StatefulSet`

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

```console
kubectl get po
NAME    READY   STATUS              RESTARTS   AGE
web-0   0/1     ContainerCreating   0          3s
❯ kubectl get po
NAME    READY   STATUS              RESTARTS   AGE
web-0   1/1     Running             0          9s
web-1   0/1     ContainerCreating   0          1s
❯ kubectl get po
NAME    READY   STATUS              RESTARTS   AGE
web-0   1/1     Running             0          12s
web-1   1/1     Running             0          4s
web-2   0/1     ContainerCreating   0          2s
❯ kubectl get po
NAME    READY   STATUS    RESTARTS   AGE
web-0   1/1     Running   0          15s
web-1   1/1     Running   0          7s
web-2   1/1     Running   0          5s
```

### Kubernetes : `StatefulSet` avancé

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
    app.kubernetes.io/name: mysql
data:
  primary.cnf: |
    [mysqld]
    log-bin    
  replica.cnf: |
    [mysqld]
    super-read-only    

---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
      app.kubernetes.io/name: mysql
  serviceName: mysql
  replicas: 3
  template:
    metadata:
      labels:
        app: mysql
        app.kubernetes.io/name: mysql
    spec:
      initContainers:
      - name: init-mysql
        image: mysql:5.7
        command:
        - bash
        - "-c"
        - |
          set -ex
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          echo [mysqld] > /mnt/conf.d/server-id.cnf
          echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
          if [[ $ordinal -eq 0 ]]; then
            cp /mnt/config-map/primary.cnf /mnt/conf.d/
          else
            cp /mnt/config-map/replica.cnf /mnt/conf.d/
          fi          
        ....
      - name: clone-mysql
        image: gcr.io/google-samples/xtrabackup:1.0
        command:
        - bash
        - "-c"
        - |
          set -ex
          [[ -d /var/lib/mysql/mysql ]] && exit 0
          # Skip the clone on primary (ordinal index 0).
          [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
          ordinal=${BASH_REMATCH[1]}
          [[ $ordinal -eq 0 ]] && exit 0
          ncat --recv-only mysql-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql
        ...
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ...
```

### Kubernetes : `Job`

- Crée des pods et s'assurent qu'un certain nombre d'entre eux se terminent avec succès.
- Peut exécuter plusieurs pods en parallèle
- Si un noeud du cluster est en panne, les pods sont reschedulés vers un autre noeud.
  

![job](images/job.png)

### Kubernetes : `Job`

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

En ligne de commande :


```console
kubectl create job exemple-job --image=busybox -- /bin/sh -c "date; echo Hello from the Kubernetes cluster"
```

### Kubernetes: `CronJob`

- Un CronJob permet de lancer des Jobs de manière planifiée.
- la programmation des Jobs se définit au format `Cron`
- le champ `jobTemplate` contient la définition de l'application à lancer comme `Job`.

![cronjob](images/cronjob.png)

### Kubernetes : `CronJob`

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: batch-job-every-fifteen-minutes
spec:
  schedule: '0,15,30,45 * * * *'
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: periodic-batch-job
        spec:
          restartPolicy: OnFailure
          containers:
            - name: pi
              image: perl
              command:
                - perl
                - '-Mbignum=bpi'
                - '-wle'
                - print bpi(2000)

```

En ligne de commande :

```console
kubectl create cronjob exemple-cronjob --image=busybox --schedule="*/5 * * * *" -- /bin/sh -c "date; echo Hello from the Kubernetes cluster"
```

Susprendre un cronjob :

```console
kubectl patch cronjob <cronjob-name> -p '{"spec" : {"suspend" : true }}'
```

Reprendre l'exécution :


```console
kubectl patch cronjob <cronjob-name> -p '{"spec" : {"suspend" : false }}'
```

   


### Extras : `Init Containers`

- On peut définir des conteneurs qui doivent s'exécuter avant les conteneurs principaux
- Ils seront exécutés dans l'ordre
    (au lieu d'être exécutés en parallèle)
- ⚠️ Ils doivent tous réussir avant que les conteneurs principaux ne soient démarrés


exemple :



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app.kubernetes.io/name: MyApp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]

```

### Extras : `Init Containers`


- Lors du démarrage d'un Pod, le kubelet retarde l'exécution des conteneurs d'initialisation jusqu'à ce que le réseau et le stockage soient prêts. Ensuite, le kubelet exécute les conteneurs d'initialisation du Pod dans l'ordre où ils apparaissent dans la spécification du Pod.
- Chaque conteneur d'initialisation doit se terminer avec succès avant que le suivant ne démarre. 
- Si un conteneur ne parvient pas à démarrer en raison de l'environnement d'exécution ou se termine avec un échec, il est relancé conformément à la **restartPolicy** du Pod. Cependant, si la **restartPolicy** du Pod est définie sur **Always**, les conteneurs d'initialisation utilisent la restartPolicy OnFailure.
- Un Pod ne peut pas être **Ready** tant que tous les conteneurs d'initialisation n'ont pas réussi. Les ports d'un conteneur d'initialisation ne sont pas agrégés sous un Service. 
- Un Pod en cours d'initialisation est dans l'état **Pending** mais doit avoir une condition **Initialized** définie à false.
- Si le Pod redémarre, ou est redémarré, tous les conteneurs d'initialisation doivent s'exécuter à nouveau.

- Utilisations possibles
    - Charger/préparer des données (code, data, configuration,...)
    - Organiser les update (migrations) de bases de données
    - Attendre que certains services soient démarrés (bonne alternative à des sondes)
    - ...
     
     




