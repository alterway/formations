### Exercice 23/30 : Éviction immédiate d'un Pod sur un pool de nœuds dédié (*Toleration NoSchedule vs NoExecute*) (Niveau : Avancé)

* **Objectif :** Diagnostiquer et corriger une éviction systématique de Pods causée par une inadéquation entre l'effet d'une empreinte de nœud (*Taint*) et la tolérance (*Toleration*) définie dans le manifeste.
* **Contexte :** Un pool de nœuds du cluster est réservé aux traitements lourds avec l'empreinte `dedicated=batch:NoExecute`. Le déploiement d'un worker batch est appliqué, mais les Pods sont créés puis immédiatement arrêtés (`Terminating`) et recréés en boucle.

# 1. Poser le label sur le nœud ciblé
kubectl label node <nom-du-noeud> node-role.kubernetes.io/batch=true --overwrite

# 2. Appliquer la Taint avec l'effet NoExecute
kubectl taint nodes <nom-du-noeud> dedicated=batch:NoExecute --overwrite



```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La tolérance est configurée avec l'effet "NoSchedule".
# Résultat : Le scheduler autorise le placement du Pod sur le nœud, mais le Kubelet du nœud l'évince immédiatement car la Taint porte l'effet "NoExecute".
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-processor
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: batch-processor
  template:
    metadata:
      labels:
        app: batch-processor
    spec:
      # Le Pod cible spécifiquement les nœuds du pool batch
      nodeSelector:
        node-role.kubernetes.io/batch: "true"
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "batch"
        # ERREUR : "NoSchedule" empêche seulement le nouveau scheduling, mais ne protège pas contre la Taint "NoExecute" présente sur le nœud
        effect: "NoSchedule"
      containers:
      - name: worker
        image: alpine:3.19
        command: ["sh", "-c", "echo 'Processing batch job...'; sleep 3600"]

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-processor
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: batch-processor
  template:
    metadata:
      labels:
        app: batch-processor
    spec:
      nodeSelector:
        node-role.kubernetes.io/batch: "true"
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "batch"
        # CORRECTION : Alignement de l'effet sur "NoExecute" pour tolérer l'éviction active du nœud
        effect: "NoExecute"
      containers:
      - name: worker
        image: alpine:3.19
        command: ["sh", "-c", "echo 'Processing batch job...'; sleep 3600"]

```

**Démarche de résolution pour l'apprenant :**

1. Observer l'instabilité des Pods : `kubectl get pods -o wide` (les Pods passent de `Pending` à `Terminating` ou se régénèrent en continu avec des noms différents).
2. Inspecter les détails d'un Pod juste avant sa suppression ou consulter l'historique d'événements : `kubectl get events --sort-by='.metadata.creationTimestamp'`.
3. Noter le message d'éviction émis par le Kubelet : `NodeControllerEviction` ou `TaintManagerEviction`.
4. Inspecter les Taints appliquées sur le nœud cible : `kubectl describe node <nom-du-noeud>`.
5. Identifier la Taint présente sur le nœud : `Taints: dedicated=batch:NoExecute`.
6. Comparer avec la section `tolerations` du Deployment et corriger `effect: NoSchedule` par `effect: NoExecute` (ou supprimer le champ `effect` pour tolérer tous les effets associés à cette clé).

---
