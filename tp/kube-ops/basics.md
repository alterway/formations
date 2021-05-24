# Bases

Machine : **master**

```bash
training@master$ mkdir basics
training@master$ cd basics
training@master$ kubectl create namespace basics
```

## Lancement du premier pod

1. Creer un pod en CLI :

```bash
training@master$ kubectl run --image=nginx basic-pod

pod/basic-pod created
```

2. Creer un pod avec un fichier YAML :

```bash
training@master$ touch basic-pod2.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: basic-pod2
  namespace: basics
  labels:
    role: front
spec:
  containers:
  - name: basic-pod2
    image: nginx
```

3. Deployons ce pod :

```bash
training@master$ kubectl apply -f basic-pod2.yaml

pod/basic-pod2 created
```

## Interagir avec un pod

1. Inspecter le pod basic-pod2 :

```bash
training@master$ kubectl describe pods -n basics basic-pod2

Name:         basic-pod2
Namespace:    basics
Priority:     0
Node:         worker-0/10.156.0.2
Start Time:   Tue, 30 Mar 2021 19:21:48 +0000
Labels:       role=front
Annotations:  Status:  Running
...
```

2. Executer un commande dans un pod :

```bash
training@master$ kubectl exec -it -n basics basic-pod2 -- bash

root@basic-pod2:/#
```

# Dry run

1. Recuperer l'Yaml de la creation d'un pod :

```bash
training@master$ kubectl run nginx --image=nginx --dry-run=client -o yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

## Exposer un pod avec un service

1. Exposer un service en CLI

```bash
training@master$ kubectl expose pod basic-pod2 --port=80 --target-port=80 -n basics

service/basic-pod2 exposed
```

3. Creer un service en YAML

```bash
training@master$ touch basic-service.yaml
```

Avec le contenu yaml suivant :

```yaml

apiVersion: v1
kind: Service
metadata:
  labels:
    app: basic-service
  name: basic-service
  namespace: basics
spec:
  ports:
  - name: "80"
    nodePort: 32000
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    role: front
  type: NodePort
```

4. Creeons ce service :

```bash
training@master$ kubectl apply -f basic-service.yaml

service/basic-service created
```

5. Inspectons ce service :

```bash
training@master$ kubectl get services -n basics

NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
basic-pod2      ClusterIP   10.108.17.23     <none>        80/TCP         37m
basic-service   NodePort    10.100.198.240   <none>        80:32000/TCP   79s

training@master$ kubectl describe services -n basics basic-service

Name:                     basic-service
Namespace:                basics
Labels:                   app=basic-service
Annotations:              Selector:  role=front
Type:                     NodePort
IP:                       10.100.198.240
Port:                     80  80/TCP
TargetPort:               80/TCP
NodePort:                 80  32000/TCP
Endpoints:                10.32.0.3:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

6. Testons nos deux services :

```bash
training@master$ curl CLUSTER_IP_BASIC_POD

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

```bash
training@master$ curl IP_EXTERNE_NODE:32000

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## Lancer un deployment

1. Commençons par créer un simple deployment :

```bash
training@master$ touch basic-deployment.yaml
```

Avec le contenu yaml suivant :

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: basic-deployment
  namespace: basics
  labels:
    app: httpd
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.43
        ports:
        - containerPort: 80
```

2. Créeons donc ce deployment :

```bash
training@master$ kubectl apply -f basic-deployment.yaml

deployment.apps/basic-deployment created
```

3. Inspectons ce deployment :

```bash
training@master$ kubectl get deployments -n basics
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
basic-deployment   3/3     3            3           37s

training@master$ kubectl get pods -n basics
NAME                                READY   STATUS    RESTARTS   AGE
basic-deployment-64b5596cc5-2jttj   1/1     Running   0          47s
basic-deployment-64b5596cc5-4kzxn   1/1     Running   0          47s
basic-deployment-64b5596cc5-ljhqp   1/1     Running   0          47s
basic-pod2                          1/1     Running   0          35m

training@master$ kubectl describe deployments -n basics basic-deployment

Name:                   basic-deployment
Namespace:              basics
CreationTimestamp:      Tue, 30 Mar 2021 19:56:48 +0000
Labels:                 app=httpd
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=httpd
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
...
```

4. Mettons a jour ce deployment :

```yaml
replicas: 4
```

```bash
training@master$ kubectl apply -f basic-deployment.yaml

deployment.apps/basic-deployment configured

training@master$ kubectl get deployments -n basics basic-deployment

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
basic-deployment   4/4     4            4           5m8s
```
