### Kubectl : Advanced Usage

- Il est possible de mettre à jour un service sans incident grâce ce qui est appelé le _rolling-update_. 
- Avec les _rolling updates_, les resources qu'expose un objet `Service` se mettent à jour progressivement.
- Seuls les objets `Deployments`, `DaemonSet` et `StatefulSet` support les _rolling updates_.
- Les arguments `maxSurge` et `maxUnavailabe` définissent le rythme du _rolling update_.
- La commande `kubectl rollout` permet de suivre les _rolling updates_ éffectués.

### Kubectl : Advanced Usage

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: frontend
  replicas: 2
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      name: nginx
      labels:
        app: frontend
    spec:
      containers:
        - image: nginx:1.9.1
          name: nginx
```

### Kubectl : Advanced Usage

```console
$ kubectl create -f nginx.yaml --record
deployment.apps/nginx created
```

### Kubectl : Advanced Usage

- Il est possible d'augmenter le nombre de pods avec la commande `kubectl scale` :
`kubectl scale --replicas=5 deployment nginx`

- Il est possible de changer l'image d'un container utilisée par un _Deployment_ : 
`kubectl set image deployment nginx nginx=nginx:1.15`

### Kubectl : Logging

### Monitoring

### LimitRanges

- L'objet `LimitRange` permet de définir les valeurs minimum et maximum pour les ressources utilisées par les containers et les pods
- L'objet `LimitRange` ne s'applique dans un seul `namespace` mais peut être utilisé pour d'autres `namespaces`
- Les limites spécifiées s'appliquent à chaque pod/container créé dans le `namespace`
- Le `LimitRange` ne limite pas le nombre total de ressources disponibles dans le namespace


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

- Un objet `ResourceQuota` limite le total des ressources de calcul consommées par les pods ainsi que
  le total de l'espace de stockage consommé par les `PersistentVolumeClaims` dans un namespace
- Il permet aussi de limiter le nombre de `pods`, `PVCs` et autres objets qui peuvent être créés dans un `namespace`

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

