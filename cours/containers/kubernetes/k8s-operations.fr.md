### Kubectl : Advanced Usage

- Il est possible de mettre à jour un service sans incident grâce ce qui est appelé le _rolling-update_.
- Avec les _rolling updates_, les ressources qu'expose un objet `Service` se mettent à jour progressivement.
- Seuls les objets `Deployment`, `DaemonSet` et `StatefulSet` support les _rolling updates_.
- Les arguments `maxSurge` et `maxUnavailabe` définissent le rythme du _rolling update_.
- La commande `kubectl rollout` permet de suivre les _rolling updates_ effectués.

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

```console
kubectl scale --replicas=5 deployment nginx
```

- Il est possible de changer l'image d'un container utilisée par un _Deployment_ :

```console
kubectl set image deployment nginx nginx=nginx:1.15
```

### Kubectl : Advanced Usage

- Dry run. Afficher les objets de l'API correspondant sans les créer :

```console
kubectl run nginx --image=nginx --dry-run
```

- Démarrer un container en utiliser une commande différente et des arguments différents :

```console
kubectl run nginx --image=nginx \
--command -- <cmd> <arg1> ... <argN>
```

- Démarrer un Cron Job qui calcule π et l'affiche toutes les 5 minutes :

```console
kubectl run pi --schedule="0/5 * * * ?" --image=perl --restart=OnFailure \
-- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

### Kubectl : Advanced Usage

- Se connecter à un container:

```console
kubectl run -it busybox --image=busybox -- sh
```

- S'attacher à un container existant :

```console
kubectl attach my-pod -i
```

- Accéder à un service via un port :

```console
kubectl port-forward my-svc 6000
```

### Kubectl : Logging

- Utiliser `kubectl` pour diagnostiquer les applications et le cluster kubernetes :

```console
kubectl cluster-info
kubectl get events
kubectl describe node <NODE_NAME>
kubectl  logs (-f) <POD_NAME>
```

### Kubectl : Maintenance

- Obtenir la liste des noeuds ainsi que les informations détaillées :

```console
kubectl get nodes
kubectl describe nodes
```

### Kubectl : Maintenance

- Marquer le noeud comme _unschedulable_ (+ drainer les pods) et _schedulable_ :

```console
kubectl cordon <NODE_NAME>
kubectl drain <NDOE_NAME>
kubectl uncordon <NODE_NAME>
```
