# KUBERNETES : Réseau, Services & Découverte DNS {-}

### Le Problème : Les Adresses IP des Pods Sont Mortelles !

```
 [ Pod Web 1 (10.244.1.42) ] ──► (Meurt) ──► [ Nouveau Pod (10.244.2.89) ]
                                                   ▲
                                                   │
  "Comment le Frontend peut-il joindre le Backend si son IP change sans cesse ?"
```

- **La Solution : L'Objet Service**
  - Fournit une **IP Virtuelle stable (ClusterIP)** qui ne change jamais.
  - Fournit un **Nom DNS interne** résolu par CoreDNS.
  - Répartit la charge (Load Balancing L4) vers tous les Pods sains correspondants.

![](images/kubernetes/k8s_service.jpg){height="220px"}

### 1. La Découverte DNS Interne (CoreDNS)

Chaque Service enregistré reçoit automatiquement un nom DNS FQDN :

```
             ┌──────────────────────────────────────────────────┐
             │       mon-service.mon-namespace.svc.cluster.local│
             └───────────────┬──────────────────────────────────┘
                                       │
                 ┌─────────────────────┼───────────────────────┐
                 ▼                     ▼                       ▼
        [ Mêmes Namespace ]    [ Autre Namespace ]      [ FQDN Complet ]
        "curl mon-service"    "curl mon-service.prod".  "curl mon-service.prod.svc..."
```

### 2. Les 4 Types de Services Kubernetes

```
                      [ LoadBalancer ]          (Cloud Public : AWS NLB / GCP LB)
                             │
                             ▼
                        [ NodePort ]            (Port 30000-32767 sur chaque Nœud)
                             │
                             ▼
                       [ ClusterIP ]            (IP Virtuelle interne au Cluster)
                             │
                             ▼
             [ Pod 1 ]   [ Pod 2 ]   [ Pod 3 ]
```

### Typologie Détaillée des Services

| Type de Service | Portée | Adresse IP | Cas d'Usage |
| :--- | :--- | :--- | :--- |
| **`ClusterIP`** (Défaut) | Interne au cluster | IP Virtuelle interne | Communication Est-Ouest (API $\leftrightarrow$ BDD) |
| **`Headless`** (`clusterIP: None`) | Interne | Aucune VIP (DNS direct vers les IPs des Pods) | StatefulSets, Kafka, Elasticsearch |
| **`NodePort`** | Accessible depuis l'extérieur | Port élevé (`30000-32767`) | Dev local, passerelles bare-metal |
| **`LoadBalancer`** | Public Internet | IP Publique Cloud managée | Exposition externe principale d'un cluster Cloud |
| **`ExternalName`** | Interne $\rightarrow$ Externe | Alias CNAME DNS | Rediriger vers une BDD managée (ex: RDS AWS) |

### 3. Sous le Capot : Les `Endpoints` & `EndpointSlice`

Comment le Service sait-il où envoyer le trafic ?

```
[ Service (port: 80) ] ──► [ EndpointSlice ] ──► [ Pod 1: 10.244.1.15:8080 ]
   (Sélecteur: app=web)                             [ Pod 2: 10.244.2.20:8080 ]
```

```bash
# Vérifier la liste des pods réellement connectés au service
kubectl get endpoints mon-service
kubectl get endpointslices -l kubernetes.io/service-name=mon-service
```

- Si `kubectl get endpoints` renvoie `<none>`, aucun pod ne recevra jamais de trafic !

### Manifeste YAML Type d'un Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: bookstore-backend
spec:
  type: ClusterIP
  selector:
    app: bookstore
    tier: backend
  ports:
    - name: http
      protocol: TCP
      port: 80         # Le port exposé par le Service
      targetPort: 8080 # Le port réel écouté dans le conteneur du Pod
```

### Mini-Défi : Le Service Fantôme

**Incident SRE** : Vous créez un Service `auth-service` pour exposer 3 Pods. 
Lorsque vous faites `curl auth-service` depuis un autre Pod, la requête renvoie instantanément : `Connection refused`.

Quand vous tapez `kubectl get endpoints auth-service`, la colonne `ENDPOINTS` affiche `<none>`.

Quelles sont les 2 causes les plus probables ?


### Mini-Défi : Le Service Fantôme

**Incident SRE** : Vous créez un Service `auth-service` pour exposer 3 Pods. 
Lorsque vous faites `curl auth-service` depuis un autre Pod, la requête renvoie instantanément : `Connection refused`.

Quand vous tapez `kubectl get endpoints auth-service`, la colonne `ENDPOINTS` affiche `<none>`.

Quelles sont les 2 causes les plus probables ?

**Réponses** :

1. Le sélecteur de labels du Service ne correspond pas aux labels des Pods.
2. Les Pods ne passent pas leurs Readiness Probes (Pods non `Ready`), donc Kubernetes les a retirés des Endpoints.

