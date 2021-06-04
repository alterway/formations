# Ingress

Machine : **master**

```bash
training@master$ mkdir ingress
training@master$ cd ingress
training@master$ kubectl create namespace ingress
```

## Nginx ingress controller

1. Commençons par installer l'ingress controller Nginx via Helm :

```bash
training@master$ kubectl create namespace ingress-nginx
training@master$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
training@master$ helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx

NAME: ingress-nginx
LAST DEPLOYED: Tue Oct 27 13:03:35 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w ingress-nginx-controller'

An example Ingress that makes use of the controller:
...
```

2. Nous allons maintenant définir deux pods : Un nginx et Un apache :

```bash
training@master$ touch ingress-nginx-pod.yaml
training@master$ touch ingress-httpd-pod.yaml
```

Avec respectivement les yaml suivants :

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: ingress-nginx-pod
  name: ingress-nginx-pod
  namespace: ingress
spec:
  containers:
  - image: nginx
    name: nginx
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: ingress-httpd-pod
  name: ingress-httpd-pod
  namespace: ingress
spec:
  containers:
  - image: httpd
    name: httpd
```

3. Créeons maintenant ces pods :

```bash
training@master$ kubectl apply -f ingress-nginx-pod.yaml -f ingress-httpd-pod.yaml

pod/ingress-nginx-pod created
pod/ingress-httpd-pod created
```

4. Exposons ces pods :

```bash
training@master$ touch ingress-nginx-service.yaml
training@master$ touch ingress-httpd-service.yaml
```

Avec les yaml suivants :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-service
  namespace: ingress
spec:
  type: ClusterIP
  selector:
    run: ingress-nginx-pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-httpd-service
  namespace: ingress
spec:
  type: ClusterIP
  selector:
    run: ingress-httpd-pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

5. Créeons ces services :

```bash
training@master$ kubectl apply -f ingress-nginx-service.yaml -f ingress-httpd-service.yaml

service/ingress-nginx-service created
service/ingress-httpd-service created
```

6. Nous allons maintenant définir un ingress redirigeant vers nos deux services, selon le path dans l'URL :

```bash
training@master$ touch ingress-with-paths.yaml
```

Avec le contenu yaml suivant

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: ingress-with-paths
  namespace: ingress
spec:
  rules:
    - http:
        paths:
          - path: /nginx
            pathType: Prefix
            backend:
              serviceName: ingress-nginx-service
              servicePort: 80
          - path: /httpd
            pathType: Prefix
            backend:
              serviceName: ingress-httpd-service
              servicePort: 80
```

7. Créeons maintenant cet ingress :

```bash
training@master$ kubectl apply -f ingress-with-paths.yaml

Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io/ingress-with-paths created
```

8. Nous pouvons récupérer des informations sur notre ingress de la façon suivante :

```bash
training@master$ kubectl get ingresses -n ingress ingress-with-paths

Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME                 CLASS    HOSTS   ADDRESS   PORTS   AGE
ingress-with-paths   <none>   *                 80      19s

training@master$ kubectl get svc -n ingress-nginx

NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.99.141.243   <pending>     80:32527/TCP,443:30666/TCP   14m
ingress-nginx-controller-admission   ClusterIP      10.97.240.239   <none>        443/TCP                      14m
```

9. Essayons tout d'abord de nous connecter via les services de nginx et de httpd :

```bash
training@master$ kubectl get svc -n ingress

NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
ingress-httpd-service   ClusterIP   10.110.184.101   <none>        80/TCP    19m
ingress-nginx-service   ClusterIP   10.97.71.54      <none>        80/TCP    19m

training@master$ curl IP_HTTP_SERVICE

<html><body><h1>It works!</h1></body></html>

training@master$ curl IP_NGINX_SERVICE

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

10. Essayons maintenant de nous connecter aux deux pods via cet ingress :

```bash
training@master$ curl IP_INGRESS/httpd

<html><body><h1>It works!</h1></body></html>

training@master$ curl IP_INGRESS/nginx

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

11. Nous allons maintenant définir un ingress, mais cette fois-ci, nos redirection se feront selon l'host que nous utilisons pour nous connecter :

```bash
training@master$ touch ingress-with-hosts.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: ingress-with-hosts
  namespace: ingress
spec:
  rules:
    - host: nginx.example.com
      http:
        paths:
          - backend:
              serviceName: ingress-nginx-service
              servicePort: 80
            path: /
    - host: httpd.example.com
      http:
        paths:
          - backend:
              serviceName: ingress-httpd-service
              servicePort: 80
            path: /
```

12. Creeons cet ingress :

```bash
training@master$ kubectl apply -f ingress-with-hosts.yaml

Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io/ingress-with-hosts created
```

13. Ajoutons ces deux entrees dans le fichier /etc/hosts :

```bash
IP_INGRESS nginx.example.com
IP_INGRESS httpd.example.com
```

14. Essayons maintenant de nous connecter à nos deux pods via l'ingress :

```bash
training@master$ curl httpd.example.com

<html><body><h1>It works!</h1></body></html>

training@master$ curl nginx.example.com

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

Nous pouvons supprimer les ressources generes par cet exercices de la facon suivante :

```bash
training@master$ kubectl delete -f .

pod "ingress-httpd-pod" deleted
service "ingress-httpd-service" deleted
pod "ingress-nginx-pod" deleted
service "ingress-nginx-service" deleted
Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io "ingress-with-hosts" deleted
ingress.networking.k8s.io "ingress-with-paths" deleted
```
