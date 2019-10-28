# Kubernetes : Gestion des ressources

### Pods resources : request et limits

- Permettent de gérer l'allocation de ressources au sein d'un cluster
- Par défaut, un pod/container sans request/limits est en *best effort*
- Request: allocation minimum garantie (réservation)
- Limit: allocation maximum (limite)
- Se base sur le CPU et la RAM

### Pods resources : CPU

- 1 CPU est globalement équivalent à un cœurs
- L'allocation se fait par fraction de CPU:
  - `1` : 1 vCPU entier
  - `100m` : 0.1 vCPU
  - `0.5` : 1/2 vCPU
- Lorsqu'un conteneur atteint la limite CPU, celui ci est *throttled*

### Pods resources : RAM

- L'allocation se fait en unité de RAM:
  - `M` : en base 10
  - `Mi` : en base 2
- Lorsqu'un conteneur atteint la limite RAM, celui ci est *OOMKilled*

### Pods resources : request et limits

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: db
    image: mysql
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: "password"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: wp
    image: wordpress
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### LimitRanges

- l'objet `LimitRange` permet de définir les valeurs minimum et maximum pour les ressources utilisées par les containers et les pods
- l'objet `LimitRange` ne s'applique dans un seul `namespace` mais peut être utilisé pour d'autres `namespaces`
- les limites spécifiées s'appliquent à chaque pod/container créé dans le `namespace`
- le `LimitRange` ne limite pas le nombre total de ressources disponibles dans le namespace

### LimitRanges

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-example
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256 Mi
    type: Container
```

### ResourceQuotas

- un objet `ResourceQuota` limite le total des ressources de calcul consommées par les pods ainsi que
  le total de l'espace de stockage consommé par les `PersistentVolumeClaims` dans un namespace
- il permet aussi de limiter le nombre de `pods`, `PVC` et autres objets qui peuvent être créés dans un `namespace`

### ResourceQuotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cpu-and-ram
spec:
  hard:
    requests.cpu: 400m
    requests.memory: 200Mi
    limits.cpu: 600m
    limits.memory: 500Mi
```

