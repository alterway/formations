
# Exercice Fil Rouge : Déploiement d'une Application de Vote avec Kubernetes

## Objectif

Cet exercice a pour but de vous guider à travers les concepts clés de Kubernetes en déployant et en faisant évoluer une application de vote composée de plusieurs microservices. Vous commencerez par les bases et ajouterez progressivement des fonctionnalités plus avancées pour rendre l'application plus robuste, scalable et observable.

L'application est composée des services suivants :

*   `vote` : Un front-end en Python pour voter.
*   `result` : Un front-end en Node.js pour afficher les résultats.
*   `redis` : une file d'attente pour les votes.
*   `worker` : Un service en .NET qui consomme les votes et les stocke.
*   `db` : Une base de données PostgreSQL pour persister les données.

## Prérequis

*   Un cluster Kubernetes déjà déployé et fonctionnel.
*   L'outil `kubectl` installé sur votre poste de travail.
*   Un fichier `kubeconfig` fourni pour accéder à votre cluster.

---

### Étape 1 : Configuration Initiale et Vérification

1.  **Configuration du Kubeconfig**
    *   Exportez la variable d'environnement `KUBECONFIG` pour pointer vers votre fichier de configuration.

        ```shell
        export KUBECONFIG=/chemin/vers/votre/kubeconfig
        ```

2.  **Vérifiez votre environnement**
    *   Listez les nœuds pour confirmer la connexion.

        ```shell
        kubectl get nodes
        ```

---

### Étape 2 : Déploiement des Composants de Base

1.  **Déployez le Pod de vote**
    *   Créez et appliquez `assets/vote-pod.yaml`.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/vote-pod.yaml
        apiVersion: v1
        kind: Pod
        metadata:
          name: vote
          labels:
            app: vote
        spec:
          containers:
          - name: vote
            image: dockersamples/examplevotingapp_vote
            ports:
            - containerPort: 80
        ```

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/vote-pod.yaml
        ```

2.  **Exposez le Pod avec un Service `NodePort`**
    *   Créez et appliquez `assets/vote-service.yaml`.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/vote-service.yaml
        apiVersion: v1
        kind: Service
        metadata:
          name: vote
        spec:
          type: NodePort
          selector:
            app: vote
          ports:
          - port: 80
            targetPort: 80
        ```

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/vote-service.yaml
        ```

    *   Accédez au service via `http://<IP-DU-NOEUD>:<NODE-PORT>`.

---

### Étape 3 : Gestion des Déploiements

1.  **Utilisez un Déploiement**
    *   Supprimez le Pod (`kubectl delete pod vote`) et remplacez-le par `assets/vote-deployment.yaml`.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/vote-deployment.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: vote
        spec:
          replicas: 2
          selector:
            matchLabels:
              app: vote
          template:
            metadata:
              labels:
                app: vote
            spec:
              containers:
              - name: vote
                image: dockersamples/examplevotingapp_vote
                ports:
                - containerPort: 80
        ```

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/vote-deployment.yaml
        ```

---

### ��tape 4 : Déploiement de l'Application Complète

1.  **Déployez les composants restants**
    *   Appliquez `assets/all-in-one-app.yaml` qui contient `redis`, `db`, `worker` et `result`.

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/all-in-one-app.yaml
        ```

---

### Étape 5 : Exposition via Ingress

1.  **Installez un Ingress Controller NGINX**

    ```shell
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
    ```

    *   Récupérez l'IP externe du service `ingress-nginx-controller`.

2.  **Passez les Services en `ClusterIP`**
    *   Modifiez les services `vote` et `result` pour retirer `type: NodePort`.

3.  **Créez la ressource Ingress**
    *   Appliquez `assets/app-ingress.yaml` pour router `vote.k8s.local` et `result.k8s.local`.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/app-ingress.yaml
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          name: vote-app-ingress
        spec:
          rules:
          - host: "vote.k8s.local"
            http:
              paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: vote
                    port:
                      number: 80
          - host: "result.k8s.local"
            http:
              paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: result
                    port:
                      number: 80
        ```

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/app-ingress.yaml
        ```

4.  **Testez**
    *   Modifiez votre fichier `/etc/hosts` local pour mapper l'IP du contrôleur aux noms d'hôte.

---

### Étape 6 : Persistance des Données

1.  **Créez un PVC**
    *   Appliquez `assets/db-pvc.yaml` pour demander du stockage.

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/db-pvc.yaml
        ```

2.  **Montez le volume dans le Pod `db`**
    *   Appliquez une version modifiée du déploiement `db` qui monte le volume.

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/db-deployment-with-volume.yaml
        ```

---

### Étape 7 : Gestion des Configurations avec Kustomize

1.  **Organisez les fichiers** et créez une structure `base`/`overlays`.
2.  **Créez la Base Kustomize** avec un fichier `kustomization.yaml` qui référence tous vos manifestes.
3.  **Créez un Overlay de Production** pour patcher le nombre de réplicas du déploiement `vote`.
4.  **Déployez avec Kustomize** en utilisant `kubectl apply -k chemin/vers/overlay`.

---

### Étape 8 : Gestion des Ressources au niveau Conteneur

1.  **Définissez les requêtes et les limites**
    *   Ajoutez une section `resources` à vos déploiements pour spécifier les besoins en CPU et mémoire pour chaque conteneur.

        ```yaml
        # Extrait de redis-deployment.yaml
        ...
        spec:
          containers:
          - name: redis
            image: redis:alpine
            resources:
              requests:
                memory: "64Mi"
                cpu: "100m"
              limits:
                memory: "128Mi"
                cpu: "250m"
        ...
        ```

---

### Étape 9 : Gouvernance des Ressources : Quotas et LimitRanges

Maintenant que nous gérons les ressources au niveau des conteneurs, nous allons appliquer des politiques au niveau du Namespace pour garantir une utilisation équitable des ressources.

1.  **Créez un Namespace**
    *   Pour isoler notre application et ses politiques, créons un Namespace.

        ```shell
        kubectl create namespace vote-app
        ```

    *   **Important** : Toutes les commandes `kubectl` suivantes devront être exécutées avec l'option `-n vote-app` pour cibler ce Namespace.

2.  **Définissez un `LimitRange`**
    *   Cet objet définit des contraintes sur les ressources au sein d'un Namespace.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/limits.yaml
        apiVersion: v1
        kind: LimitRange
        metadata:
          name: default-limits
        spec:
          limits:
          - default:
              memory: "256Mi"
              cpu: "200m"
            defaultRequest:
              memory: "128Mi"
              cpu: "100m"
            type: Container
        ```

    *   Appliquez-le au Namespace `vote-app`.

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/limits.yaml -n vote-app
        ```

3.  **Définissez un `ResourceQuota`**
    *   Cet objet limite la consommation totale de ressources dans un Namespace.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/quota.yaml
        apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: app-quota
        spec:
          hard:
            requests.cpu: "2"
            requests.memory: "2Gi"
            limits.cpu: "4"
            limits.memory: "4Gi"
            pods: "10"
            services: "5"
        ```

    *   Appliquez-le également au Namespace.

        ```shell
        kubectl apply -f /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/quota.yaml -n vote-app
        ```

4.  **Déployez l'application dans le Namespace**
    *   Déployez à nouveau l'ensemble de vos manifestes en spécifiant le Namespace.

        ```shell
        kubectl apply -k /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/kustomize/overlays/production -n vote-app
        ```

5.  **Vérifiez les Quotas**
    *   Inspectez l'état de votre quota.

        ```shell
        kubectl describe quota app-quota -n vote-app
        ```

---

### Étape 10 : Mise à l'échelle automatique (HPA)

1.  **Implémentez le HPA**
    *   Installez le Metrics Server si nécessaire.
    *   Créez une ressource `HorizontalPodAutoscaler` pour le déploiement `vote`.

        ```shell
        kubectl autoscale deployment vote --cpu-percent=50 --min=2 --max=5 -n vote-app
        ```

---

### Étape 11 : Sécurité avec les NetworkPolicies

1.  **Mettez en place des NetworkPolicies**
    *   Créez une politique réseau pour restreindre le trafic. Par exemple, n'autoriser que les pods `worker` à communiquer avec les pods `db`.

        ```yaml
        # /Users/hleclerc/dev/projects/formations/formations-aw/cours/containers/kubernetes/assets/db-netpol.yaml
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: db-access-policy
          namespace: vote-app
        spec:
          podSelector:
            matchLabels:
              app: db
          policyTypes:
          - Ingress
          ingress:
          - from:
            - podSelector:
                matchLabels:
                  app: worker
        ```

---

### Étape 12 : Observabilité

1.  **Déployez Prometheus et Grafana**
    *   La manière la plus simple d'installer une pile de monitoring est via un **Chart Helm**.

        ```shell
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
        ```
    *   Une fois déployé, vous pouvez configurer Prometheus pour découvrir automatiquement vos services et créer des tableaux de bord dans Grafana.

---

### Étape 13 : Packaging avec Helm

1.  **Créez un Chart Helm**
    *   Helm fournit une commande pour créer la structure d'un chart.

        ```shell
        helm create voting-app-chart
        ```
    *   Vous pouvez ensuite déplacer vos manifestes YAML dans le répertoire `templates/` de ce chart, en remplaçant les valeurs fixes (comme le nombre de réplicas ou les versions d'image) par des variables Helm (`{{ .Values.replicaCount }}`).

---

### Étape 14 : Déploiement avec GitOps (ArgoCD)

1.  **Installez et configurez ArgoCD**
    *   ArgoCD s'installe dans le cluster. Une fois son interface accessible, vous créez une ressource `Application`.
    *   Cette ressource `Application` pointe vers un dépôt Git contenant vos manifestes Kubernetes (ou votre Chart Helm).
    *   ArgoCD détectera automatiquement toute différence entre le contenu du dépôt Git et ce qui est déployé dans le cluster, et appliquera les changements nécessaires pour maintenir la synchronisation.

---

### Étape 15 : Maintenance et Dépannage

1.  **Simulez une panne**
    *   **Pod en boucle de crash :** Modifiez un déploiement avec une image incorrecte (ex: `redis:nonexistent`).
    *   Utilisez `kubectl get pods -n vote-app` pour voir le statut, qui sera `ImagePullBackOff` ou `CrashLoopBackOff`.
    *   **Diagnostic :** Utilisez `kubectl describe pod <nom-du-pod> -n vote-app` pour voir les événements et comprendre la cause de l'erreur (l'image n'a pas été trouvée).
    *   **Logs :** Utilisez `kubectl logs <nom-du-pod> -n vote-app` pour inspecter les journaux de l'application à l'intérieur du conteneur, ce qui est utile pour les erreurs applicatives.
