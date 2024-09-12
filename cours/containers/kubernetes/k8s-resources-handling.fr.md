# KUBERNETES : Gestion des Ressources

### Pods resources : requests et limits

- Permettent de gérer l'allocation de ressources au sein d'un cluster
- Par défaut, un pod/container sans request/limits est en *best effort*
- Request: allocation minimum garantie (réservation)
- Limit: allocation maximum (limite)
- Se base sur le CPU et la RAM

- Relation entre requests et limits
    - Requests <= Limits: La valeur de la request doit toujours être inférieure ou égale à celle de la limit.
    - Qualité de service (QoS): Les valeurs de requests et limits définissent le niveau de QoS d'un pod (BestEffort, Burstable, Guaranteed).



### QoS

- BestEffort :
    - Pas de limites ni de requests définies: Le pod peut consommer autant de ressources que disponibles, mais il n'a aucune garantie.
    - Conséquences: Le pod peut être évincé à tout moment si les ressources du nœud sont insuffisantes, ce qui peut entraîner des interruptions de service.
- Burstable :
    - Requests définies: Le pod a une garantie minimale de ressources (requests).
    - Pas de limites strictes: Le pod peut dépasser ses requests si les ressources sont disponibles, mais il peut être évincé si d'autres pods Guaranteed ont besoin de ressources.
    - Conséquences: Le pod bénéficie d'une certaine priorité, mais il peut être impacté par les besoins des pods Guaranteed.
- Guaranteed :
    - Requests et limites définies: Le pod a une garantie minimale de ressources (requests) et une limite maximale (limits).
    - Priorité élevée: Le pod a la plus haute priorité et ne peut pas être évincé tant qu'il respecte ses limites.
    - Conséquences: Le pod bénéficie d'une garantie de ressources stable, ce qui est idéal pour les applications critiques.

Exemple concret :

Un nœud Kubernetes avec 4 cœurs CPU.

    - Pod BestEffort: Il peut utiliser 0, 1, 2, 3 ou 4 cœurs, selon la disponibilité.
    - Pod Burstable (requests: 2 cœurs, pas de limits): Il est garanti d'avoir au moins 2 cœurs, mais il peut en utiliser jusqu'à 4 s'ils sont disponibles. Si un pod Guaranteed a besoin de 2 cœurs, le pod Burstable peut en perdre 2.
    - Pod Guaranteed (requests: 2 cœurs, limits: 2 cœurs): Il a toujours 2 cœurs garantis et ne peut pas en utiliser plus.


### Pods resources : CPU

- 1 CPU est globalement équivalent à un cœur
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

### Pods resources : requests et limits

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

- l'objet `LimitRange` permet de définir les valeurs minimales et maximales des ressources utilisées par les containers et les pods pour les requests et limits de CPU, de mémoire et de stockage
- l'objet `LimitRange` s'applique au niveau du `namespace`
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
- il permet aussi de limiter le nombre de `pods`, `PVC`, réplicas, services et autres objets qui peuvent être créés dans un `namespace`

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


