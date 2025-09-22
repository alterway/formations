Absolument. Pour des experts, il faut une erreur qui n'est pas seulement une faute de frappe, mais une erreur d'architecture subtile, cachée dans plusieurs couches d'abstraction.

Ce scénario, que j'appelle **"Le Mystère de la Configuration Introuvable via RBAC"**, est redoutable. Tout semble parfaitement configuré, mais le pod n'arrive jamais à se configurer correctement, menant à un état d'erreur fonctionnelle, mais pas à un crash évident.

### Scénario de l'Atelier : "Le Mystère de la Configuration Introuvable"

**Objectif pour les élèves :** Diagnostiquer pourquoi une application ne démarre jamais correctement, alors que tous les manifestes semblent valides, les permissions RBAC semblent correctes et le pod est en état `Running`.

**Description du problème :**

Le scénario met en place un pod avec deux conteneurs :
1.  **Un conteneur principal (nginx)** : Il attend qu'un fichier de configuration (`index.html`) soit généré dans un volume partagé pour démarrer correctement.
2.  **Un conteneur "sidecar" (config-loader)** : Son rôle est de contacter l'API Kubernetes, de lire les données d'un `ConfigMap` spécifique et de les écrire dans le volume partagé pour que le conteneur principal puisse les utiliser.

L'erreur est enfouie dans la configuration RBAC (Role-Based Access Control). Des permissions sont bien créées (ServiceAccount, Role, RoleBinding), mais elles ne sont pas appliquées au pod. Le pod utilise donc le `ServiceAccount` par défaut, qui n'a pas les droits pour lire le `ConfigMap`. Le sidecar échoue en silence, le fichier de configuration n'est jamais créé, et l'application principale ne fonctionne pas comme prévu.

Ce qui rend cet exercice extrêmement difficile, c'est que les experts vont immédiatement inspecter les rôles et les bindings, verront qu'ils existent et sont corrects, et pourraient ne pas penser à vérifier si le pod les utilise réellement.

---

### Les Fichiers Manifestes à Fournir aux Élèves

**1. `01-namespace.yaml`**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: expert-ns
```

**2. `02-configmap.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-html-config
  namespace: expert-ns
data:
  # Le contenu que le sidecar doit récupérer et servir
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
    <title>Configuration Loaded!</title>
    </head>
    <body>
    <h1>Success! The sidecar has successfully fetched the configuration.</h1>
    </body>
    </html>
```

**3. `03-rbac.yaml`**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: expert-ns

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-reader-role
  namespace: expert-ns
rules:
- apiGroups: [""] # "" indique l'API core
  resources: ["configmaps"]
  verbs: ["get", "watch", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-role-binding
  namespace: expert-ns
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: expert-ns
roleRef:
  kind: Role
  name: configmap-reader-role
  apiGroup: rbac.authorization.k8s.io
```

**4. `04-deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
  namespace: expert-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      # ERREUR CRUCIALE : Le ServiceAccount n'est pas spécifié ici.
      # Le pod utilisera donc le ServiceAccount "default" de l'namespace.
      # serviceAccountName: app-service-account # <--- LA LIGNE MANQUANTE

      volumes:
      - name: shared-html
        emptyDir: {}

      containers:
      - name: main-app
        image: nginx:1.21.6
        ports:
        - containerPort: 80
        volumeMounts:
        - name: shared-html
          mountPath: /usr/share/nginx/html

      - name: config-loader-sidecar
        # On utilise une image kubectl pour simuler un client API
        image: bitnami/kubectl:1.23
        # Cette commande tente de lire le configmap et d'écrire son contenu
        # dans le volume partagé. Elle échouera en boucle à cause des permissions.
        command:
        - /bin/sh
        - -c
        - |
          echo "Attempting to fetch configuration...";
          while true; do
            kubectl get configmap app-html-config -n expert-ns -o jsonpath='{.data.index\.html}' > /mnt/html/index.html;
            if [ $? -eq 0 ]; then
              echo "Configuration successfully written.";
              sleep 3600; # On a réussi, on attend
            else
              echo "Failed to fetch configmap. Retrying in 10 seconds...";
              sleep 10;
            fi
          done
        volumeMounts:
        - name: shared-html
          mountPath: /mnt/html
```
---

### Guide de Diagnostic et Solution (Pour le Formateur)

#### 1. Symptômes Observés par les Élèves

*   `kubectl apply -f .` fonctionne sans aucune erreur. Toutes les ressources sont créées.
*   `kubectl get pods -n expert-ns` montre le pod en état `Running`. Les deux conteneurs sont démarrés. Aucun crash, aucun `CrashLoopBackOff`.
*   Un `port-forward` vers le pod (`kubectl port-forward <pod-name> 8080:80 -n expert-ns`) et une visite sur `http://localhost:8080` montrera la page d'accueil par défaut de Nginx ("Welcome to nginx!"), et non le message de succès. C'est un indice majeur que `index.html` n'a pas été remplacé.
*   En inspectant les ressources RBAC (`kubectl get sa,role,rolebinding -n expert-ns`), tout semble parfaitement correct. Le `ServiceAccount` existe, le `Role` a les bonnes permissions, et le `RoleBinding` fait le lien.

#### 2. Le Cheminement du Diagnostic (pour un expert)

1.  **Constat initial : L'application ne sert pas le bon contenu.**
    Le premier réflexe sera d'entrer dans le conteneur principal pour voir le contenu du fichier.
    ```sh
    kubectl exec -it <pod-name> -c main-app -n expert-ns -- /bin/bash
    ls -l /usr/share/nginx/html/
    # Retournera les fichiers par défaut de nginx. Pas de 'index.html' personnalisé.
    ```
    Cela prouve que le sidecar a échoué dans sa mission.

2.  **Analyser le Sidecar : La source du problème.**
    L'étape suivante est de regarder les logs du conteneur `config-loader-sidecar`.
    ```sh
    kubectl logs <pod-name> -c config-loader-sidecar -n expert-ns
    ```
    La sortie sera une boucle de messages d'erreur :
    ```
    Attempting to fetch configuration...
    Error from server (Forbidden): configmaps "app-html-config" is forbidden: User "system:serviceaccount:expert-ns:default" cannot get resource "configmaps" in API group "" in the namespace "expert-ns"
    Failed to fetch configmap. Retrying in 10 seconds...
    ```

3.  **La Révélation dans le Message d'Erreur.**
    Un expert décortiquera ce message. L'information la plus importante est `User "system:serviceaccount:expert-ns:default"`. Cela indique que la commande `kubectl` à l'intérieur du pod est exécutée en tant que `ServiceAccount` **"default"**, et non en tant que `app-service-account` que l'on a créé.

4.  **Connecter les Points.**
    L'expert a maintenant toutes les pièces du puzzle :
    *   Un `ServiceAccount` nommé `app-service-account` a été créé avec les bonnes permissions.
    *   Le pod exécute ses commandes API avec le `ServiceAccount` `default`.
    *   Conclusion : le pod n'a pas été configuré pour *utiliser* le bon `ServiceAccount`.

5.  **Inspection Finale.**
    L'expert inspectera le manifeste `04-deployment.yaml` ou la spécification du pod en cours d'exécution (`kubectl get pod <pod-name> -o yaml -n expert-ns`). Il constatera l'absence du champ `spec.template.spec.serviceAccountName`.

#### 4. La Solution

La solution consiste à ajouter une seule ligne au fichier `04-deployment.yaml` dans la section `spec.template.spec`.

*Fichier `04-deployment.yaml` corrigé :*
```yaml
...
  template:
    metadata:
      labels:
        app: webapp
    spec:
      serviceAccountName: app-service-account # <--- LA CORRECTION
      volumes:
...
```

Après avoir appliqué ce manifeste corrigé (`kubectl apply -f 04-deployment.yaml`), Kubernetes va créer un nouveau pod (en raison de la mise à jour du template). Ce nouveau pod :
1.  Sera associé au `app-service-account`.
2.  Le sidecar aura les permissions, lira le `ConfigMap` et écrira le fichier `index.html`.
3.  Le test avec `port-forward` affichera la page de succès.