# KUBERNETES : Networking

### Kubernetes : Network plugins

- Kubernetes n'implémente pas de solution de gestion de réseau par défaut
- Le réseau est implémenté par des solutions tierces:
    - [Calico](https://www.projectcalico.org/): IPinIP + BGP
    - [Cilium](https://cilium.io/): eBPF
    - [Weave](https://www.weave.works/)
    - Bien [d'autres](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

### Kubernetes : CNI

- [Container Network Interface](https://github.com/containernetworking/cni)
- Projet dans la CNCF
- Standard pour la gestion du réseau en environnement conteneurisé
- Les solutions précédentes s'appuient sur CNI


### Kubernetes : POD Networking

![pod network](images/pod-networking.png)

### Kubernetes : Services

- Abstraction des pods sous forme d'une `IP virtuelle` de service et d'un `nom DNS`
- Rendre un ensemble de pods accessibles depuis l'extérieur
- Load Balancing entre les pods d'un même service

### Kubernetes : Services

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCP
    - Azure Kubernetes Service
    - OpenStack
    - ...

### Kubernetes : Services : ClusterIP

- `ClusterIP` : 
    - C'est le service par défaut
    - Attribue une adresse IP interne accessible uniquement au sein du cluster, cette adresse est accessible dans le cluster par les pods et les noeuds
    - Expose le service pour les connexions depuis l'intérieur du cluster 

![](images/clusterIP.png)

### Kubernetes : Services : ClusterIP

```yaml
apiVersion: v1
kind: Service
metadata: 
  name: the-service
spec: 
  ports: 
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector: 
    app: web
```

```console
# déploiement 

kubectl create deployment web --image=nginx

# service
# par défaut type= ClusterIP

kubectl expose deploy web --port=80 --target-port=8080

```

### Kubernetes : Services : HeadLess ClusterIP

- `Headless ClusterIP` : 
    - Il n'y pas de load balancing
    - Le service renvoie sur une requête DNS la liste des IP des pods et non pas l'ip du service
    - Le service donc envoi les requêtes sur les pods même ceux-ci ne fonctionnent pas
    - C'est donc à l'application de gérer la tolérance de panne et le routing

![](images/headlessClusterIP.png)


### Kubernetes : Services : HeadLess ClusterIP

```yaml

apiVersion: v1
kind: Service
metadata:
  name: my-headless-service
spec:
  clusterIP: None # <--
  selector:
    app: test-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```


```console
# déploiement 

kubectl create deployment web --image=nginx

# service

kubectl expose deploy web --port=80 --target-port=8080  --cluster-ip none

```



### Kubernetes : Services : NodePort

- `NodePort` : 
    - chaque noeud du cluster ouvre un port statique (entre 30000-32767 par défaut) et redirige le trafic vers le port indiqué
    - Un service de type ClusterIP est créé automatiquement lors de la création du Service NodePort
    - Expose le service au trafic externe
    - Expose le service sur un port sur chaque nœud du cluster
    - Pb : le code doit être changé pour accéder au bon n° de port

![](images/nodePort.png)

### Kubernetes : Services : NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: my-nginx
```

```console
# déploiement 

kubectl create deployment web --image=nginx

# service

kubectl expose deploy web --type NodePort --protocol TCP --port 80 --target-port 8080

```


### Kubernetes : Services : LoadBalancer

- `LoadBalancer` :  expose le service à l'externe en utilisant le loadbalancer d'un cloud provider (AWS, Google, Azure)
    - Expose des services au trafic externe
    - Expose le service sur chaque nœud (comme NodePort)
    - Fournit un équilibreur de charge


### Kubernetes : Services : LoadBalancer


```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  ports:
    - port: 9000
      targetPort: 1234
  selector:
    app: myapp
  type: LoadBalancer
```

```console
# déploiement 

kubectl create deployment web --image=myapp

# service

kubectl expose deploy web --type LoadBalancer --protocol TCP --port 9000 --target-port 1234

```


### Kubernetes : Services : ExternalName

- `ExternalName`
    - Un alias vers un service externe en dehors du cluster
    - La redirection se produit au niveau DNS, il n'y a aucune proxyfication ou forward


### Kubernetes : Services : ExternalName

Il est aussi possible de mapper un service avec un nom de domaine en spécifiant le paramètre `spec.externalName`.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```
### Kubernetes : Services Discovery

- Kubernetes prend en charge 2 modes principaux de "service discovery"
    - Variables d'environnement
    - DNS
- Variables d'environnement
    - {SERVICE_NAME} _SERVICE_HOST
    - {SERVICE_NAME} _SERVICE_PORT
- DNS
    - Ensemble d'enregistrements DNS pour chaque service

### Kubernetes : Services Discovery

- Exemple
    - Active service : my-app
    - Variables d'environment 
        - MY_APP_SERVICE_HOST=`<Cluster IP Address>`
        - MY_APP_SERVICE_PORT=`<Service Port>`

### Kubernetes : Services Discovery


- exemple :

```console
kubectl get svc
web   ClusterIP   10.96.163.5     <none>        80/TCP     3m56s

kubectl exec web-96d5df5c8-lfmhs env | sort
WEB_PORT=tcp://10.96.163.5:80
WEB_PORT_80_TCP=tcp://10.96.163.5:80
WEB_PORT_80_TCP_ADDR=10.96.163.5
WEB_PORT_80_TCP_PORT=80
WEB_PORT_80_TCP_PROTO=tcp
WEB_SERVICE_HOST=10.96.163.5
WEB_SERVICE_PORT=80


```


### Kubernetes : Services Discovery

- Exemple
    name: my-app 
    namespace: default 
    - Les application dans les pods peuvent utiliser le nom `my-app` comme nom d'hôte dans le même `namespace`
    - Les application dans les pods peuvent utiliser le nom `my-app.default` comme nom d'hôte dans d'autres `namespace`

- Syntaxe FQDN - `<svc name>`.`<ns>`.`svc`.`cluster`.`local`

ex: my-app.default.svc.cluster.local

### Kubernetes: Ingress

- L'objet `Ingress` permet d'exposer un service à l'extérieur d'un cluster Kubernetes
- Il sont faits pour les services de type HTTP (et pas pour UDD et TCP)
- Il permet de fournir une URL visible permettant d'accéder un Service Kubernetes
- Il permet d'avoir des terminations TLS, de faire du _Load Balancing_, etc...
- Ils ont besoin d'un _ingress Controller_ pour fonctionner
  
![](images/ingress.png)


### Kubernetes : Ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: blog
spec:
  rules:
  - host: blog.alterway.fr
    http:
      paths:
      - path: /
        backend:
          serviceName: blog-nodeport
          servicePort: 80
```

### Kubernetes : Ingress Controller

Pour utiliser un `Ingress`, il faut un Ingress Controller. Il existe plusieurs offres sur le marché :

- Traefik : <https://github.com/containous/traefik>
- Istio : <https://github.com/istio/istio>
- Linkerd : <https://github.com/linkerd/linkerd>
- Contour : <https://www.github.com/heptio/contour/>
- Nginx Controller : <https://github.com/kubernetes/ingress-nginx>


