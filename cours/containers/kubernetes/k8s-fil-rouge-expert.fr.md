# Exercice Fil Rouge : Déploiement et Exploitation d'une Application Complexe sur Kubernetes (Niveau Expert)

## Objectif

Cet exercice a pour but de simuler le cycle de vie complet d'une application microservices dans un environnement Kubernetes de production. En partant d'un déploiement de base, nous ajouterons progressivement des couches de complexité pour aborder des sujets experts tels que la sécurité, la persistance avancée, la gouvernance des ressources, l'observabilité, le packaging et les déploiements GitOps.

**L'application de vote est composée des services suivants :**

*   `vote` : Un front-end en Python pour voter.
*   `result` : Un front-end en Node.js pour afficher les résultats.
*   `redis` : Une file d'attente pour les votes.
*   `worker` : Un service en .NET qui consomme les votes et les stocke.
*   `db` : Une base de données PostgreSQL pour persister les données.

## Prérequis

*   Un cluster Kubernetes fonctionnel.
*   `kubectl` configuré pour accéder au cluster.
*   `helm` installé localement.
*   Un compte sur un dépôt Git (GitHub, GitLab, etc.).

---

### Étape 1 : Mise en Place et Déploiement Initial

1.  **Isolation avec un Namespace**
    *   Créez un `Namespace` dédié `vote-app` pour isoler tous les composants de l'application.

2.  **Déploiement des Composants**
    *   Déployez chaque service (`vote`, `result`, `redis`, `worker`, `db`) en utilisant des manifestes `Deployment` et `Service` (de type `ClusterIP`).
    *   Utilisez des `labels` cohérents pour chaque composant (ex: `app: vote`, `component: frontend`).

Images : 

- votes : dockersamples/examplevotingapp_worker
- posgresql : postgres:9.4
- redis : redis:alpine
- result : dockersamples/examplevotingapp_result
- worker : dockersamples/examplevotingapp_worker



---

### Étape 2 : Persistance des Données avec un `StatefulSet`

1.  **Gestion de l'état**
    *   Supprimez le `Deployment` de la base de données `db`.
    *   Redéployez `db` en utilisant un `StatefulSet` pour garantir une identité réseau stable.
    *   Créez un `Service` "headless" pour permettre la découverte des pods de la base de données.

2.  **Stockage Dynamique**
    *   Créez un `PersistentVolumeClaim` (PVC) pour la base de données.
    *   Configurez le `StatefulSet` pour qu'il utilise ce PVC via la section `volumeClaimTemplates` afin de provisionner dynamiquement un `PersistentVolume` (PV) pour chaque réplica.

---

### Étape 3 : Gestion de la Configuration et des Secrets

1.  **Externalisation de la Configuration**
    *   Créez un `ConfigMap` pour le service `result` afin de configurer les options de vote. Montez ce `ConfigMap` en tant que volume dans le pod `result`.

2.  **Gestion des Données Sensibles**
    *   Créez un `Secret` pour stocker le mot de passe de la base de données PostgreSQL.
    *   Injectez ce mot de passe dans les pods `worker` et `db` via des variables d'environnement qui référencent le `Secret`. Ne stockez jamais de mots de passe en clair dans les manifestes.

---

### Étape 4 : Exposition Sécurisée avec `Ingress` et TLS

1.  **Routage du Trafic**
    *   Installez un `Ingress Controller` (par exemple, NGINX).
    *   Créez une ressource `Ingress` pour router le trafic vers les services `vote` et `result` en utilisant des noms d'hôtes différents (ex: `vote.mondomaine.com` et `result.mondomaine.com`).

2.  **Sécurisation avec TLS**
    *   Déployez `cert-manager` dans votre cluster.
    *   Configurez un `ClusterIssuer` (par exemple, pour Let's Encrypt).
    *   Modifiez la ressource `Ingress` pour demander automatiquement un certificat TLS et activer le HTTPS.

---

### Étape 5 : Sécurité et Isolation

1.  **Politiques Réseau (`NetworkPolicy`)**
    *   Mettez en place une politique de "deny-all" par défaut sur le namespace `vote-app`.
    *   Créez des `NetworkPolicy` granulaires pour autoriser uniquement les flux de communication nécessaires :
        *   `Ingress Controller` -> `vote` et `result`.
        *   `vote` -> `redis`.
        *   `worker` -> `redis` et `db`.
    *   Vérifiez que toute communication non autorisée est bien bloquée.

2.  **Contrôle d'Accès (`RBAC`)**
    *   Créez un `ServiceAccount` spécifique pour l'application `worker`.
    *   Créez un `Role` qui donne des permissions très limitées (ex: uniquement la lecture des `ConfigMaps` du namespace `vote-app`).
    *   Liez le `ServiceAccount` au `Role` avec un `RoleBinding`.
    *   Modifiez le `Deployment` du `worker` pour qu'il utilise ce `ServiceAccount`.

---

### Étape 6 : Gouvernance des Ressources

1.  **Limites et Requêtes**
    *   Ajoutez des `requests` et `limits` (CPU et mémoire) à tous les conteneurs de l'application pour garantir la Qualité de Service (QoS).

2.  **Quotas**
    *   Appliquez un `ResourceQuota` sur le namespace `vote-app` pour limiter la consommation totale de ressources (CPU, mémoire, nombre de pods, nombre de PVCs).

3.  **Contraintes par Défaut**
    *   Définissez un `LimitRange` pour appliquer des `requests` et `limits` par défaut à tout nouveau pod créé dans le namespace qui n'en spécifierait pas.

---

### Étape 7 : Observabilité et Haute Disponibilité

1.  **Sondes de Santé (`Probes`)**
    *   Ajoutez des `livenessProbe` et `readinessProbe` à tous les déploiements pour que Kubernetes puisse gérer automatiquement les conteneurs défaillants et les redémarrer ou les retirer du service.

2.  **Monitoring**
    *   Déployez une pile de monitoring (ex: `kube-prometheus-stack` via Helm) dans un namespace `monitoring`.
    *   Créez un `ServiceMonitor` pour que Prometheus collecte automatiquement les métriques de vos services (si elles en exposent).

3.  **Scalabilité Automatique**
    *   Déployez le `metrics-server`.
    *   Créez un `HorizontalPodAutoscaler` (HPA) pour le déploiement `worker`, afin de le mettre à l'échelle automatiquement en fonction de l'utilisation du CPU.

---

### Étape 8 : Packaging avec Helm

1.  **Création d'un Chart**
    *   Transformez l'ensemble de vos manifestes YAML en un Chart Helm `voting-app`.
    *   Utilisez des templates pour les valeurs configurables (nombre de réplicas, versions d'images, noms d'hôtes Ingress, ressources CPU/mémoire, etc.).
    *   Structurez le `values.yaml` pour qu'il soit clair et facile à utiliser.

---

### Étape 9 : Déploiement Continu avec GitOps et ArgoCD

1.  **Mise en place de GitOps**
    *   Poussez votre Chart Helm sur un dépôt Git.
    *   Déployez ArgoCD dans le cluster (dans son propre namespace `argocd`).

2.  **Application ArgoCD**
    *   Créez une ressource `Application` dans ArgoCD qui pointe vers votre dépôt Git.
    *   Configurez-la pour qu'elle déploie le Chart Helm dans le namespace `vote-app`.
    *   Activez la synchronisation automatique (`auto-sync`) et le `self-heal`.

3.  **Validation du Workflow**
    *   Modifiez une valeur dans le fichier `values.yaml` de votre Chart dans Git (par exemple, augmentez le nombre de réplicas du `vote`).
    *   Poussez le changement et observez ArgoCD détecter la dérive de configuration et mettre à jour automatiquement le déploiement dans le cluster.

---

### Étape 10 : Scénarios de Dépannage Guidé (Troubleshooting)

L'objectif de cette étape est d'utiliser notre installation GitOps pour simuler des problèmes courants et s'entraîner à les diagnostiquer. Pour chaque scénario, la "panne" est introduite en modifiant le code dans votre dépôt Git et en poussant le changement. ArgoCD appliquera alors la configuration défaillante.

#### Scénario 1 : L'Image Inexistante (Erreur `ImagePullBackOff`)

1.  **Introduire l'erreur :**
    *   Dans votre dépôt Git, ouvrez le fichier `labs/k8s/fil-rouge-expert/step8-helm-chart/voting-app-chart/values.yaml`.
    *   Modifiez la version de l'image du service `result` pour une version qui n'existe pas. Par exemple :
        ```yaml
        result:
          image: dockersamples/examplevotingapp_result
          tag: non-existent-tag
          ...
        ```
    *   Commettez et poussez ce changement sur votre branche principale.

2.  **Observer le problème :**
    *   Dans l'interface d'ArgoCD, observez que l'application `voting-app` passe à l'état `Degraded`.
    *   Utilisez `kubectl` pour inspecter les pods dans le namespace `vote-app` :
        ```shell
        kubectl get pods -n vote-app
        ```
    *   Repérez le pod `result` qui est dans un état anormal (`ImagePullBackOff` ou `ErrImagePull`).

3.  **Diagnostiquer la cause :**
    *   Utilisez la commande `describe` sur le pod défaillant pour voir les événements. C'est la commande la plus importante pour ce type de problème.
        ```shell
        kubectl describe pod <nom-du-pod-result> -n vote-app
        ```
    *   Analysez la section `Events` à la fin de la sortie. Vous devriez voir un message clair indiquant que Kubernetes n'a pas réussi à "pull" (télécharger) l'image car elle n'a pas été trouvée.

4.  **Résoudre le problème :**
    *   Corrigez le tag de l'image dans votre fichier `values.yaml` dans Git.
    *   Commettez et poussez la correction.
    *   Observez ArgoCD qui se synchronise automatiquement et déploie la version correcte, réparant ainsi l'application.

---

#### Scénario 2 : Le Dépassement de Quota (Erreur `Pending`)

1.  **Introduire l'erreur :**
    *   Dans votre `values.yaml` sur Git, augmentez le nombre de réplicas pour le service `vote` à une valeur très élevée, qui dépassera certainement le quota de 10 pods que nous avons fixé à l'étape 6.
        ```yaml
        vote:
          replicaCount: 20
          ...
        ```
    *   Commettez et poussez ce changement.

2.  **Observer le problème :**
    *   ArgoCD va tenter de synchroniser et d'appliquer le changement.
    *   Listez les pods dans le namespace :
        ```shell
        kubectl get pods -n vote-app
        ```
    *   Vous verrez que certains pods `vote` sont créés et passent à `Running`, mais que beaucoup d'autres restent bloqués à l'état `Pending`.

3.  **Diagnostiquer la cause :**
    *   Utilisez `describe` sur l'un des pods en état `Pending` :
        ```shell
        kubectl describe pod <nom-du-pod-vote-pending> -n vote-app
        ```
    *   Dans les événements, vous verrez un message du `scheduler` indiquant qu'il ne peut pas planifier le pod à cause d'un dépassement de quota (`exceeded quota`).
    *   Vous pouvez également vérifier l'état de votre `ResourceQuota` :
        ```shell
        kubectl describe resourcequota app-quota -n vote-app
        ```

4.  **Résoudre le problème :**
    *   Réduisez le `replicaCount` de `vote` à une valeur raisonnable (ex: `2`) dans votre `values.yaml` sur Git.
    *   Commettez et poussez la correction. ArgoCD va réajuster le `Deployment` au nombre de réplicas correct.

---

#### Scénario 3 : La Dépendance Réseau Brisée (Sondes en échec)

1.  **Introduire l'erreur :**
    *   Ce scénario est un peu plus complexe à simuler via GitOps, mais nous pouvons le faire en modifiant les `labels` qui lient un service à son déploiement.
    *   Ouvrez le fichier template du service `redis` : `.../templates/redis-service.yaml`.
    *   Modifiez le `selector` pour qu'il ne corresponde plus aux pods `redis` :
        ```yaml
        # .../templates/redis-service.yaml
        ...
        spec:
          selector:
            app.kubernetes.io/component: redis-broken # On change le label
        ```
    *   Commettez et poussez ce changement.

2.  **Observer le problème :**
    *   ArgoCD applique le changement. Le service `redis` n'a plus d'endpoints car le sélecteur ne correspond à aucun pod.
    *   Vérifiez-le : `kubectl get endpoints -n vote-app | grep redis`. La sortie devrait être vide.
    *   Les pods `vote` et `worker`, qui dépendent de `redis`, vont commencer à avoir des problèmes. Leurs sondes de santé pourraient échouer, ou l'application pourrait simplement cesser de fonctionner.
    *   Regardez les logs des pods `vote` :
        ```shell
        kubectl logs -l app.kubernetes.io/component=vote -n vote-app
        ```
    *   Vous devriez voir des erreurs de connexion à `redis`.

3.  **Diagnostiquer la cause :**
    *   Le diagnostic commence par les logs (`kubectl logs`) qui montrent une erreur de connexion.
    *   Ensuite, on vérifie que le service `redis` est joignable depuis un pod `vote` :
        ```shell
        kubectl exec -it <pod-vote> -n vote-app -- sh
        # A l'intérieur du pod
        ping my-vote-release-redis # (adaptez le nom du service)
        ```
    *   Le `ping` pourrait fonctionner (DNS résout), mais la connexion sur le port échouera.
    *   L'étape clé est de vérifier que le `Service` est correctement configuré et qu'il cible les bons pods en comparant les `labels` du pod `redis` avec le `selector` du service `redis`.

4.  **Résoudre le problème :**
    *   Corrigez le `selector` dans `.../templates/redis-service.yaml` dans Git.
    *   Commettez et poussez le correctif. ArgoCD réappliquera la bonne configuration pour le service, qui retrouvera ses endpoints, et les applications `vote` et `worker` recommenceront à fonctionner normalement.
