### Exercice 26/30 : Interblocage d'ordonnancement (*Scheduling Deadlock*) par Anti-Affinité stricte (Niveau : Avancé / Expert)

* **Objectif :** Diagnostiquer et corriger un blocage de planification (*scheduling*) causé par une règle de `podAntiAffinity` stricte (`requiredDuringSchedulingIgnoredDuringExecution`) incompatible avec le nombre de nœuds disponibles.
* **Contexte :** Un composant hautement disponible doit être déployé sur 3 répliques. Le développeur a configuré une anti-affinité stricte pour garantir qu'aucun Pod ne tourne sur le même nœud physique. L'application reste partiellement déployée : 2 Pods sont `Running`, mais le 3ᵉ reste bloqué indéfiniment en `Pending`.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le cluster ne compte que 2 nœuds (ou le vcluster ne voit que 2 nœuds), mais le Deployment exige 3 répliques avec une anti-affinité HARDE (required...).
# Résultat : Le 3ᵉ Pod ne trouve aucun nœud éligible et reste en Pending.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ha-redis
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ha-redis
  template:
    metadata:
      labels:
        app: ha-redis
    spec:
      affinity:
        podAntiAffinity:
          # ERREUR : La contrainte stricte (required) empêche l'ordonnancement dès que replicas > nombre de nœuds
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - ha-redis
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ha-redis
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ha-redis
  template:
    metadata:
      labels:
        app: ha-redis
    spec:
      affinity:
        podAntiAffinity:
          # CORRECTION : Passage en anti-affinité souple (preferred) pour favoriser la répartition sans bloquer le scheduling si le nombre de nœuds est inférieur
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - ha-redis
              topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter l'état du déploiement : `kubectl get pods -o wide`.
2. Observer que 2 Pods sont `Running` sur des nœuds distincts et que le 3ᵉ est bloqué en `Pending`.
3. Inspecter les événements du Pod bloqué : `kubectl describe pod <nom-du-pod-pending>`.
4. Lire le message du scheduler : `0/2 nodes are available: 2 node(s) didn't match pod anti-affinity rules`.
5. Compter le nombre de nœuds disponibles dans le cluster : `kubectl get nodes`.
6. Conclure qu'une règle de type `requiredDuringSchedulingIgnoredDuringExecution` avec `replicas: 3` nécessite au minimum 3 nœuds physiques distincts.
7. Corriger le manifeste en transformant la contrainte en anti-affinité souple (`preferredDuringSchedulingIgnoredDuringExecution`) ou en utilisant des `topologySpreadConstraints` avec `whenUnsatisfiable: ScheduleAnyway`.

---
