## Étape 4 : Sécurité, isolation et secrets (AppProject & RBAC)

En production, utiliser le projet `default` et le rôle `admin` constitue une faille de sécurité majeure. Argo CD propose la CRD **AppProject** pour cloisonner les équipes (multi-tenancy) et un moteur **RBAC** fin.

### 1. La CRD `AppProject` (Isolation multi-tenant)

Un `AppProject` définit une frontière de sécurité stricte :

* Dépôts Git autorisés (`sourceRepos`).
* Clusters et namespaces cibles autorisés (`destinations`).
* Types de ressources Kubernetes autorisés ou interdits (`clusterResourceWhitelist`, `namespaceResourceWhitelist`).

Exemple de manifeste `project-dev.yaml` :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: dev-team
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io/foreground
spec:
  description: "Projet restreint pour l'équipe de développement"
  
  # Dépôts Git autorisés
  sourceRepos:
    - 'https://github.com/argoproj/argocd-example-apps.git'

  # Destinations (cluster + namespace) autorisées
  destinations:
    - namespace: 'guestbook-dev'
      server: 'https://kubernetes.default.svc'

  # Interdiction de créer des ressources Scope Cluster (ex: ClusterRole, StorageClass)
  clusterResourceWhitelist: []

  # Autorisation explicite de certaines ressources Scope Namespace
  namespaceResourceWhitelist:
    - group: ''
      kind: Service
    - group: ''
      kind: ConfigMap
    - group: 'apps'
      kind: Deployment

```

Applique ce projet sur ton cluster :

```bash
kubectl apply -f project-dev.yaml

```

*(Pour rattacher une application à ce projet, il suffit de modifier le champ `spec.project: dev-team` dans le manifeste de l'Application).*

### 2. Contrôle d'accès fin (RBAC)

Le RBAC d'Argo CD se configure via la ConfigMap `argocd-rbac-cm`. Il associe des utilisateurs ou groupes (OIDC / DEX / Keycloak) à des permissions granulaires.

Exemple d'injection de règles dans la ConfigMap :

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.csv: |
    # Syntaxe : p, subject, resource, action, object, allow/deny
    p, role:developer, applications, get, dev-team/*, allow
    p, role:developer, applications, sync, dev-team/*, allow
    p, role:developer, applications, delete, dev-team/*, deny
    
    # Association du rôle à un groupe d'utilisateurs
    g, dev-group, role:developer

```

### 3. Gestion des secrets en mode GitOps

Le principe fondamental du GitOps interdisant de commiter des secrets en clair dans Git, trois solutions principales sont utilisées :

| Solution | Fonctionnement | Cas d'usage principal |
| --- | --- | --- |
| **External Secrets Operator (ESO)** | Récupère les secrets depuis un coffre externe (Vault, AWS Secrets Manager) et crée les `Secrets` K8s natifs. | Standard entreprise (recommandé). |
| **Sealed Secrets (Bitnami)** | Chiffre les secrets avec la clé publique du cluster. Le `SealedSecret` est commité dans Git et déchiffré par le contrôleur. | Petites structures / Projets simples. |
| **Mozilla SOPS** | Chiffre les valeurs des clés YAML via KMS/PGP avant le commit Git. | Intégration Helm / Kustomize native. |

---

Voici l'implémentation complète pour la **gestion des utilisateurs locaux** et l'**activation du Terminal Web (`exec`) dans l'interface d'Argo CD**.

---

### 1. Mise à jour de la configuration via Helm (`argocd-values.yaml`)

Pour activer le terminal Web et déclarer des utilisateurs locaux, ajoute les sections `cm` (ConfigMap principale) et `rbac` à ton fichier `argocd-values.yaml` :

```yaml
configs:
  cm:
    # Activation du terminal Web (Terminal/Exec dans l'UI)
    exec.enabled: "true"

    # Création d'un utilisateur local "dev-user" avec droit de connexion
    accounts.dev-user: login

  rbac:
    # Politiques RBAC granulaires
    policy.csv: |
      # Permissions sur le projet "dev-team"
      p, role:developer, applications, get, dev-team/*, allow
      p, role:developer, applications, sync, dev-team/*, allow
      
      # Permission d'exécuter des commandes dans les Pods (Terminal Web)
      p, role:developer, exec, create, dev-team/*, allow

      # Association de l'utilisateur local au rôle
      g, dev-user, role:developer

```

---

### 2. Application des modifications

Mets à jour ton déploiement Argo CD via Helm :

```bash
helm upgrade argocd argo/argo-cd \
  --namespace argocd \
  -f argocd-values.yaml

```

---

### 3. Initialiser le mot de passe du nouvel utilisateur

Connecte-toi avec la CLI Argo CD en tant qu'administrateur, puis définis le mot de passe du compte `dev-user` :

```bash
# Définir le mot de passe du compte dev-user
argocd account update-password \
  --account dev-user \
  --current-password "P@ssword123!" \
  --new-password "DevUserP@ssword123!"

```

---

### 4. Vérification dans l'interface Web (GUI)

1. Déconnecte-toi de l'UI et reconnecte-toi avec l'identifiant **`dev-user`**.
2. Ouvre l'application `guestbook` (rattachée au projet `dev-team`).
3. Clique sur l'un des Pods de l'application : un onglet **Terminal** apparaît désormais en haut de la fenêtre du Pod.
4. Clique sur l'onglet pour ouvrir un shell interactif (`sh`/`bash`) directement depuis ton navigateur.

---
