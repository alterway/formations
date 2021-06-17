# TLS

Machine : **master**

```bash
training@master$ mkdir tls
training@master$ cd tls
training@master$ kubectl create namespace tls
```

## Cert Manager

1. Commençons par l'installation de Cert-Manager via Helm :

```bash
training@master$ kubectl create namespace cert-manager
training@master$ helm repo add jetstack https://charts.jetstack.io
training@master$ helm repo update
training@master$ helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.0.3 --set installCRDs=true
```

2. Nous allons créer un issuer avec cert-manager à partir d'une CA en local :

```bash
training@master$ openssl genrsa -des3 -out rootCA.key 4096
training@master$ openssl rsa -in rootCA.key -out rootCA.key
training@master$ openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
```

3. Pour que cert-manager puisse utiliser cette CA, il est nécessaire de la stocker dans un secret :

```bash
training@master$ kubectl create secret generic -n tls cm-secret-ca --from-file=tls.crt=rootCA.crt --from-file=tls.key=rootCA.key

secret/cm-secret-ca created
```

4. Nous allons maintenant créer un issuer avec cert-manager utilisant la CA que nous avons généré en local :

```bash
training@master$ touch example-issuer.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: example-issuer
  namespace: tls
spec:
  ca:
    secretName: cm-secret-ca
```

5. Créons donc cet Issuer :

```bash
training@master$ kubectl apply -f example-issuer.yaml

issuer.cert-manager.io/example-issuer created
```

6. Nous pouvons inspecter cet issuer de la façon suivante :

```bash
training@master$ kubectl get issuer -n tls example-issuer

NAME             READY   AGE
example-issuer   True    76s

training@master$ kubectl describe issuer -n tls example-issuer

...
Status:
  Conditions:
    Last Transition Time:  2020-11-01T19:05:17Z
    Message:               Signing CA verified
    Reason:                KeyPairVerified
    Status:                True
    Type:                  Ready
Events:
  Type     Reason           Age                 From          Message
  ----     ------           ----                ----          -------
  Normal   KeyPairVerified  43s (x2 over 43s)   cert-manager  Signing CA verified
...
```

7. Il est également possible de définir des ClusterIssuer. Comme pour les roles, les Issuer sont limités à un seul namespace, tandis que les ClusterIssuer sont utilisables dans tout les namespaces :

```bash
training@master$ kubectl create secret generic -n cert-manager cm-secret-ca --from-file=tls.crt=rootCA.crt --from-file=tls.key=rootCA.key

secret/cm-secret-ca created
```

```bash
training@master$ touch example-cluster-issuer.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: example-cluster-issuer
spec:
  ca:
    secretName: cm-secret-ca
```

8. Nous pouvons créer ce ClusterIssuer :

```bash
training@master$ kubectl apply -f example-cluster-issuer.yaml

clusterissuer.cert-manager.io/example-cluster-issuer created
```

9. Que nous pouvons consulter de la même façon qu'un Issuer :

```bash
training@master$ kubectl get clusterissuer example-cluster-issuer

NAME                     READY   AGE
example-cluster-issuer   True    75s

training@master$ kubectl describe clusterissuer example-cluster-issuer

...
Status:
  Conditions:
    Last Transition Time:  2020-11-01T19:10:39Z
    Message:               Signing CA verified
    Reason:                KeyPairVerified
    Status:                True
    Type:                  Ready
Events:
  Type    Reason           Age                From          Message
  ----    ------           ----               ----          -------
  Normal  KeyPairVerified  73s (x3 over 85s)  cert-manager  Signing CA verified
```

10. Maintenant que nous avons un Issuer, nous pouvons générer un certificat à partir de cet Issuer :

```bash
training@master$ touch example-certificate.yaml
```

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-certificate
  namespace: tls
spec:
  secretName: example-com-tls
  issuerRef:
    name: example-issuer
  commonName: example.com
  dnsNames:
  - www.example.com
```

11. Nous pouvons créer ce certificat :

```bash
training@master$ kubectl apply -f example-certificate.yaml

certificate.cert-manager.io/example-certificate created
```

12. Que nous pouvons consulter de la façon suivante :

```bash
training@master$ kubectl get certificate -n tls example-certificate

NAME                  READY   SECRET            AGE
example-certificate   True    example-com-tls   17s

training@master$ kubectl describe certificate -n tls example-certificate

...
Status:
  Conditions:
    Last Transition Time:  2020-11-01T19:12:50Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2021-01-30T19:12:50Z
  Not Before:              2020-11-01T19:12:50Z
  Renewal Time:            2020-12-31T19:12:50Z
  Revision:                1
Events:
  Type    Reason     Age   From          Message
  ----    ------     ----  ----          -------
  Normal  Issuing    44s   cert-manager  Issuing certificate as Secret does not exist
  Normal  Generated  43s   cert-manager  Stored new private key in temporary Secret resource "example-certificate-lqdvg"
  Normal  Requested  43s   cert-manager  Created new CertificateRequest resource "example-certificate-bhv5v"
  Normal  Issuing    43s   cert-manager  The certificate has been successfully issued
```

13. Ce certificat est stocké dans un secret example-com-tls :

```bash
training@master$ kubectl get secrets -n tls example-com-tls

NAME              TYPE                DATA   AGE
example-com-tls   kubernetes.io/tls   3      56s

training@master$ kubectl describe secrets -n tls example-com-tls

Type:  kubernetes.io/tls

Data
====
ca.crt:   1939 bytes
tls.crt:  1537 bytes
tls.key:  1675 bytes
```

Ces certificats pourront être montés en tant que fichier sur n'importe quel pod.

## Ingress with TLS using Cert Manager

Une autre force de cert manager est la compatibilité avec plusieurs outils, notamment les ingress-controller. Nous allons voir dans cet exercice comment ceci s'illustre.

1. Commençons par créer un pod :

```bash
training@master$ touch tls-pod.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: tls-pod
  name: tls-pod
  namespace: tls
spec:
  containers:
  - image: nginx
    name: nginx
```

2. Que nous allons exposer avec le service suivant :

```bash
training@master$ touch tls-service.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tls-service
  namespace: tls
spec:
  type: ClusterIP
  selector:
    run: tls-pod
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

3. Nous allons maintenant créer un ingress pour ce service, avec le tls active, utilisant notre example-issuer :

```bash
training@master$ touch tls-ingress.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tls-ingress
  namespace: tls
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/issuer: example-issuer
spec:
  rules:
  - host: tls.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: tls-service
          servicePort: 80
  tls:
  - hosts:
    - tls.example.com
    secretName: tls-cert
```

4. Créons ces ressources :

```bash
training@master$ kubectl apply -f tls-pod.yaml -f tls-service.yaml -f tls-ingress.yaml

pod/tls-pod created
service/tls-service created
Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.networking.k8s.io/tls-ingress created
```

5. Nous pouvons voir qu'un certificat, ainsi qu'un secret ont été générés :

```bash
training@master$ kubectl get certificates -n tls

NAME                  READY   SECRET            AGE
example-cert          True    example-cert      12s
example-certificate   True    example-com-tls   9m28s

kubectl get secrets -n tls

NAME                  TYPE                                  DATA   AGE
cm-secret-ca          Opaque                                2      17m
default-token-k6b92   kubernetes.io/service-account-token   3      20m
tls-cert              kubernetes.io/tls                     3      109s
example-com-tls       kubernetes.io/tls                     3      9m39s
```

6. Essayons de nous connecter via l'ingress avec notre CA :

Ajouter tls.example.com avec l'IP du l'ingress controller dans /etc/hosts :

```bash
IP_INGRESS tls.example.com
```

Puis tester la connexion

```bash
training@master$ curl --cacert rootCA.crt https://tls.example.com

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

##Clean Up

Nous pouvons supprimer les ressources générés par cet exercices de la façon suivante :

```bash
training@master$ kubectl delete -f .
```
