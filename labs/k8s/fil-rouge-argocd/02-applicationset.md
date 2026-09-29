## Étape 3 : Multi-cluster et ApplicationSet

Gérer des objets `Application` individuellement fonctionne pour quelques microservices. Mais lorsque l'on gère des dizaines de microservices ou plusieurs clusters (Dev, Staging, Prod), créer un fichier `Application` par environnement devient verbeux et répétitif.

C'est là qu'intervient la CRD **`ApplicationSet`**. Elle automatise la génération dynamique et la gestion du cycle de vie des objets `Application`.

---

### 1. App-of-Apps vs ApplicationSet

* **Pattern App-of-Apps (historique)** : Une `Application` Argo CD racine pointe vers un dossier Git contenant les définitions YAML d'autres objets `Application`.
* **ApplicationSet (moderne & recommandé)** : Un contrôleur natif qui utilise un **template** et un ou plusieurs **générateurs** pour créer dynamiquement les objets `Application`.

---

### 2. Les Générateurs clés

Les générateurs fournissent des paramètres sous forme de variables (ex: `{{env}}`, `{{cluster}}`, `{{path}}`) injectées dans le template :

1. **`List`** : Définit une liste explicite de paires clé/valeur dans le YAML.
2. **`Git`** : Scanne un dépôt Git et génère une `Application` pour chaque dossier ou fichier de configuration trouvé.
3. **`Cluster`** : Découvre automatiquement tous les clusters membres enregistrés dans Argo CD.
4. **`Matrix`** : Combine deux générateurs (produit cartésien). *Exemple : (Cluster Dev, Cluster Prod) x (App Frontend, App Backend)*.

---

### 3. TP Pratique : ApplicationSet avec un générateurs `List`

Créons un fichier `applicationset-environments.yaml` qui va générer automatiquement deux environnements distincts (`dev` et `staging`) à partir d'un seul manifeste :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook-multienv
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: https://kubernetes.default.svc
          - env: staging
            cluster: https://kubernetes.default.svc
  template:
    metadata:
      name: 'guestbook-{{env}}'
      finalizers:
        - resources-finalizer.argocd.argoproj.io/foreground
    spec:
      project: default
      source:
        repoURL: https://github.com/argoproj/argocd-example-apps.git
        targetRevision: HEAD
        path: guestbook
      destination:
        server: '{{cluster}}'
        namespace: 'guestbook-{{env}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true

```

---

### 4. Déploiement et observation

Applique ce manifeste sur ton cluster :

```bash
kubectl apply -f applicationset-environments.yaml

```

Vérifie ce que l'ApplicationSet a généré :

```bash
# Vérifier la CRD ApplicationSet
kubectl get applicationset -n argocd

# Constater que deux objets Application distincts ont été créés automatiquement
kubectl get app -n argocd

```

Dans l'interface web, tu verras apparaître deux nouvelles cartes d'applications : `guestbook-dev` et `guestbook-staging`. Si tu ajoutes un troisième élément (ex: `env: prod`) dans le bloc `list` et que tu réappliques le fichier, la troisième application sera instanciée immédiatement.

---
