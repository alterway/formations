# Pods


### Création

```bash
kubectl run webserver --image=nginx:latest
```

ou

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webserver
  name: webserver
spec:
  containers:
  - image: nginx:latest
    imagePullPolicy: Always
    name: webserver
```

### check


```bash
kubectl get pod -o wide
```

### Connexion

```bash
kubectl exec webserver -- cat /etc/os-release
```

### logs

```bash
kubectl logs webserver 
# ou
stern webserver
# ou 
stern -l run=webserver
```

### webwatcher

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: webserver
  name: webserver
spec:
  containers:
  - image: nginx:latest
    imagePullPolicy: Always
    name: webserver
  - image: afakharany/watcher:latest
    imagePullPolicy: Always
    name: webwatcher
```

```bash 
kubectl delete pod webserver
kubectl apply -f pod.yaml
kubectl exec webserver -c webwatcher -- cat /etc/hosts
```




<hr>
