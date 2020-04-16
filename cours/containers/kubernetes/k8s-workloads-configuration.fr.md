# Kubernetes : Gestion de la configuration des applications

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

### Kubernetes : ConfigMap environnement

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: ["/bin/sh", "-c", "env"]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: env-config
              key: log_level
  restartPolicy: Never
```

### Kubernetes: ConfigMap volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: ["/bin/sh", "-c", "ls /etc/config/"]
      volumeMounts:
        - name: config-volume
          mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: special-config
  restartPolicy: Never
```

### Kubernetes : Secrets

- Objet Kubernetes de type `secret` utilisé pour stocker des informations sensibles comme les mots de passe, les _tokens_, les clés SSH...
- Similaire à un `ConfigMap`, à la seule différence que le contenu des entrées présentes dans le champ `data` sont encodés en base64.
- Il est possible de directement créer un `Secret` spécifique à l'authentification sur un registre Docker privé.
- Il est possible de directement créer un `Secret` à partir d'un compte utilisateur et d'un mot de passe.

### Kubernets : Secrets

- S'utilisent de la même façon que les ConfigMap
- La seule différence est le stockage en base64
- 3 types de secrets:
  - `Generic`: valeurs arbitraire comme dans une _ConfigMap_
  - `tls`: certificat et clé pour utilisation avec un serveur web
  - `docker-registry`: utilisé en tant que `imagePullSecret` par un pod pour pouvoir pull les images d'une registry privée

### Kubernetes : Secrets

```console
$ kubectl create secret docker-registry mydockerhubsecret \
--docker-username="employeeusername" --docker-password="employeepassword" \
--docker-email="employee.email@organization.com"
```

```console
kubectl create secret generic dev-db-secret --from-literal=username=devuser --from-literal=password='S!B\*d$zDsb'
```

### Kubernetes : Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: 2016-01-22T18:41:56Z
  name: mysecret
  namespace: default
  resourceVersion: "164619"
  uid: cfee02d6-c137-11e5-8d73-42010af00002
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```
