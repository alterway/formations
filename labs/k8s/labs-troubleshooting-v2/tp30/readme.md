### Exercice 30/30 : Timeouts et pertes de trafic via un Service NodePort avec `externalTrafficPolicy: Local` (Niveau : Ultra compliqué / Expert)

* **Objectif :** Diagnostiquer et corriger une perte intermittente de connectivité réseau externe causée par la politique de routage du proxy Kubernetes (`kube-proxy`) lorsqu'un Service est configuré en `externalTrafficPolicy: Local`.
* **Contexte :** Pour conserver l'adresse IP source réelle des utilisateurs dans les logs applicatifs, l'équipe Réseau a configuré l'option `externalTrafficPolicy: Local` sur le Service d'entrée. Depuis, les requêtes échouent de manière aléatoire avec des timeouts lorsque le trafic entre par certains nœuds du cluster.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : "externalTrafficPolicy: Local" indique à kube-proxy de ne PAS retransmettre le trafic vers un autre nœud si aucun Pod cible n'est présent localement.
# Le Deployment ne compte qu'un seul réplique (1 Pod sur 1 seul nœud). Toutes les requêtes arrivant sur les autres nœuds du cluster tombent dans le vide (timeout).
apiVersion: apps/v1
kind: Deployment
metadata:
  name: edge-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: edge-api
  template:
    metadata:
      labels:
        app: edge-api
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: edge-api-nodeport
  namespace: default
spec:
  type: NodePort
  # ERREUR : "Local" rejette ou abandonne le trafic arrivant sur un nœud qui n'héberge aucun Pod "edge-api"
  externalTrafficPolicy: Local
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: edge-api

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
# Option A (Correction du routage) : Passage à "externalTrafficPolicy: Cluster" pour autoriser kube-proxy à router le trafic vers n'importe quel nœud du cluster hébergeant le Pod.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: edge-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: edge-api
  template:
    metadata:
      labels:
        app: edge-api
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: edge-api-nodeport
  namespace: default
spec:
  type: NodePort
  # CORRECTION : Le trafic arrivant sur n'importe quel nœud sera redirigé via le réseau overlay (SNAT) vers le nœud hébergeant le Pod
  externalTrafficPolicy: Cluster
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: edge-api

```

**Démarche de résolution pour l'apprenant :**

1. Tester la connectivité vers le `NodePort` (30080) sur les différentes adresses IP des nœuds du cluster :
`curl -m 2 http://<IP_NOEUD_1>:30080` (fonctionne si le Pod s'y trouve).
`curl -m 2 http://<IP_NOEUD_2>:30080` (échec ou timeout).
2. Vérifier sur quel nœud est planifié l'unique Pod de l'application : `kubectl get pods -o wide`.
3. Inspecter la définition du Service : `kubectl get svc edge-api-nodeport -o yaml`.
4. Repérer la directive `externalTrafficPolicy: Local`.
5. Comprendre l'impact de ce paramètre :
* `Local` préserve l'IP client d'origine et évite un saut réseau (*hop*) supplémentaire entre nœuds, mais exige qu'un Pod soit présent sur le nœud récepteur.
* Si un nœud ne possède aucun Pod correspondant, `kube-proxy` ne transmet pas la requête aux autres nœuds.


6. Résoudre le problème en passant `externalTrafficPolicy` à `Cluster` (ou en transformant le `Deployment` en `DaemonSet` si la préservation de l'IP client source avec `Local` est une exigence absolue).

---

