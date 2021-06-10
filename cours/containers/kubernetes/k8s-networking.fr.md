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

- Abstraction des pods sous forme d'une IP virtuelle de service et d'un nom DNS
- Rendre un ensemble de pods accessibles depuis l'extérieur
- Load Balancing entre les pods d'un même service

### Kubernetes : Services

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCP
    - Azure Kubernetes Service
    - OpenStack

### Kubernetes : Services : ClusterIP

- `ClusterIP` : 
    - C'est le service par défaut
    - Attribue une adresse IP interne accessible uniquement au sein du cluster, cette adresse est accessible dans le cluster par les pods et les noeuds
    - Expose le service pour les connexions depuis l'intérieur du cluster 

![](images/clusterIP.png)

### Kubernetes : Services : NodePort

- `NodePort` : 
    - chaque noeud du cluster ouvre un port statique (entre 30000-32767 par défaut) et redirige le trafic vers le port indiqué
    - Expose le service au trafic externe
    - Expose le service sur un port sur chaque nœud du cluster
    - Pb : le code doit être changé pour accéder au bon n° de port

![](images/nodePort.png)

### Kubernetes : Services : LoadBalancer

- `LoadBalancer` :  expose le service à l'externe en utilisant le loadbalancer d'un cloud provider (AWS, Google, Azure)
    - Expose des services au trafic externe
    - Expose le service sur chaque nœud (comme NodePort)
    - Fournit un équilibreur de charge

### Kubernetes : Services : ExternalName

- `ExternalName`
    - Un alias vers un service externe en dehors du cluster
    - La redirection se produit au niveau DNS, il n'y a aucune proxyfication ou forward

### Kubernetes : Services

![](images/services-userspace-overview.svg){height="700"}

### Kubernetes : Services

- Exemple de service (on remarque la sélection sur le label et le mode d'exposition):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  type: NodePort
  ports:
  - port: 80
  selector:
    app: guestbook
    tier: frontend
```


### Kubernetes : Services

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


