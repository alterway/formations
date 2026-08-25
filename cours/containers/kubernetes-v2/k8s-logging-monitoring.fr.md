# KUBERNETES : Centralisation des Logs (Loki, Fluent Bit & Vector) {-}

### Le Flux des Logs dans Kubernetes

```
 [ Pod Container ] ──► Écrit sur stdout / stderr
                             │
                             ▼ (Géré par le CRI : containerd)
  Fichier JSON local : /var/log/pods/<namespace>_<pod>_<uid>/...
                             │
                             ▼ (Scrapé par un DaemonSet sur le Nœud)
               [ Fluent Bit / Promtail / Vector ]
                             │
                             ▼ (Envoi compressé)
               [ Grafana Loki / OpenSearch ]
```

![](images/kubernetes/ui-dashboard-logs-view.png){height="220px"}

### 1. Pourquoi stdout/stderr est la Règle d'Or ?

- Les conteneurs doivent **toujours** écrire leurs logs sur la sortie standard (`stdout`) et la sortie d'erreur standard (`stderr`).
- `containerd` capture ces flux, gère la rotation automatique des fichiers sur le disque du nœud hôte et les expose via `kubectl logs`.

```bash
# Consulter les logs en direct d'un Pod
kubectl logs -f deployment/bookstore-api

# Voir les logs d'un conteneur spécifique dans un Pod multi-conteneurs
kubectl logs pod-avec-sidecar -c mon-application

# Consulter les logs du conteneur AVANT son dernier crash (Indispensable !)
kubectl logs mon-pod -p
```

### 2. Le Modèle de Collecte : DaemonSet vs Sidecar

| Modèle | Consommation Ressources | Complexité | Cas d'Usage Recommandé |
| :--- | :--- | :--- | :--- |
| **DaemonSet (Node-level)** | **Très faible** (1 seul agent par serveur physique) | Simple et transparent pour les devs | **95% des cas en production** (Fluent Bit, Vector) |
| **Sidecar (Pod-level)** | Élevée (1 conteneur en plus par Pod) | Spécifique | Applications legacy écrivant dans un fichier rigide `/var/log/app.log` |

### 3. La Stack Moderne : Grafana Loki & LogQL

Contrairement à ElasticSearch qui indexe l'intégralité du texte des logs (gourmand en RAM/Disque), **Grafana Loki** indexe uniquement les métadonnées (labels K8s) :

```logql
# Requête LogQL pour filtrer les erreurs 500 sur le namespace production
{namespace="production", app="bookstore"} |= "ERROR" | json | status_code >= 500
```

### Mini-Défi : Le Crash Mystère

**Incident SRE** : Un Pod s'est crashé il y a 30 secondes et vient d'être recréé par son ReplicaSet. 
Quand vous tapez `kubectl logs mon-pod`, vous ne voyez que 2 lignes de démarrage, les logs de l'erreur qui a causé la mort du pod ont disparu.

Quelle option magique de `kubectl logs` permet de voir les derniers instants du conteneur décédé ?


### Mini-Défi : Le Crash Mystère

**Incident SRE** : Un Pod s'est crashé il y a 30 secondes et vient d'être recréé par son ReplicaSet. 
Quand vous tapez `kubectl logs mon-pod`, vous ne voyez que 2 lignes de démarrage, les logs de l'erreur qui a causé la mort du pod ont disparu.

Quelle option magique de `kubectl logs` permet de voir les derniers instants du conteneur décédé ?

(Réponse : `kubectl logs mon-pod --previous` ou `kubectl logs mon-pod -p`).

