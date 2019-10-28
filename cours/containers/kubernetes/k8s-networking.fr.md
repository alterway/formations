# Kubernetes : Networking

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

### Kubernetes : Services

- Abstraction des pods sous forme d'une VIP de service
- Rendre un ensemble de pods accessibles depuis l'extérieur
- Load Balancing entre les pods d'un même service

### Kubernetes : Services

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCP
    - Azure Kubernetes Service
    - OpenStack
- `NodePort` : chaque noeud du cluster ouvre un port  statique et redirige le trafic vers le port indiqué
- `ClusterIP` : IP dans le réseau privé Kubernetes (VIP)
- `LoadBalancer` :  expose le service à l'externe en utilisant le loadbalancer d'un cloud provider (AWS, Google, Azure)

### Kubernetes : Services

![](images/services.png)


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


### Kubernetes: Ingress

- L'objet `Ingress` permet d'exposer un service à l'extérieur d'un cluster Kubernetes
- Il permet de fournir une URL visible permettant d'accéder un Service Kubernetes
- Il permet d'avoir des terminations TLS, de faire du _Load Balancing_, etc...


### Kubernetes : Ingress

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: osones
spec:
  rules:
  - host: blog.osones.com
    http:
      paths:
      - path: /
        backend:
          serviceName: osones-nodeport
          servicePort: 80
```

### Kubernetes : Ingress Controller

Pour utiliser un `Ingress`, il faut un Ingress Controller. Il existe plusieurs offres sur le marché :

- Traefik : <https://github.com/containous/traefik>
- Istio : <https://github.com/istio/istio>
- Linkerd : <https://github.com/linkerd/linkerd>
- Contour : <https://www.github.com/heptio/contour/>
- Nginx Controller : <https://github.com/kubernetes/ingress-nginx>


