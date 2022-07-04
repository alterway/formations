# Deployment

```bash
kubectl create deploy nginx-deployment --image=nginx:1.17.10 --port 80 --replicas=2

```

ou

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:1.17.10
        imagePullPolicy: IfNotPresent
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
```


### Scale

```bash
kubectl scale deployment nginx-deployment --replicas=4
kubectl get deployment nginx-deployment
kubectl describe deployment nginx-deployment
```

### Mise à jour de l'image

```bash
kubectl set image deployment nginx-deployment nginx=nginx:1.9.1
```

### Status

```bash
kubectl rollout status deployment nginx-deployment
kubectl describe deploy nginx-deployment
```

### Rollback

```bash
kubectl rollout undo deployment nginx-deployment

kubectl rollout status deployment nginx-deployment
kubectl describe deploy nginx-deployment
```

<hr>
