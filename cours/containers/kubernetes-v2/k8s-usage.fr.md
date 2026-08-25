# KUBERNETES : Piloter le Cluster avec `kubectl` & Kubeconfig {-}

### L'Arme Absolue de l'Ops : `kubectl`

![](images/kubectl.svg){height="150px"}

- CLI officiel pour interagir avec le `kube-apiserver`.
- Transforme chaque commande en appel REST HTTPS sécurisé.
- Lit par défaut sa configuration dans `~/.kube/config` ou via `$KUBECONFIG`.

```bash
# L'indispensable autocomplétion shell (Bash / Zsh)
source <(kubectl completion zsh)
alias k=kubectl
complete -o default -F __start_kubectl k
```

### Anatomie d'un Fichier `kubeconfig`

Un `kubeconfig` regroupe 3 entités distinctes :

```
      CLUSTERS                    USERS
 (URL API + CA TLS)         (Certificats / Tokens)
         │                            │
         └─────────────┬──────────────┘
                       ▼
                   CONTEXTS
      (Association Cluster + User + Namespace)
                       │
                       ▼
                CURRENT-CONTEXT
            (Le contexte actif ciblé)
```

![](images/kubeconfig-structure.png){height="260px"}

### Gérer Plusieurs Clusters Comme un Pro

Au lieu de jongler manuellement avec des fichiers dispersés :

```bash
# 1. Fusionner plusieurs kubeconfigs en une seule vue
export KUBECONFIG=~/.kube/config:~/.kube/eks-prod:~/.kube/gke-dev
kubectl config view --flatten > ~/.kube/config.all
mv ~/.kube/config.all ~/.kube/config

# 2. Utiliser kubectx et kubens pour changer en 1 clic
kubectx prod-cluster
kubens billing-app
```

### Explorer l'API : Ne Devinez Plus le YAML !

- **`kubectl api-resources`** : Découvre toutes les ressources supportées (CRDs, versions, abréviations, portée namespace).
- **`kubectl explain`** : La documentation intégrée directement dans votre terminal.

```bash
# Trouver la structure exacte d'un champ
kubectl explain pod.spec.containers.livenessProbe

# Explorer toute l'arborescence
kubectl explain deployment.spec.strategy --recursive
```

### Requêtes Expertes : Sortir des Tableaux Basiques

```bash
# 1. Vue enrichie immédiate
kubectl get pods -o wide

# 2. Colonnes sur mesure (Custom Columns)
kubectl get pods -o custom-columns=NAME:.metadata.name,IP:.status.podIP,NODE:.spec.nodeName

# 3. Tri avancé (ex: trier les pods par nombre de redémarrages)
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# 4. JSONPath chirurgical (extraire toutes les images utilisées)
kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort -u
```

### Sélecteurs de Labels : Filtrer à l'Échelle

Ne cherchez jamais vos pods un par un :

```bash
# Ciblage par égalité ou ensemble
kubectl get pods -l 'app=frontend,environment in (production, staging)'

# Afficher les labels directement dans les colonnes
kubectl get pods -L app,version,tier
```

### L'Écosystème des Plugins `krew`

`krew` est le gestionnaire de paquets officiel pour étendre `kubectl` :

```bash
kubectl krew install ctx ns neat who-can tree

# kubectl-tree : Visualise toute la hiérarchie d'objets créés par un Deployment
kubectl tree deploy web-app

# kubectl-who-can : Qui a le droit de supprimer des namespaces ?
kubectl who-can delete namespaces
```

### Mini-Défi : La Commande Ninja

**Objectif** : Vous suspectez une fuite de mémoire sur un cluster de 150 pods. 

Quelle commande en une ligne permet de lister le nom de tous les pods ayant déjà redémarré au moins 1 fois, triés par leur nœud ?


## Mini-Défi : La Commande Ninja

**Objectif** : Vous suspectez une fuite de mémoire sur un cluster de 150 pods. 

Quelle commande en une ligne permet de lister le nom de tous les pods ayant déjà redémarré au moins 1 fois, triés par leur nœud ?

```bash
# Solution experte :
kubectl get pods --field-selector status.phase=Running \
  -o custom-columns=POD:.metadata.name,NODE:.spec.nodeName,RESTARTS:.status.containerStatuses[0].restartCount \
  --sort-by='.spec.nodeName'
```
