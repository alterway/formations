# Rolling Update

```bash
training@master$ mkdir updating
training@master$ cd updating
training@master$ kubectl create namespace updating
```

## Mise a jour d'un deployment

1. Commençons par créer un simple deployment :

```bash
training@master$ touch example-update.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-update
  namespace: updating
  labels:
    app: httpd
spec:
  replicas: 4
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
training@master$ kubectl apply -f example-update.yaml --record

deployment.apps "example-update" created
```

3. Nous pouvons voir le status du rollout de la façon suivante :

```bash
training@master$ kubectl rollout status deployment -n updating example-update

deployment "example-update" successfully rolled out
```

4. Nous allons mettre à jour l'image httpd avec la version 2.4.46

```yaml
containers:
- name: httpd
  image: httpd:2.4.46
```

5. Mettons à jour notre deployment :

```bash
training@master$ kubectl apply -f example-update.yaml --record

deployment.apps/example-update configured
```

6. Vérifions à nouveau le status de notre rollout :

```bash
training@master$ kubectl rollout status deployment -n updating example-update

Waiting for deployment "example-update" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "example-update" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "example-update" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "example-update" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "example-update" rollout to finish: 1 old replicas are pending termination...
deployment "example-update" successfully rolled out
```

7. Nous pouvons voir l'historique du rollout avec la commande suivante :

```bash
training@master$ kubectl rollout history deployment -n updating example-update

REVISION  CHANGE-CAUSE
1         kubectl apply --filename=example-update.yaml --record=true
2         kubectl apply --filename=example-update.yaml --record=true
```

10. Nous pouvons voir les images de nos pods de la façon suivante :

```bash
training@master$ kubectl get pods -n updating -o jsonpath='{range .items[*]}{@.spec.containers[0].image}{"\n"}'

httpd:2.4.46
httpd:2.4.46
httpd:2.4.46
httpd:2.4.46
```

11. Nous pouvons faire un rollback si nous souhaitons revenir en arrière :

```bash
training@master$ kubectl rollout undo deployment -n updating example-update

deployment.apps/example-update rolled back
```

12. Revérifions le status de notre rollout :

```bash
training@master$ kubectl rollout status deployment -n updating example-update

Waiting for deployment "example-update" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "example-update" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "example-update" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "example-update" rollout to finish: 3 of 4 updated replicas are available...
deployment "example-update" successfully rolled out
```

13. Nous pouvons voir les images de nos pods de la façon suivante :

```bash
training@master$ kubectl get pods -n updating -o jsonpath='{range .items[*]}{@.spec.containers[0].image}{"\n"}'

httpd:2.4.43
httpd:2.4.43
httpd:2.4.43
httpd:2.4.43
```

14. Si nous faisons un describe sur notre deployment, nous pouvons voir les paramètre **MaxSurge** et **MaxUnavailable** :

```bash
training@master$ kubectl describe deployments -n updating example-update

...
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
...
```

## Blue/Green

1. Commençons par définir un pod "v1" :

```bash
training@master$ touch app-v1.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: blue
  name: app-v1
  namespace: updating
spec:
  containers:
  - image: nginx
    name: nginx
```

2. Que nous allons exposer avec le service suivant :

```bash
training@master$ touch app-service.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: updating
spec:
  type: ClusterIP
  selector:
    run: blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

3. Déployons donc notre application :

```bash
training@master$ kubectl apply -f app-v1.yaml -f app-service.yaml

pod/app-v1 created
service/app-service created
```

4. Nous pouvons faire un test de connexion pour voir que tout fonctionne bien :

```bash
training@master$ kubectl get svc -n updating

NAME          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
app-service   ClusterIP   10.106.61.45   <none>        80/TCP    23s

training@master$ curl IP_SERVICE_APP

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

5. Supposons que nous souhaitons mettre à jour notre application (dans notre cas, nous allons remplacer l'image nginx par httpd). Définissons donc un pod v2 :

```bash
training@master$ touch app-v2.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: green
  name: app-v2
  namespace: updating
spec:
  containers:
  - image: httpd
    name: httpd
```

6. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f app-v2.yaml

pod/app-v2 created
```

7. La mise à jour de notre application consiste uniquement en la mise à jour de notre service, en changeant le selector **blue** par **green** :

```yaml
selector:
  run: green
```

```bash
training@master$ kubectl apply -f app-service.yaml

service/app-service configured
```

8. Nous pouvons faire un test de connexion pour voir que notre service pointe désormais sur le httpd :

```bash
training@master$ curl IP_SERVICE_APP

<html><body><h1>It works!</h1></body></html>
```

9. Si nous souhaitons revenir en arrière, il nous suffit simplement remettre le label green a blue :

```yaml
selector:
  run: blue
```

```bash
training@master$ kubectl apply -f app-service.yaml

service/app-service configured
```

10. Un petit test pour confirmer :

```bash
training@master$ curl IP_SERVICE_APP

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

## Clean Up

Nous pouvons maintenant supprimer les ressources que nous avons créées dans ces exercices :

```bash
training@master$ kubectl delete -f .

service "app-service" deleted
pod "app-v1" deleted
pod "app-v2" deleted
deployment.apps "example-update" deleted
```
