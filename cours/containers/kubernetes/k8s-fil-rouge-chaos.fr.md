# Exercice Fil Rouge : Détective Kubernetes - Diagnostiquer et Résoudre des Pannes par Chaos Engineering

## Objectif

Cet exercice a pour but de vous placer dans la peau d'un ingénieur SRE. L'application de vote est déjà déployée et fonctionne parfaitement. Votre mission est de maintenir l'application en bonne santé alors que des pannes mystérieuses et imprévisibles surviennent.

Le formateur utilisera un outil de **Chaos Engineering** (comme LitmusChaos, Chaos Mesh ou autre) pour injecter des pannes dans le cluster. En utilisant les outils d'observabilité et de `kubectl`, vous devrez :

1.  **Observer** les symptômes de la panne.
2.  **Diagnostiquer** la cause racine du problème.
3.  **Proposer et implémenter** une solution pérenne pour rendre l'application plus résiliente à ce type de panne.

## Prérequis

*   **Application Pré-déployée :** Le formateur vous fournira un accès à un cluster où l'application de vote (version du Chart Helm) est déjà déployée et fonctionnelle dans le namespace `vote-app`.
*   **Outils d'Observabilité :** Une pile de monitoring (Prometheus & Grafana) est également déployée. Vous aurez accès à Grafana pour visualiser les métriques du cluster.
*   **Outils de Chaos :** Le formateur a installé un outil de Chaos Engineering. Vous n'avez pas besoin de le maîtriser, seulement de savoir qu'il est la source des problèmes.

## Votre Boîte à Outils de Détective

Pour chaque scénario, vous devrez vous appuyer sur ces commandes et outils essentiels :

*   `kubectl get pods -n vote-app -w` : Pour observer les changements d'état des pods en temps réel.
*   `kubectl describe pod <nom-du-pod> -n vote-app` : Pour examiner les événements et comprendre pourquoi un pod est en échec.
*   `kubectl logs -f <nom-du-pod> -n vote-app` : Pour lire les journaux de l'application.
*   `kubectl top pods -n vote-app` & `kubectl top nodes` : Pour vérifier la consommation de ressources.
*   **Tableaux de bord Grafana :** Pour visualiser les métriques de CPU, mémoire, réseau et disque.

---

### Scénario 1 : L'Application Instable (Chaos : `pod-delete`)

*   **Symptômes Observés :** Le formateur annonce le début de la panne. Vous remarquez que l'accès à l'application `vote` est intermittent. Parfois la page charge, parfois elle renvoie une erreur. En observant les pods, vous voyez que les pods `vote` redémarrent sans cesse, mais ne sont pas en `CrashLoopBackOff`.

*   **Votre Mission :**
    1.  Utilisez `kubectl get pods -w` pour confirmer que les pods sont bien terminés et recréés.
    2.  Utilisez `kubectl describe deployment vote` pour voir que le `Deployment` fait bien son travail en maintenant le nombre de réplicas.
    3.  **Diagnostic :** Quelle est la cause de l'interruption de service ? Que se passe-t-il si un pod est supprimé ?
    4.  **Solution :** Quelle modification simple dans la configuration du `Deployment` `vote` permettrait d'assurer la haute disponibilité et de garantir qu'il y ait toujours au moins un pod disponible pour répondre, même si un autre est en cours de suppression ?

---

### Scénario 2 : Le Voisin Bruyant (Chaos : `pod-cpu-hog`)

*   **Symptômes Observés :** L'application `result` devient extrêmement lente, voire inaccessible (timeout du navigateur). Les autres services semblent fonctionner normalement au début, mais peuvent aussi être impactés.

*   **Votre Mission :**
    1.  Utilisez `kubectl top pods` pour identifier un pod qui consomme une quantité anormale de CPU.
    2.  Consultez les dashboards Grafana pour confirmer le pic de consommation CPU sur le pod `result` et potentiellement sur le nœud qui l'héberge.
    3.  **Diagnostic :** Pourquoi un seul pod peut-il impacter les performances de tout un nœud ? Qu'est-ce qui manque dans la configuration de notre conteneur pour l'empêcher de consommer toutes les ressources disponibles ?
    4.  **Solution :** Modifiez le `Deployment` `result`. Quelle section et quels paramètres faut-il ajouter au conteneur pour s'assurer qu'il ne puisse jamais dépasser une certaine limite de CPU, protégeant ainsi les autres applications ?

---

### Scénario 3 : Le Réseau Défaillant (Chaos : `network-latency`)

*   **Symptômes Observés :** Vous pouvez voter sur l'application `vote`, mais les résultats ne se mettent jamais à jour sur l'application `result`. Après quelques minutes, vous remarquez que le pod `worker` se met à redémarrer en boucle (`CrashLoopBackOff`).

*   **Votre Mission :**
    1.  Observez les logs du pod `worker` avec `kubectl logs`. Vous devriez y voir des erreurs de timeout lors de la connexion à la base de données `db`.
    2.  Examinez la configuration des sondes (`probes`) du `Deployment` `worker`.
    3.  **Diagnostic :** Pourquoi une simple latence réseau entre le `worker` et la `db` provoque-t-elle un redémarrage en boucle du `worker` ? La configuration de la `livenessProbe` est-elle adaptée à une application qui a des dépendances réseau ?
    4.  **Solution :** Proposez des modifications à la `livenessProbe` et/ou à la `readinessProbe` du `worker` pour le rendre plus tolérant aux latences réseau passagères. Faut-il augmenter les timeouts ? Les seuils d'échec (`failureThreshold`) ?

---

### Scénario 4 : Le Disque Saturé (Chaos : `disk-fill`)

*   **Symptômes Observés :** L'application entière semble se figer. Les nouveaux votes ne sont plus pris en compte et la base de données ne répond plus. Le pod `db` est peut-être en `CrashLoopBackOff`.

*   **Votre Mission :**
    1.  Examinez les logs du pod `db`. Vous devriez y trouver des erreurs explicites du type "No space left on device" ou des erreurs d'écriture.
    2.  Obtenez un shell à l'intérieur du pod `db` (`kubectl exec -it ...`) et vérifiez l'espace disque avec `df -h`.
    3.  Vérifiez l'état du `PersistentVolumeClaim` (PVC) associé.
    4.  Consultez les dashboards Grafana/Prometheus pour les métriques d'utilisation des volumes persistants.
    5.  **Diagnostic :** Le volume persistant alloué à la base de données est plein. Comment pouvons-nous résoudre ce problème sur un cluster en production ?
    6.  **Solution :** Quelle est la procédure pour augmenter la taille d'un `PersistentVolumeClaim` ? Vérifiez si la `StorageClass` utilisée autorise l'expansion de volume (`allowVolumeExpansion: true`). Modifiez la ressource `PVC` pour demander plus d'espace.

---

### Conclusion de l'Exercice

En résolvant ces pannes, vous aurez prouvé que la résilience d'une application sur Kubernetes n'est pas magique. Elle est le résultat d'une conception rigoureuse incluant :

*   **La haute disponibilité** (plusieurs réplicas).
*   **La gouvernance des ressources** (requests et limits).
*   **Des sondes de santé intelligentes** (probes bien configurées).
*   **Une stratégie de stockage évolutive**.

---
---

## Annexe pour le Formateur : Mise en Place des Outils de Chaos Engineering

Cette section vous guide pour installer et configurer un outil de Chaos Engineering afin de réaliser les scénarios de panne décrits dans cet exercice. Nous utiliserons **LitmusChaos**, un projet open-source de la CNCF, qui est puissant et facile à prendre en main.

### Étape 1 : Installation de LitmusChaos

1.  **Installez le portail Chaos :**
    Appliquez le manifeste d'installation de Litmus. Cela déploiera tous les composants nécessaires dans le namespace `litmus`.

    ```shell
    kubectl apply -f https://litmuschaos.github.io/litmus/2.14.0/litmus-2.14.0.yaml
    ```
    *(Vérifiez la [dernière version](https://litmuschaos.github.io/litmus/index.yaml) si nécessaire)*

2.  **Installez les expériences de chaos :**
    Nous allons installer les expériences de chaos génériques (`generic`) depuis le Chaos Hub de Litmus.

    ```shell
    kubectl apply -f https://hub.litmuschaos.io/api/chaos/2.14.0?file=charts/generic/generic-chaos-experiments.yaml
    ```

### Étape 2 : Configuration des Permissions (RBAC)

Pour que Litmus (s'exécutant dans le namespace `litmus`) puisse affecter les pods de notre application (dans le namespace `vote-app`), nous devons créer les permissions RBAC appropriées.

1.  **Créez un ServiceAccount pour les expériences de chaos dans `vote-app` :**

    ```yaml
    # litmus-rbac.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: litmus-sa
      namespace: vote-app
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: litmus-chaos-role
      namespace: vote-app
    rules:
      # Permissions pour les expériences de base (pod-delete, container-kill, etc.)
      - apiGroups: [""]
        resources: ["pods"]
        verbs: ["create","delete","get","list","patch","update", "deletecollection"]
      # Permissions pour les expériences réseau
      - apiGroups: [""]
        resources: ["pods/exec"]
        verbs: ["create","get","list"]
      # Permissions pour les événements
      - apiGroups: [""]
        resources: ["events"]
        verbs: ["create", "get", "list", "patch", "update"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: litmus-chaos-role-binding
      namespace: vote-app
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: litmus-chaos-role
    subjects:
    - kind: ServiceAccount
      name: litmus-sa
      namespace: vote-app
    ```

2.  **Appliquez ce manifeste :**
    ```shell
    kubectl apply -f chemin/vers/litmus-rbac.yaml
    ```

### Étape 3 : Déclenchement des Scénarios de Chaos

Pour chaque scénario, vous devrez appliquer un manifeste `ChaosEngine`. C'est cet objet qui lie une expérience de chaos à une application cible.

---

#### Scénario 1 : L'Application Instable (`pod-delete`)

Créez le fichier `chaos-scenario-1.yaml` et appliquez-le pour commencer à supprimer des pods `vote`.

```yaml
# chaos-scenario-1.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: vote-pod-delete-chaos
  namespace: vote-app
spec:
  engineState: 'active'
  appinfo:
    appns: 'vote-app'
    applabel: 'app=vote'
    appkind: 'deployment'
  chaosServiceAccount: litmus-sa
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '60' # Durée en secondes
            - name: CHAOS_INTERVAL
              value: '10' # Intervalle entre chaque suppression de pod
            - name: FORCE
              value: 'false'
```

**Pour démarrer la panne :** `kubectl apply -f chaos-scenario-1.yaml`
**Pour arrêter la panne :** `kubectl delete -f chaos-scenario-1.yaml`

---

#### Scénario 2 : Le Voisin Bruyant (`pod-cpu-hog`)

Créez le fichier `chaos-scenario-2.yaml` et appliquez-le pour surcharger le CPU du pod `result`.

```yaml
# chaos-scenario-2.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: result-cpu-hog-chaos
  namespace: vote-app
spec:
  engineState: 'active'
  appinfo:
    appns: 'vote-app'
    applabel: 'app=result'
    appkind: 'deployment'
  chaosServiceAccount: litmus-sa
  experiments:
    - name: pod-cpu-hog
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '120' # Durée en secondes
            - name: CPU_CORES
              value: '1' # Nombre de coeurs CPU à utiliser
```

**Pour démarrer la panne :** `kubectl apply -f chaos-scenario-2.yaml`
**Pour arrêter la panne :** `kubectl delete -f chaos-scenario-2.yaml`

---

#### Scénario 3 : Le Réseau Défaillant (`network-latency`)

Créez le fichier `chaos-scenario-3.yaml`. Cette expérience injecte une latence de 2 secondes sur le trafic sortant du pod `worker` à destination du pod `db`.

```yaml
# chaos-scenario-3.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: worker-network-latency-chaos
  namespace: vote-app
spec:
  engineState: 'active'
  appinfo:
    appns: 'vote-app'
    applabel: 'app=worker'
    appkind: 'deployment'
  chaosServiceAccount: litmus-sa
  experiments:
    - name: pod-network-latency
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '120' # Durée en secondes
            - name: NETWORK_LATENCY
              value: '2000' # en millisecondes
            - name: TARGET_CONTAINER
              value: 'worker' # Nom du conteneur dans le pod
            # Cible optionnelle, pour être plus précis
            - name: DESTINATION_IPS
              value: '' # Laissez vide pour tout le trafic sortant
            - name: DESTINATION_HOSTS
              value: 'db' # Cible le service 'db'
```

**Pour démarrer la panne :** `kubectl apply -f chaos-scenario-3.yaml`
**Pour arrêter la panne :** `kubectl delete -f chaos-scenario-3.yaml`

---

#### Scénario 4 : Le Disque Saturé (`disk-fill`)

Créez le fichier `chaos-scenario-4.yaml`. Cette expérience remplit à 80% le volume monté sur `/var/lib/postgresql/data` dans le pod `db`.

```yaml
# chaos-scenario-4.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: db-disk-fill-chaos
  namespace: vote-app
spec:
  engineState: 'active'
  appinfo:
    appns: 'vote-app'
    applabel: 'app=db'
    appkind: 'statefulset' # Attention, la cible est un StatefulSet ici
  chaosServiceAccount: litmus-sa
  experiments:
    - name: disk-fill
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '180' # Durée en secondes
            - name: FILL_PERCENTAGE
              value: '80' # Pourcentage de remplissage du disque
            - name: TARGET_PATH
              value: '/var/lib/postgresql/data' # Chemin du volume à remplir
```

**Pour démarrer la panne :** `kubectl apply -f chaos-scenario-4.yaml`
**Pour arrêter la panne :** `kubectl delete -f chaos-scenario-4.yaml`
