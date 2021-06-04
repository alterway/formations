# Network Policies

Machine : **master**

```bash
training@master$ mkdir network-policies
training@master$ cd network-policies
training@master$ kubectl create namespace network-policies
```

1. Nous allons commencer par créer 3 pods : 2 pods "source" et un pod "dest" :

```bash
training@master$ touch source1-pod.yaml
training@master$ touch source2-pod.yaml
training@master$ touch dest-pod.yaml
```

Avec respectivement ces contenus yaml :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: source1-pod
  namespace: network-policies
  labels:
    role: source1
spec:
  containers:
  - name: source1
    image: nginx
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: source2-pod
  namespace: network-policies
  labels:
    role: source2
spec:
  containers:
  - name: source2
    image: nginx
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dest-pod
  namespace: network-policies
  labels:
    role: dest
spec:
  containers:
  - name: dest
    image: nginx
```

2. Déployons ces 3 pods :

```bash
training@master$ kubectl apply -f source1-pod.yaml -f source2-pod.yaml -f dest-pod.yaml

pod/dest-pod created
pod/source1-pod created
pod/source2-pod created
```

3. Nous allons également définir un service pour chacun de nos pods :

```bash
training@master$ touch source1-service.yaml
training@master$ touch source2-service.yaml
training@master$ touch dest-service.yaml
```

Avec respectivement les contenus yaml suivants :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: source1-service
  namespace: network-policies
spec:
  type: ClusterIP
  selector:
    role: source1
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: source2-service
  namespace: network-policies
spec:
  type: ClusterIP
  selector:
    role: source2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: dest-service
  namespace: network-policies
spec:
  type: ClusterIP
  selector:
    role: dest
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

4. Créeons ces services :

```bash
training@master$ kubectl apply -f source1-service.yaml -f source2-service.yaml -f dest-service.yaml

service/dest-service created
service/source1-service created
service/source2-service created
```

3. Essayons de faire une requête depuis les pods source1 et source2 vers dest :

```bash
training@master$ kubectl exec -n network-policies -it source1-pod curl dest-service
training@master$ kubectl exec -n network-policies -it source2-pod curl dest-service

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

Sans Network Policies, on remarque que les requêtes se déroulent bien.

4. Nous allons maintenant créer une Network Policy autorisant source1 à faire des requêtes sur dest, mais pas source2 (ni aucun autre pod) :


```bash
training@master$ touch ingress-network-policy.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-network-policy
  namespace: network-policies
spec:
  podSelector:
    matchLabels:
      role: dest
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: source1
    ports:
    - protocol: TCP
      port: 80
```

5. Créeons cette Network Policy :

```bash
training@master$ kubectl apply -f ingress-network-policy.yaml

networkpolicy.networking.k8s.io/ingress-network-policy created
```

6. Nous pouvons inspecter la network policy de la façon suivante :

```bash
training@master$ kubectl describe networkpolicies -n network-policies ingress-network-policy

Name:         ingress-network-policy
Namespace:    network-policies
Created on:   2020-11-02 09:29:07 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     role=dest
  Allowing ingress traffic:
    To Port: 80/TCP
    From:
      PodSelector: role=source1
  Not affecting egress traffic
  Policy Types: Ingress
```

7. Maintenant, essayons le même test de connexion :

```bash
training@master$ kubectl exec -n network-policies -it source1-pod -- curl dest-service

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

training@master$ kubectl exec -n network-policies -it source2-pod -- curl dest-service

curl: (7) Failed to connect to dest-service port 80: Connection timed out
command terminated with exit code 7
```

8. Nous allons maintenant définir une network policy mais en egress, authorisant dest à faire une requête à source1 mais pas à source 2 :

```bash
training@master$ touch egress-network-policy.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-network-policy
  namespace: network-policies
spec:
  podSelector:
    matchLabels:
      role: dest
  policyTypes:
  - Egress
  egress: []
```

9. Créeons donc cette network policy :

```bash
training@master$ kubectl apply -f egress-network-policy.yaml

networkpolicy.networking.k8s.io/egress-network-policy created
```

10. Nous pouvons maintenant essayer de faire une requête depuis dest vers source1 ou source2 :

```bash
training@master$ kubectl exec -n network-policies -it dest-pod -- curl source2-service

curl: (6) Could not resolve host: source2-service
command terminated with exit code 6
```

11. Modifions le contenu yaml de l'egress network policy :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-network-policy
  namespace: network-policies
spec:
  podSelector:
    matchLabels:
      role: dest
  policyTypes:
  - Egress
  egress:
  - to:
    ports:
    - protocol: TCP
      port: 80
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
```

12 Appliquons la modification :

```bash
training@master$ kubectl apply -f egress-network-policy.yaml

networkpolicy.networking.k8s.io/egress-network-policy configured
```

13. Nous pouvons reessayer le test de connexion :

```bash
training@master$ kubectl exec -n network-policies -it dest-pod -- curl source2-service

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

## Clean up

Nous allons supprimer les ressources créées par cet exercice de la façon suivante :

```bash
training@master$ kubectl delete -f .

pod "dest-pod" deleted
service "dest-service" deleted
networkpolicy.networking.k8s.io "egress-network-policy" deleted
networkpolicy.networking.k8s.io "ingress-network-policy" deleted
pod "source1-pod" deleted
service "source1-service" deleted
pod "source2-pod" deleted
service "source2-service" deleted
```
