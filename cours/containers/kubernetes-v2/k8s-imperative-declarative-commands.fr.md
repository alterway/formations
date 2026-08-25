# KUBERNETES : Méthodes Impérative vs Déclarative {-}

### Le Dilemme : Impératif vs Déclaratif

```{.center}
   APPROCHE IMPÉRATIVE                          APPROCHE DÉCLARATIVE
"Fais ceci, puis cela maintenant !"           "Voici l'état final que je veux."
        (Exécution directe)                         (GitOps / Versionné)
               │                                           │
               ▼                                           ▼
  kubectl run / kubectl create                   kubectl apply -f app.yaml
  Rapide en lab / CLI / Urgence                  Reproductible, auditable, CI/CD
```

![](images/kubernetes/imperative-declarative-k8s.jpg){height="260px"}


### Quand Utiliser Chaque Approche ?

| Critère | Impératif (`kubectl create/run/scale`) | Déclaratif (`kubectl apply / GitOps`) |
| :--- | :--- | :--- |
| **Idéal pour** | Examen CKA/CKAD, tests jetables, dépannage à chaud | Production, revue de code, déploiements automatisés |
| **Historique** | Non tracé (hors audit logs) | Versionné dans Git (Source of Truth) |
| **Gestion des Dérives** | Écrasement partiel sans contexte | Réconciliation automatique (`apply` 3-way merge) |

### L'Arme Secrète des Pros : Le Générateur de Boilerplate

Ne tapez jamais un squelette YAML à la main ! Utilisez l'impératif pour générer du déclaratif propre :

```bash
# 1. Générer le squelette d'un Pod multi-ports
kubectl run api-server --image=nginx:alpine --port=8080 --dry-run=client -o yaml > pod.yaml

# 2. Générer un Deployment 3 réplicas avec labels
kubectl create deployment web-backend --image=my-api:1.0 --replicas=3 --dry-run=client -o yaml > deploy.yaml

# 3. Générer un Service ClusterIP raccordé au port cible
kubectl expose deployment web-backend --port=80 --target-port=8080 --dry-run=client -o yaml > svc.yaml

# 4. Générer un ConfigMap à partir de variables
kubectl create configmap app-cfg --from-literal=DB_HOST=postgres --dry-run=client -o yaml > cm.yaml
```

### Le Cycle de Vie Déclaratif : Le « 3-Way Merge »

Quand vous faites `kubectl apply -f manifest.yaml`, Kubernetes compare 3 versions :

```{.center}
    [ Fichier Local (Nouveau souhait) ]
                   │
                   ▼
    [ Last-Applied-Configuration (Annotation dans l'objet) ]
                   │
                   ▼
    [ État Actuel en Direct dans etcd ]
```

- Cela permet de fusionner vos changements **sans écraser** les champs injectés dynamiquement (ex: annotations de monitoring, tokens de sécurité ou IP de statut).

### Détecter les Dérives : `kubectl diff`

Avant d'appliquer une modification en production :

```bash
# Affiche le diff exact entre le cluster et vos fichiers locaux (couleurs git diff)
kubectl diff -f k8s/production/

# Appliquer avec Server-Side Apply (standard moderne K8s 1.22+)
kubectl apply --server-side -f k8s/production/
```

### Mini-Défi : Le « Speedrun » YAML

**Objectif** : En moins de 30 secondes et sans ouvrir d'éditeur de texte, générez un fichier `stack.yaml` contenant à la fois un **Deployment** `redis` (image `redis:alpine`) et son **Service** `redis-svc` exposant le port TCP `6379`.



### Mini-Défi : Le « Speedrun » YAML

**Objectif** : En moins de 30 secondes et sans ouvrir d'éditeur de texte, générez un fichier `stack.yaml` contenant à la fois un **Deployment** `redis` (image `redis:alpine`) et son **Service** `redis-svc` exposant le port TCP `6379`.

```bash
# Solution en 2 lignes chainées :
kubectl create deployment redis --image=redis:alpine --dry-run=client -o yaml > stack.yaml
echo "---" >> stack.yaml
kubectl create service clusterip redis-svc --tcp=6379:6379 --dry-run=client -o yaml >> stack.yaml
```

