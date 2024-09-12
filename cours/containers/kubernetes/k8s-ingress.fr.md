# Exposer les services HTTP avec les ressources Ingress

### Exposer les services HTTP avec les ressources Ingress

- Les services nous permettent d'accéder à un pod ou à un ensemble de pods

- Les services peuvent être exposés au monde extérieur:
    - avec le type NodePort (sur un port> 30000)
    - avec le type LoadBalancer (allocation d'un répartiteur de charge externe)

- Qu'en est-il des services HTTP?


### Exposer les services HTTP

Si nous utilisons les services `NodePort`, les clients doivent spécifier les numéros de port

(c'est-à-dire http: // xxxxx: 31234 au lieu de simplement http: // xxxxx)

Les services `LoadBalancer` sont bien, mais:

- ils ne sont pas disponibles dans tous les environnements

- ils entraînent souvent un coût supplémentaire (par exemple, ils fournissent un ELB)

- ils nécessitent une étape supplémentaire pour l'intégration DNS
(en attendant que le `LoadBalancer` soit provisionné; puis en l'ajoutant au DNS)


### Ressources Ingress

- Ressource API Kubernetes (`kubectl get ingress / ingresses / ing`)

- Conçu pour exposer les services HTTP

- Caractéristiques de base:
    - l'équilibrage de charge
    - Terminaison SSL
    - vhost basé sur le nom
    - Peut également router vers différents services en fonction de:
        - Chemin URI (par exemple / api → api-service, / static → assets-service)
        - En-têtes client, y compris les cookies (pour les tests A / B, déploiement canary ...)
        - ...

### Principe de fonctionnement

- Étape 1: déployer un `Ingress Controller`

Ingress Controller = répartiteur de charge + boucle de contrôle

La boucle de contrôle surveille les Objects `Ingress` et configure le LB en conséquence

- Étape 2: configurer le DNS

Associer les entrées DNS à l'adresse du LB


- Étape 3: créer des Ingress

L'`Ingress Controller` prend ces ressources et configure le LB (load balancer)

- Étape 4: Votre Site est prêt à être utilisé !


### À quoi ressemble une ressource Ingress?


Un exemple simple

```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: podinfo-ing
  namespace: podinfo
spec:
  ingressClassName: nginx
  rules:
  - host: podinfo.formation.com
    http:
      paths:
      - backend:
          service:
            name: podinfo
            port:
              number: 9898
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - podinfo.formation.com
    secretName: podinfo.formation.com-tls
```

