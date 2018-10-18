# Monitoring

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

