### Exercice 7/30 : Pod interrompu brusquement avec le statut `OOMKilled` (Niveau : Facile / Moyen)

* **Objectif :** Diagnostiquer une terminaison de conteneur due à un dépassement de la limite de mémoire RAM autorisée (*Exit Code 137*).
* **Contexte :** Un script d'arrière-plan charge des données en mémoire vive au démarrage, mais le Pod redémarre systématiquement après quelques secondes.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La limite mémoire (10Mi) est insuffisante pour le processus Python qui requiert ~50Mi pour démarrer.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-app
  template:
    metadata:
      labels:
        app: memory-app
    spec:
      containers:
      - name: mem-allocator
        image: python:3.11-alpine
        command: ["python", "-c", "import time; x = 'A' * 50 * 1024 * 1024; time.sleep(3600)"]
        resources:
          requests:
            cpu: "50m"
            memory: "10Mi"
          limits:
            cpu: "100m"
            # ERREUR : Limite mémoire bien trop basse (10Mi) pour l'allocation de 50Mi de l'application
            memory: "10Mi"

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: memory-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: memory-app
  template:
    metadata:
      labels:
        app: memory-app
    spec:
      containers:
      - name: mem-allocator
        image: python:3.11-alpine
        command: ["python", "-c", "import time; x = 'A' * 50 * 1024 * 1024; time.sleep(3600)"]
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "100m"
            # CORRECTION : Limite rehaussée à 128Mi pour autoriser l'allocation de 50Mi + l'overhead Python
            memory: "128Mi"

```

**Démarche de résolution pour l'apprenant :**

1. Examiner l'état des Pods : `kubectl get pods` (statut `CrashLoopBackOff` ou `OOMKilled`).
2. Obtenir les détails de terminaison du conteneur précédent : `kubectl describe pod <nom-du-pod>`.
3. Noter sous `Last State` les éléments clés : `Reason: OOMKilled` et `Exit Code: 137`.
4. Consulter la section `Limits` / `Requests` de la description du Pod pour constater l'allocation sous-dimensionnée.
5. Augmenter le paramètre `limits.memory` dans le manifeste et redéployer.

---
