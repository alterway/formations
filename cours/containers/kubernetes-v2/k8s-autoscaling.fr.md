# KUBERNETES : Autoscaling (HPA, VPA, Karpenter & KEDA) {-}

### Les 3 Dimensions de l'Autoscaling

```{.center}
┌─────────────────────────────────────────────────────────────┐
|                                                             |
│ 1. HPA (Horizontal Pod Autoscaler) : Varie le NOMBRE de Pods│
│    [ Pod ] ──► [ Pod ] [ Pod ] [ Pod ] [ Pod ]              |
|                                                             |
├─────────────────────────────────────────────────────────────┤
|                                                             |
| 2. VPA (Vertical Pod Autoscaler) : Varie la TAILLE du Pod   |
│    [ Petit Pod (1 CPU) ] ──► [ GROS Pod (4 CPU) ]           |
|                                                             |
├─────────────────────────────────────────────────────────────┤
|                                                             |
| 3. Cluster Autoscaler / Karpenter : Varie le NOMBRE de NŒUDS|
│    [ Node 1 ] ──► [ Node 1 ] [ Node 2 ] [ Node 3 ]          |
|                                                             |
└─────────────────────────────────────────────────────────────┘
```

### 1. Horizontal Pod Autoscaler (HPA v2)

Le HPA interroge `metrics-server` toutes les 15 secondes pour adapter le nombre de réplicas :

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bookstore-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: bookstore-api
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Vise 70% de la Request CPU
  - type: Resource
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 400Mi
```

### 2. KEDA : Autoscaling Piloté par les Événements

Le CPU/RAM ne suffit plus : comment réagir AVANT que le CPU ne sature ?

```{.center}
[ File RabbitMQ / Kafka ] ──► [ KEDA Controller ] ──► [ HPA K8s ] ──► [ Scale Pods ]
  (10 000 messages en attente)
```

- **KEDA (Kubernetes Event-driven Autoscaling)** permet de scaler sur :
  - La longueur d'une file RabbitMQ / SQS / Redis.
  - Le lag de consommation d'un topic Kafka.
  - Le nombre de requêtes HTTP par seconde (Prometheus metric).
  - **Scale to Zero** : Descendre à 0 Pod quand la file est vide (économies maximales !).

### 3. Provisionnement des Nœuds : Karpenter vs Cluster Autoscaler

Quand 50 nouveaux Pods passent en statut `Pending` faute de place :

- **Cluster Autoscaler standard** : Ajuste les Node Groups Cloud (délai : 2 à 4 minutes).
- **Karpenter (CNCF)** : Provisionneur sans groupe de nœuds, démarre la VM Cloud exacte sur-mesure (Spot/On-Demand) en **moins de 45 secondes** !

### Mini-Défi : Le HPA Aveugle

**Incident SRE** : Vous configurez un HPA sur un Deployment. 
En tapant `kubectl get hpa`, la colonne `TARGETS` affiche obstinément : `<unknown>/70%`.

Quelles sont les 2 causes directes de ce blocage ?


### Mini-Défi : Le HPA Aveugle

**Incident SRE** : Vous configurez un HPA sur un Deployment. 
En tapant `kubectl get hpa`, la colonne `TARGETS` affiche obstinément : `<unknown>/70%`.

Quelles sont les 2 causes directes de ce blocage ?

```bash
# Diagnostic :
kubectl describe hpa bookstore-api-hpa
```

**Réponses** :

1. Le Deployment n'a pas de `resources.requests.cpu` définie (le HPA ne sait pas sur quelle base calculer le pourcentage !).
2. Le composant `metrics-server` n'est pas installé ou ne parvient pas à joindre les Kubelets.

