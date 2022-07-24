# Ingress

<hr>

Machine : **master**

<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 mkdir ingress
 cd ingress
 kubectl create namespace ingress
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Nginx ingress controller

1. Commençons par installer l'ingress controller Nginx via Helm :


- creer un fichier values.yaml avec les valeurs suivantes :

en modifiant IP-PUB-MASTER et IP-PRIV-MASTER par vos valeurs

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
controller:
  hostNetwork: false
  hostPort:
    enabled: true
    ports:
      http: 80
      https: 443
  service:
    enabled: true
    externalIPs:
      - IP-PUB-MASTER
      - IP-PRIV-MASTER
    type: NodePort
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Déployer le chart Helm

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl create namespace ingress-nginx
 helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
 # helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx

 helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace -f values.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Nous allons maintenant définir deux pods : Un nginx et Un apache :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 touch ingress-nginx-pod.yaml
 touch ingress-httpd-pod.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec respectivement les yaml suivants :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Créons maintenant ces pods :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl apply -f ingress-nginx-pod.yaml -f ingress-httpd-pod.yaml

pod/ingress-nginx-pod created
pod/ingress-httpd-pod created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Exposons ces pods :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 touch ingress-nginx-service.yaml
 touch ingress-httpd-service.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec les yaml suivants :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Créons ces services :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl apply -f ingress-nginx-service.yaml -f ingress-httpd-service.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
service/ingress-nginx-service created
service/ingress-httpd-service created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Nous allons maintenant définir un ingress redirigeant vers nos deux services, selon le path dans l'URL :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 touch ingress-with-paths.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: networking.k8s.io/v1
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
              service:
                name: ingress-nginx-service
                port:
                  number: 80
          - path: /httpd
            pathType: Prefix
            backend:
              service:
                 name: ingress-httpd-service
                 port:
                   number: 80
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

7. Créons maintenant cet ingress :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl apply -f ingress-with-paths.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io/ingress-with-paths created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

8. Nous pouvons récupérer des informations sur notre ingress de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl get ingresses -n ingress ingress-with-paths
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME                 CLASS    HOSTS   ADDRESS   PORTS   AGE
ingress-with-paths   <none>   *                 80      19s

 kubectl get svc -n ingress-nginx

NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.99.141.243   <pending>     80:32527/TCP,443:30666/TCP   14m
ingress-nginx-controller-admission   ClusterIP      10.97.240.239   <none>        443/TCP                      14m
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Essayons tout d'abord de nous connecter via les services de nginx et de httpd :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl get svc -n ingress
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
ingress-httpd-service   ClusterIP   10.110.184.101   <none>        80/TCP    19m
ingress-nginx-service   ClusterIP   10.97.71.54      <none>        80/TCP    19m
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 curl IP_HTTP_SERVICE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.html}
<html><body><h1>It works!</h1></body></html>

 curl IP_NGINX_SERVICE

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

10. Essayons maintenant de nous connecter aux deux pods via cet ingress :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 curl IP_INGRESS/httpd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.html}
<html><body><h1>It works!</h1></body></html>

 curl IP_INGRESS/nginx

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

11. Nous allons maintenant définir un ingress, mais cette fois-ci, nos redirection se feront selon l'host que nous utilisons pour nous connecter :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 touch ingress-with-hosts.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: networking.k8s.io/v1
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
              service:
                name: ingress-nginx-service
                port:
                  number: 80
            path: /
            pathType: Prefix
    - host: httpd.example.com
      http:
        paths:
          - backend:
              service:
                name: ingress-httpd-service
                port:
                  number: 80
            path: /
            pathType: Prefix
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

12. Créons cet ingress :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl apply -f ingress-with-hosts.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
ingress.networking.k8s.io/ingress-with-hosts created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

13.  Ajoutons ces deux entrées dans le fichier /etc/hosts :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
IP_INGRESS nginx.example.com
IP_INGRESS httpd.example.com
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

14. Essayons maintenant de nous connecter à nos deux pods via l'ingress :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 curl httpd.example.com
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.html}
<html><body><h1>It works!</h1></body></html>

 curl nginx.example.com

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


<hr>

Machine : **master**

<hr>

## Canary Deployment

Les déploiements Canary permettent le déploiement progressif de nouvelles versions d'applications sans aucune interruption de service. 

Le **NGINX Ingress Controller**  prend en charge les politiques de répartition du trafic basées sur les en-têtes (header) , le cookie et le poids. Alors que les politiques basées sur les en-têtes et les cookies servent à fournir une nouvelle version de service à un sous-ensemble d'utilisateurs, les politiques basées sur le poids servent à détourner un pourcentage du trafic vers une nouvelle version de service.

Le **NGINX Ingress Controller** utilise les annotations suivantes pour activer les déploiements Canary :

```
- nginx.ingress.kubernetes.io/canary-by-header

- nginx.ingress.kubernetes.io/canary-by-header-value

- nginx.ingress.kubernetes.io/canary-by-header-pattern

- nginx.ingress.kubernetes.io/canary-by-cookie

- nginx.ingress.kubernetes.io/canary-weight
```

Les règles s'appliquent dans cet ordre :

- canary-by-header 

- canary-by-cookie 

- canary-weight 

Les déploiements Canary nécessitent que vous créiez deux entrées : une pour le trafic normal et une pour le trafic alternatif. Sachez que vous ne pouvez appliquer qu'une seule entrée Canary.

Vous activez une règle de répartition du trafic particulière en définissant l'annotation Canary associée sur true dans la ressource Kubernetes Ingress, comme dans l'exemple suivant :

- `nginx.ingress.kubernetes.io/canary-by-header : "true"`


Exemple : 

1. Déployer les applications et services suivants

- Application V1 :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}

apiVersion: v1
kind: Service
metadata:
  name: echo-v1
spec:
  type: ClusterIP
  ports:
    - port: 80
      protocol: TCP
      name: http
  selector:
    app: echo
    version: v1

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
      version: v1
  template:
    metadata:
      labels:
        app: echo
        version: v1
    spec:
      containers:
        - name: echo
          image: "hashicorp/http-echo"
          args:
            - -listen=:80
            - --text="echo-v1"
          ports:
            - name: http
              protocol: TCP
              containerPort: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

- Application V2 :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Service
metadata:
  name: echo-v2
spec:
  type: ClusterIP
  ports:
    - port: 80
      protocol: TCP
      name: http
  selector:
    app: echo
    version: v2

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo
      version: v2
  template:
    metadata:
      labels:
        app: echo
        version: v2
    spec:
      containers:
        - name: echo
          image: "hashicorp/http-echo"
          args:
            - -listen=:80
            - --text="echo-v2"
          ports:
            - name: http
              protocol: TCP
              containerPort: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

2. Déployer l'ingress de l'application v1

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: nginx
  name: ingress-echo
spec:
  #ingressClassName: nginx
  rules:
    - host: canary.example.com
      http:
        paths:
          - path: /echo
            pathType: Exact
            backend:
              service:
                name: echo-v1
                port:
                  number: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

3. Vérifiez qu'il fonctionne

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl -H "Host: canary.example.com" http://<IP_ADDRESS>:<PORT>/echo

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
4. Vous devriez avoir la réponse suivante

**echo-v2**

5. Test : Par Header

Deployez l'ingress suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "Region"
    nginx.ingress.kubernetes.io/canary-by-header-pattern: "fr|us"
    kubernetes.io/ingress.class: nginx
  name: ingress-echo-canary-header
spec:
  #ingressClassName: nginx
  rules:
    - host: canary.example.com
      http:
        paths:
          - path: /echo
            pathType: Exact
            backend:
              service:
                name: echo-v2
                port:
                  number: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

6. Faire les test suivants

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl   -H "Host: canary.example.com" -H "Region: us" http://<IP_ADDRESS>:<PORT>/echo
curl   -H "Host: canary.example.com" -H "Region: de" http://<IP_ADDRESS>:<PORT>/echo
curl   -H "Host: canary.example.com"                 http://<IP_ADDRESS>:<PORT>/echo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

7. Résultats

**echo-v2**  

**echo-v1**  

**echo-v1**

8. Supprimer l'ingress ingress-echo-canary-header

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete ingress ingress-echo-canary-header
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

9. Test : Par cookie

Déployez l'ingress suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: "my-cookie"
    kubernetes.io/ingress.class: nginx
  name: ingress-echo-canary-cookie
spec:
  #ingressClassName: nginx
  rules:
    - host: canary.example.com
      http:
        paths:
          - path: /echo
            pathType: Exact
            backend:
              service:
                name: echo-v2
                port:
                  number: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

10. Faire les test suivants

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl -s --cookie "my-cookie=always"  -H "Host: canary.example.com"     http://<IP_ADDRESS>:<PORT>/echo
curl -s --cookie "other-cookie=always"  -H "Host: canary.example.com"  http://<IP_ADDRESS>:<PORT>/echo
curl   -H "Host: canary.example.com"                                   http://<IP_ADDRESS>:<PORT>/echo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

11. Résultats

**echo-v2**  

**echo-v1**  

**echo-v1**  


12. Supprimer l'ingress ingress-echo-canary-cookie

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete ingress ingress-echo-canary-cookie
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 


13. Test : Par poids

Déployez l'ingress suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "X-Canary"
    nginx.ingress.kubernetes.io/canary-weight: "50"
    kubernetes.io/ingress.class: nginx
  name: ingress-echo-canary-weight
spec:
  #ingressClassName: nginx
  rules:
    - host: canary.example.com
      http:
        paths:
          - path: /echo
            pathType: Exact
            backend:
              service:
                name: echo-v2
                port:
                  number: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

14. faire les tests suivants

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

# 6 fois : 
curl   -H "Host: canary.example.com"  http://<IP_ADDRESS>:<PORT>/echo

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

15. Vérifiez bien que vous avez une répartition de 50% entre echo-v1 et echo-v2

16. Installer k6: https://k6.io/docs/getting-started/installation/


Utilisez en l'adaptant (url) le fichier: script.js

Modifiez `http://localhost/echo` par `http://ip-pub-loadbalancer/echo`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ javascript

import http from 'k6/http';
import {check, sleep} from 'k6';
import {Rate} from 'k6/metrics';
import {parseHTML} from "k6/html";

const reqRate = new Rate('http_req_rate');

export const options = {
    stages: [
        {target: 20, duration: '20s'},
        {target: 20, duration: '20s'},
        {target: 0, duration: '20s'},
    ],
    thresholds: {
        'checks': ['rate>0.9'],
        'http_req_duration': ['p(95)<1000'],
        'http_req_rate{deployment:echo-v1}': ['rate>=0'],
        'http_req_rate{deployment:echo-v2}': ['rate>=0'],
    },
};

export default function () {
    const params = {
        headers: {
            'Host': 'canary.example.com',
            'Content-Type': 'text/plain',
        },
    };

    const res = http.get(`http://localhost/echo`, params);
    check(res, {
        'status code is 200': (r) => r.status === 200,
    });
   
  
    var body = res.body.replace(/[\r\n]/gm, '');

    switch (body) {
        case '"echo-v1"':
            reqRate.add(true, { deployment: 'echo-v1' });
            reqRate.add(false, { deployment: 'echo-v2' });
            break;
        case '"echo-v2"':
            reqRate.add(false, { deployment: 'echo-v1' });
            reqRate.add(true, { deployment: 'echo-v2' });
            break;
    }

    sleep(1);
}


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

et lancez le de la manière suivante 

`k6 run script.js`

vérifiez la répartition des requetes

## Clean Up

Nous pouvons supprimer les ressources générées par cet exercices de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
 kubectl delete -f .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
pod "ingress-httpd-pod" deleted
service "ingress-httpd-service" deleted
pod "ingress-nginx-pod" deleted
service "ingress-nginx-service" deleted
Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io "ingress-with-hosts" deleted
ingress.networking.k8s.io "ingress-with-paths" deleted
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


<hr>
