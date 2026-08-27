# KUBERNETES : Ingress & Gateway API (Routage L7) {-}

### Le Problème : 50 Microservices = 50 Load Balancers Payants ?

```
          APPROCHE NAÏVE (L4)                           APPROCHE INGRESS / L7
 50 Services type LoadBalancer                 1 SEUL Load Balancer Cloud Public
  = 50 IP publiques à payer                     = 1 seule IP, routage L7 intelligent
  = Facture Cloud x50 !                         = Répartition par nom de domaine & URL !
```

- **Ingress Controller** : Le proxy inverse (NGINX, Traefik, Envoy, HAProxy) qui écoute le trafic mondial.
- **Ressource Ingress** : La règle déclarative qui indique à quel Service envoyer chaque URL.

![](images/kubernetes/gateway-api-resources.png){height="220px"}

### 1. Ingress Class & Contrôleurs

1. Déployer un **Ingress Controller** (ex: `ingress-nginx`).
2. Déclarer une **`IngressClass`** pour indiquer quel contrôleur doit interpréter vos règles.
3. Créer vos objets **`Ingress`** applicatifs.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bookstore-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod # TLS automatique !
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - store.formation.com
    secretName: bookstore-tls-cert
  rules:
  - host: store.formation.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-api-svc
            port:
              number: 8080
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-ui-svc
            port:
              number: 80
```

### 2. Automatisation TLS : `cert-manager`

Fini les certificats SSL expirés un dimanche soir à 23h !

```{.center}
[ Ingress avec annotation ] ──► [ cert-manager ] ──► [ Let's Encrypt API ]
                                     |
                                     │ (Challenge HTTP-01 / DNS-01)
                                     ▼
                        [ Secret TLS auto-renouvelé ]
```

### 3. Le Futur Est Là : La Gateway API

La **Gateway API** est le successeur officiel de l'Ingress standard, conçu pour les architectures modernes et la séparation des responsabilités :

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│ ÉQUIPE INFRA / CLOUD (Cluster Admin)                        │
│  ► GatewayClass : Définit le fournisseur (Envoy, Cilium...) │
│  ► Gateway : Déclare le point d'entrée, IP et ports 80/443  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ÉQUIPE DÉVELOPPEMENT / APPLICATION                          │
│  ► HTTPRoute : Règle de routage autonome par namespace      │
│  ► GRPCRoute / TCPRoute : Support natif au-delà du HTTP !   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

- **Avantages clés** : Séparation des rôles (RBAC granulaire), routage multi-namespaces, splitting de trafic natif (Canary / Blue-Green) sans annotations constructeur obscures !

### Mini-Défi : Diagnostic d'une Erreur 502 / 503

**Incident SRE** : Un utilisateur essaie de joindre `https://store.formation.com/api` et obtient une erreur `502 Bad Gateway` de la part d'Ingress Nginx.

Quelle est la démarche méthodique d'investigation ?



### Mini-Défi : Diagnostic d'une Erreur 502 / 503

**Incident SRE** : Un utilisateur essaie de joindre `https://store.formation.com/api` et obtient une erreur `502 Bad Gateway` de la part d'Ingress Nginx.

Quelle est la démarche méthodique d'investigation ?

```bash
# 1. Vérifier si l'Ingress pointe vers un service existant
kubectl describe ingress bookstore-ingress

# 2. Vérifier si le Service a des Pods Endpoints actifs
kubectl get endpoints backend-api-svc

# 3. Vérifier les logs du contrôleur Ingress en temps réel
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=50
```

