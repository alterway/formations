# KUBERNETES : Observabilité & Monitoring (Métriques & Traces) {-}

### Les 3 Piliers de l'Observabilité Cloud Native

```
            ┌───────────────────────────────────────────────┐
            │               OBSERVABILITÉ                   │
            │                                               │
            │   [ MÉTRIQUES ]   [ LOGS ]     [ TRACES ]     │
            │    Prometheus      Loki      OpenTelemetry    │
            │   (Tendances)   (Détails)     (Parcours)      │
            └───────┬─────────────┬──────────────┬──────────┘
                    └─────────────┼──────────────┘
                                  ▼
                        [ GRAFANA DASHBOARDS ]
```

![](images/kubernetes/dashboard-0.png){height="220px"}

### 1. La Pile Prometheus & Grafana

Prometheus collecte les métriques par **Pull (Scraping HTTP)** à intervalles réguliers :

```
[ Pod Applicatif ] ──► Expose /metrics (format Prometheus)
                             ▲
                             │ (Scrape toutes les 15s)
[ Prometheus Operator ] ─────┴──► Enregistre dans la base TSDB
                             │
                             ▼
[ Grafana Dashboard ] ◄─────── (Requêtes PromQL)
```

- **`kube-state-metrics`** : Génère des métriques sur l'état des objets K8s (nombre de pods en Pending, réplicas désirés vs réels).
- **`node-exporter`** : Métriques matérielles des nœuds (CPU, RAM, I/O disque, réseau).

### Le ServiceMonitor (Prometheus Operator)

Ne configurez plus Prometheus à la main ! Déclarez le scraping en YAML :

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: bookstore-monitor
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: bookstore
  endpoints:
  - port: metrics
    interval: 15s
    path: /metrics
```

### 2. Tracing Distribué avec OpenTelemetry (OTel)

Comment identifier quel microservice ralentit une transaction utilisateur sur 15 étapes ?

```
[ Client ] ──► [ Frontend ] (20ms)
                   │
                   ▼
               [ Auth API ] (15ms)
                   │
                   ▼
               [ Payment Gateway ] ──► (Bloqué 3.2s sur la banque !)
```

- **OpenTelemetry Collector** reçoit les traces (spans), corrèle les contextes distribués (`traceparent`) et les stocke dans **Jaeger** ou **Grafana Tempo**.

### 3. Monitoring CLI Temps Réel : `k9s` & `kubectl top`

```bash
# Vérifier la consommation réelle instantanée
kubectl top nodes
kubectl top pods -A --sort-by=memory

# Ouvrir k9s (TUI interactif pour naviguer dans les pods, logs et métriques)
k9s
```

### Mini-Défi : Alerte PromQL

**Question SRE** : Vous devez écrire une règle d'alerte pour être réveillé uniquement si le taux d'erreur 5xx de votre API dépasse 5% pendant 5 minutes.

```promql
# Requête PromQL experte :
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m])) * 100 > 5
```
