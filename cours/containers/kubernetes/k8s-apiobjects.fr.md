# Kubernetes : Autres objets de l'API

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

### Kubernetes : ConfigMaps

- Objet Kubernetes permettant stocker séparer les fichiers de configuration
- Il peut être créé d'un ensemble de valeurs ou d'un fichier resource Kubernetes (YAML ou JSON)
- Un `ConfigMap` peut sollicité par plusieurs `pods`


### Kubernetes : ConfigMaps

```yaml
apiVersion: v1
data:
    redis-config: |
      maxmemory 2mb
      maxmemory-policy allkeys-lru
kind: ConfigMap
metadata:
  name: redis-config
  namespace: default
```

### Kubernetes : Secrets

- Objet Kubernetes de type `secret` utilisé pour stocker des informations sensibles comme les mots de passe, les _tokens_, les clés SSH...
- Similaire à un `ConfigMap`, à la seule différence que le contenu des entrées présentes dans le champ `data` sont encodés en base64.
- Il est possible de directement créer un `Secret` spécifique à l'authentification sur un registre Docker privé.
- Il est possible de directement créer un `Secret` à partir d'un compte utilisateur et d'un mot de passe.


### Kubernetes : Secrets

```console
$ kubectl create secret docker-registry mydockerhubsecret \
--docker-username="employeeusername" --docker-password="employeepassword" \
--docker-email="employee.email@organization.com"
```


### Kubernets : Secrets

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-pod
  spec:
  imagePullSecrets:
  - name: mydockersecret
  containers:
  - image: privateregistry/privateimage:tag
    name: main
```

