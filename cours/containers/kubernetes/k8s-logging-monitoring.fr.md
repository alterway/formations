# KUBERNETES : logging et monitoring

### Monitoring du cluster

- Le monitoring est nécessaire pour connaitre l'utilisation des ressources du cluster (CPU, RAM, Stockage, etc)
- Kubernetes n'intègre pas nativement de solution de monitoring
- Il existe des solutions open source telles que: Metric-Server, Prometheus, Elastic Stack
- Et des solutions propriétaires: Datadog, Dynatrace


### Monitoring du cluster

- Il est recommandé d'avoir un server de métrique sur chaque cluster
- Les métriques sont récupérés, stockés et peuvent être consultés suivant la solution de monitoring utilisée.
- Un composant du Kubelet appelé cAdvisor récupère les métriques des pods sur chaque noeud


### Monitoring du cluster

- Les performances des pods et des noeuds peuvent être affichées avec la commande `kubectl top pods` et `kubectl top nodes`

```console
$ kubectl top nodes
NAME                                         CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
gke-cka-pool1-8e771340-lzju                   86m          4%     736Mi           13%
gke-cka-pool1-f884d89f-pnbx                   155m         8%     811Mi           14%
```

```console
$ kubectl -n lab top pods
NAME                             CPU(cores)   MEMORY(bytes)
lab-middleware-c46cd576f-5vltl   1m           40Mi
lab-middleware-c46cd576f-7zckz   1m           43Mi
```

### Logging

- Tout comme docker, Kubernetes permet d'afficher les logs générés par les applications avec la commande `kubectl logs`
- L'option `-f` permet de diffusion en direct des logs
- Pour les pods multi-conteneurs, il est nécessaire de spécifier le conteneur dont on veut visualiser les logs


### Logging

```console
$ kubectl -n lab get pods
NAME                             READY   STATUS    RESTARTS   AGE
lab-middleware-c46cd576f-5vltl   1/1     Running   0          17d
lab-middleware-c46cd576f-7zckz   1/1     Running   0          17d
```


```console
$ kubectl -n lab logs  lab-middleware-c46cd576f-5vltl
info: serving app on http://0.0.0.0:3333
[bugsnag] Loaded!
[bugsnag] Bugsnag.start() was called more than once. Ignoring.
[bugsnag] Bugsnag.start() was called more than once. Ignoring.
[bugsnag] Bugsnag.start() was called more than once. Ignoring.
```


