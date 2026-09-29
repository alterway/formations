### Exercice 22/30 : Échec de résolution FQDN individuel d'un StatefulSet par désalignement de `serviceName` (Niveau : Avancé)

* **Objectif :** Diagnostiquer une rupture de la découverte de pairs (*peer discovery*) dans un StatefulSet causée par la mauvaise association entre la ressource StatefulSet et son Service Headless.
* **Contexte :** Une base de données distribuée est déployée en StatefulSet. Chaque nœud doit pouvoir joindre ses pairs via leur nom de domaine pleinement qualifié (FQDN stable de type `<pod-name>.<service-name>.<namespace>.svc.cluster.local`). Les instances sont `Running`, mais l'initialisation du cluster échoue car les Pods ne parviennent pas à se résoudre entre eux par leur nom réseau individuel.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le champ "serviceName" du StatefulSet pointe vers "db-wrong-svc", alors que le Service Headless créé s'appelle "db-headless-svc".
# Résultat : CoreDNS ne génère pas les enregistrements DNS individuels de type "db-cluster-0.db-headless-svc".
apiVersion: v1
kind: Service
metadata:
  name: db-headless-svc
  namespace: default
spec:
  clusterIP: None
  selector:
    app: db-cluster
  ports:
  - port: 27017
    targetPort: 27017
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db-cluster
  namespace: default
spec:
  # ERREUR : Le serviceName ne correspond pas au nom du Service Headless ("db-headless-svc")
  serviceName: "db-wrong-svc"
  replicas: 2
  selector:
    matchLabels:
      app: db-cluster
  template:
    metadata:
      labels:
        app: db-cluster
    spec:
      containers:
      - name: tester
        image: alpine/k8s:1.37.0
        # Tente d'interroger son propre FQDN stable
        command: ["sh", "-c", "until nslookup db-cluster-0.db-headless-svc.default.svc.cluster.local; do echo 'Waiting for Headless DNS record...'; sleep 3; done"]

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: Service
metadata:
  name: db-headless-svc
  namespace: default
spec:
  clusterIP: None
  selector:
    app: db-cluster
  ports:
  - port: 27017
    targetPort: 27017
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db-cluster
  namespace: default
spec:
  # CORRECTION : Le serviceName est strictement aligné sur le metadata.name du Service Headless
  serviceName: "db-headless-svc"
  replicas: 2
  selector:
    matchLabels:
      app: db-cluster
  template:
    metadata:
      labels:
        app: db-cluster
    spec:
      containers:
      - name: tester
        image: alpine/k8s:1.37.0
        command: ["sh", "-c", "until nslookup db-cluster-0.db-headless-svc.default.svc.cluster.local; do echo 'Waiting for Headless DNS record...'; sleep 3; done"]

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter les Pods du StatefulSet : `kubectl get pods` (les Pods sont `Running` mais le conteneur boucle sur l'échec d'initialisation).
2. Vérifier les journaux applicatifs : `kubectl logs db-cluster-0`.
3. Constater l'échec de résolution DNS du FQDN `db-cluster-0.db-headless-svc.default.svc.cluster.local` (`nslookup: can't resolve...`).
4. Vérifier l'existence et la configuration du Service Headless : `kubectl get svc db-headless-svc -o yaml` (`clusterIP: None`).
5. Examiner la spécification du StatefulSet : `kubectl get statefulset db-cluster -o yaml` et vérifier la valeur du champ `spec.serviceName`.
6. Identifier la différence entre `spec.serviceName` (`db-wrong-svc`) et le véritable nom du Service Headless (`db-headless-svc`).
7. Mettre à jour le manifeste et appliquer la correction.

---
