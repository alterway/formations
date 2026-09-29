### Exercice 19/30 : Éviction de Pod bloquée par un `PodDisruptionBudget` (PDB) trop restrictif (Niveau : Avancé)

* **Objectif :** Diagnostiquer et débloquer un blocage d'éviction de Pod lors d'une opération de maintenance ou de roulement d'instance, causé par un `PodDisruptionBudget` (PDB) mal dimensionné.
* **Contexte :** Une opération de maintenance (ou un *drain* de nœud / renouvellement de composants) est déclenchée sur le vcluster. Cependant, l'éviction du Pod d'un composant critique est refusée systématiquement par l'API Server.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le PDB impose "minAvailable: 1" pour un déploiement qui ne compte qu'une seule réplique (replicas: 1).
# Résultat : L'API Server interdit formellement toute éviction ou suppression temporaire du Pod.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
      - name: auth
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: auth-service-pdb
  namespace: default
spec:
  # ERREUR : Exiger 1 Pod disponible au minimum sur un total de 1 réplique empêche 100 % des évictions
  minAvailable: 1
  selector:
    matchLabels:
      app: auth-service

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# Option de correction A : Augmenter le nombre de répliques pour autoriser la haute disponibilité réelle (Recommandé).
# Option de correction B : Utiliser "maxUnavailable: 1" si une seule réplique doit être maintenue.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: default
spec:
  # CORRECTION : Passage à 2 répliques minimum pour garantir la continuité de service lors d'un drain
  replicas: 2
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
      - name: auth
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: auth-service-pdb
  namespace: default
spec:
  # CORRECTION : Avec 2 répliques, minAvailable: 1 autorise l'éviction de l'un des deux Pods pendant la maintenance
  minAvailable: 1
  selector:
    matchLabels:
      app: auth-service

```

**Démarche de résolution pour l'apprenant :**

1. Tenter d'évincer ou de drainer le Pod : `kubectl drain <node-name> --ignore-daemonsets` ou via l'API d'éviction.
2. Intercepter le message d'erreur retourné par l'API : `Cannot evict pod "auth-service-..." as it would violate the pod's disruption budget`.
3. Inspecter les règles PDB définies dans le namespace : `kubectl get pdb`.
4. Consulter les détails du PDB : `kubectl describe pdb auth-service-pdb`.
5. Constater que la valeur `ALLOWED DISRUPTIONS` est à `0` (car `CURRENT` = 1, `DESIRED` = 1, `MIN AVAILABLE` = 1).
6. Répondre au problème soit en augmentant le nombre de répliques du `Deployment` à 2 (pour qu'au moins un Pod reste actif en cas de relance), soit en assouplissant le PDB (`maxUnavailable: 1`).

---
