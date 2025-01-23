# KUBERNETES : Networking

### Kubernetes : Network plugins

- Kubernetes n'implémente pas de solution de gestion de réseau par défaut
- Le réseau est implémenté par des solutions tierces:
    - [Antrea](https://antrea.io/) : Open vSwitch dans kubernetes
    - [Calico](https://www.projectcalico.org/): IPinIP + BGP
    - [Cilium](https://cilium.io/): eBPF
    - [Weave](https://www.weave.works/)
    - [Canal](https://projectcalico.docs.tigera.io/getting-started/kubernetes/flannel/flannel) : Flannel + Calico
    - [Multus](https://github.com/k8snetworkplumbingwg/multus-cni) : Multi Plugins
    - Bien [d'autres](https://kubernetes.io/docs/concepts/cluster-administration/networking/)


### Kubernetes : CNI

- [Container Network Interface](https://github.com/containernetworking/cni)
- Projet dans la CNCF
- Standard pour la gestion du réseau en environnement conteneurisé
- Les solutions précédentes s'appuient sur CNI
- Flexibilité: Il offre une grande flexibilité pour choisir le type de réseau à utiliser (bridge, VLAN, VXLAN, etc.) et les fonctionnalités associées (routage, NAT, etc.).
- Plugin: Un CNI est implémenté sous forme de plugin, ce qui permet de choisir le plugin adapté aux environnements et besoins.

- Rôle d'un CNI dans Kubernetes
    - Création d'interfaces réseau: Lorsqu'un pod est créé, le CNI est appelé pour créer une ou plusieurs interfaces réseau pour les conteneurs du pod.
    - Configuration IP: Le CNI attribue une adresse IP à chaque interface réseau et configure les routes nécessaires.
    - Gestion des réseaux: Le CNI gère la configuration réseau au cours du cycle de vie du pod (création, modification, suppression).

### Kubernetes : POD Networking

![pod network](images/pod-networking.png)

### Kubernetes : Services

- Une abstraction de niveau supérieur qui expose un ensemble de pods sous un nom et une adresse IP stables.
- Permet d'accéder à un groupe de pods de manière uniforme, même si les pods individuels sont créés, mis à jour ou supprimés.
- Rendre un ensemble de pods accessibles depuis l'extérieur
- Load Balancing entre les pods d'un même service

### Kubernetes : Services


![pod network](images/kubernetes/k8s_service.jpg){height="550px"}



### Kubernetes : Services : ClusterIP

- `ClusterIP` : 
    - C'est le service par défaut
    - Attribue une adresse IP interne accessible uniquement au sein du cluster, cette adresse est accessible dans le cluster par les pods et les noeuds
    - Expose le service pour les connexions depuis l'intérieur du cluster 
    - L'application peut utiliser le port de l'application directement

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

```bash
# déploiement 

kubectl create deployment web --image=nginx

# service
# par défaut type= ClusterIP

kubectl expose deploy web --port=80 --target-port=8080

```

### Kubernetes : Services : HeadLess ClusterIP

- `Headless ClusterIP` : 
    - Il n'y pas de load balancing
    - Le service renvoie sur une requête DNS la liste des IP des pods et non pas l'IP du service
    - Le service donc envoi les requêtes sur les pods même ceux-ci ne fonctionnent pas
    - C'est donc à l'application de gérer la tolérance de panne et le routage

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


```bash
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

```bash
# déploiement 

kubectl create deployment web --image=nginx

# service

kubectl expose deploy web --type NodePort --protocol TCP --port 80 --target-port 8080

```


### Kubernetes : Services : LoadBalancer

- `LoadBalancer` :  expose le service à l'externe en utilisant le loadbalancer d'un cloud provider (AWS, Google, Azure)
    - Expose des services au trafic externe
    - Expose le service sur chaque nœud (comme NodePort)
    - Fournit un répartiteur de charge


### Kubernetes : Services : LoadBalancer

Service de type Spécial

- Load Balancing : intégration avec des cloud provider :
    - AWS ELB
    - GCP
    - Azure Kubernetes Service
    - OpenStack
    - ...

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

```bash
# déploiement 

kubectl create deployment web --image=myapp

# service

kubectl expose deploy web --type LoadBalancer --protocol TCP --port 9000 --target-port 1234

```


### Kubernetes : Services : ExternalName

- `ExternalName`
    - Un alias vers un service externe en dehors du cluster
    - La redirection se produit au niveau DNS, il n'y a aucune proxyfication ou forward


Exemples d'utilisation concrets :

- Intégration avec des services tiers:
    - Base de données externe: Vous avez une base de données hébergée sur un service cloud comme AWS RDS. Au lieu d'utiliser l'adresse IP ou l'URL complète, vous pouvez créer un service ExternalName qui pointera vers le nom DNS de cette base de données. Cela facilite la configuration de vos applications dans le cluster.
    - API externe: Vous souhaitez consommer une API publique (comme une API météo ou une API de paiement). En créant un service ExternalName qui pointe vers l'URL de cette API, vous pouvez y accéder depuis vos pods comme si c'était un service interne.
- Migration progressive:
    - Transition vers un nouveau service: Vous êtes en train de migrer vers un nouveau service et souhaitez maintenir l'ancien pendant un certain temps. Vous pouvez créer un service ExternalName qui pointera alternativement vers l'ancien ou le nouveau service, selon votre configuration.
- Abstraction de noms DNS complexes:
    - Noms DNS longs ou difficiles à retenir: Si vous avez des noms DNS très longs ou complexes, un service ExternalName peut servir d'alias plus court et plus facile à mémoriser.
- Microservices: 
    - Simplifie les interactions entre différents microservices qui peuvent être déployés sur des infrastructures différentes.
- Tests: 
    - Permet de simuler des environnements de test en pointant vers des services de test.

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

En ligne de commande :

```bash
kubectl create service externalname my-service --external-name  my.database.example.com

```

    


### Kubernetes : Services : External IPs

On peut définir une IP externe permettant d'accèder à un service interne

```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
spec:
  externalIPs:
  - 1.2.3.4
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
```

En ligne de commande : 

```bash
kubectl expose deploy nginx --port=80 --external-ip=1.2.3.4

```

### Kubernetes : Services Résumé

- `ClusterIP` : C'est le type de service par défaut. Il fournit une IP virtuelle stable accessible uniquement à l'intérieur du cluster, parfait pour la communication entre microservices.
  
- `NodePort` : Il étend ClusterIP en exposant le service sur un port spécifique de chaque nœud du cluster. C'est utile pour le développement ou les environnements de test.
  
- `LoadBalancer` : Idéal pour la production, il étend NodePort en provisionnant automatiquement un load balancer externe (souvent fourni par le cloud provider).
  
- `ExternalName` : Un cas particulier qui permet de créer un alias CNAME vers un service externe au cluster.
  
- `Headless Service` : Utilisé quand vous avez besoin d'une découverte de service fine, sans Load Balancing. Très utile pour les bases de données distribuées.
  
- `ExternalIPs` : Permet d'exposer un service Kubernetes sur une adresse IP spécifique qui existe déjà sur l'un des nœuds du cluster, offrant ainsi un accès direct depuis l'extérieur sans passer par un LoadBalancer.

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
    - Variables d'environnement 
        - MY_APP_SERVICE_HOST=`<Cluster IP Address>`
        - MY_APP_SERVICE_PORT=`<Service Port>`

### Kubernetes : Services Discovery


- exemple :

```bash
kubectl get svc
web   ClusterIP   10.96.163.5     <none>        80/TCP     3m56s

kubectl exec web-96d5df5c8-lfmhs -- env | sort
...

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
- Il sont faits pour les services de type HTTP (et pas pour UDP et TCP)
- Il permet de fournir une URL visible permettant d'accéder un Service Kubernetes
- Il permet d'avoir des terminations TLS, de faire du _Load Balancing_, etc...
- Ils ont besoin d'un _ingress Controller_ pour fonctionner
  
![](images/ingress.png)


### Kubernetes : Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: le
    meta.helm.sh/release-name: argocd
    meta.helm.sh/release-namespace: argocd
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/instance: argocd
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
    app.kubernetes.io/version: v2.10.1
    helm.sh/chart: argo-cd-6.0.14
  name: argocd-server
  namespace: argocd
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.caas.fr
    http:
      paths:
      - backend:
          service:
            name: argocd-server
            port:
              number: 443
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - argocd.caas.fr
    secretName: argocd-server-tls
```

### Kubernetes : Ingress Controller

Pour utiliser un `Ingress`, il faut un `Ingress Controller`

Il existe plusieurs solutions OSS ou non :

- Traefik : <https://github.com/containous/traefik>
- Istio : <https://github.com/istio/istio>
- Linkerd : <https://github.com/linkerd/linkerd>
- Contour : <https://www.github.com/heptio/contour/>
- Nginx Controller : <https://github.com/kubernetes/ingress-nginx>

⚠︎ Note : Il est possible d'avoir plusieurs `Ingress Controller` sur un cluster il suffira dans les objets ingress de préciser sur quelle classe d'ingress on souhaite le créer.

Ca se fait par l'attribut `ingressClassName`. 

Ces classes sont créees au moment de l'installation du contrôleur.

Les **Ingress** vont bientôt être dépréciés en faveur des `Gateway API` qui sont la nouvelle génération de Kubernetes Ingress, Load Balancing, et Service Mesh APIs.

Plus d'informations ici : <https://gateway-api.sigs.k8s.io/>


### Kubernetes : Gateway API

Les Gateway APIs sont une évolution des Ingress Controllers, offrant une approche plus moderne et flexible pour gérer le trafic entrant dans un cluster Kubernetes. Voici les points essentiels :

Architecture en layers:

- GatewayClass : Définit l'implémentation (comme NGINX, Traefik, etc.)
- Gateway : Instance spécifique qui gère le trafic entrant
- Route : Définit les règles de routage (HTTP, TCP, etc.)


Avantages principaux:

    - Configuration plus fine et granulaire
    - Support natif de plusieurs protocoles
    - Meilleure séparation des responsabilités
    - API plus extensible et cohérente


Cas d'utilisation:

    - Multi-tenancy avec isolation du trafic
    - Gestion avancée du routage
    - Configuration du TLS
    - Gestion du trafic nord-sud et est-ouest


Différence avec les Ingress:

Les Gateway APIs offrent plus de fonctionnalités que les Ingress traditionnels :

    - Support multi-protocole natif
    - Meilleure extensibilité
    - Configuration plus détaillée
    - Meilleure séparation des rôles


### Kubernetes : Gateway API

![](images/kubernetes/gateway-api-resources.png)



En savoir plus :[Evolving Kubernetes networking with the Gateway API](https://kubernetes.io/blog/2021/04/22/evolving-kubernetes-networking-with-the-gateway-api/)  

 
 ---
     
   