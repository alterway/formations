# KUBERNETES : Maintenance, Drains & Mises à Niveau {-}

### La Procédure de Maintenance d'un Nœud Sans Interruption

```
[ Nœud Actif avec Pods ] ──► [ 1. CORDON ] ──► Aucun nouveau pod n'est admis
                                   │
                                   ▼
                             [ 2. DRAIN ]  ──► Évacue les pods vers d'autres nœuds
                                   │           (En respectant les PDB !)
                                   ▼
                             [ 3. REBOOT / UPGRADE OS ]
                                   │
                                   ▼
                             [ 4. UNCORDON ] ──► Nœud réactivé et sain !
```

### 1. Cordon & Drain en Pratique

```bash
# Étape 1 : Empêcher le scheduling sur le nœud
kubectl cordon worker-01

# Étape 2 : Évacuer tous les pods proprement
kubectl drain worker-01 --ignore-daemonsets --delete-emptydir-data

# Étape 3 : Une fois la maintenance terminée (reboot, kernel patch...)
kubectl uncordon worker-01
```

- `--ignore-daemonsets` : Indispensable pour ne pas bloquer sur les agents locaux de logs/monitoring.
- `--delete-emptydir-data` : Accepte la suppression des données locales temporaires.

### 2. Le Garde-Fou Absolu : `PodDisruptionBudget` (PDB)

Sans PDB, un `drain` peut tuer tous les réplicas d'un service en même temps et créer une coupure de service !

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: bookstore-pdb
spec:
  minAvailable: 2     # Garantit qu'au moins 2 pods restent vivants en permanence !
  selector:
    matchLabels:
      app: bookstore
```

- Le `kubectl drain` sera mis en attente et évincera les pods un par un, en attendant que le nouveau pod soit `Ready` avant de tuer le suivant.

### 3. Stratégie de Mise à Niveau du Cluster (`kubeadm`)

```
   1. Mettre à niveau le Control Plane Master 1
      $ sudo apt update && sudo apt install -y kubeadm=1.31.0-1.1
      $ sudo kubeadm upgrade plan
      $ sudo kubeadm upgrade apply v1.31.0
      $ sudo apt install -y kubelet=1.31.0-1.1 kubectl=1.31.0-1.1
      $ sudo systemctl daemon-reload && sudo systemctl restart kubelet
            │
            ▼
   2. Mettre à niveau les Worker Nodes (Un par Un !)
      $ kubectl drain worker-01 ...
      $ sudo kubeadm upgrade node
      $ sudo apt install -y kubelet=1.31.0-1.1
      $ sudo systemctl restart kubelet
      $ kubectl uncordon worker-01
```

### 4. Sauvegarde & Disaster Recovery avec Velero

![](images/kubernetes/dashboard-ns.png){height="180px"}

- **Velero (CNCF)** : L'outil standard de sauvegarde et de migration de clusters.
- Sauvegarde la totalité des manifests dans un bucket S3/GCS et déclenche des snapshots des disques persistants (CSI).

```bash
# Sauvegarder tout le namespace production en 1 commande
velero backup create prod-backup-$(date +%F) --include-namespaces production

# Restaurer l'environnement complet en cas de désastre
velero restore create --from-backup prod-backup-2026-08-25
```

### Mini-Défi : Le Drain Bloqué

**Incident SRE** : Vous lancez `kubectl drain worker-02`, mais la commande reste bloquée indéfiniment avec le message :
`Cannot evict pod: PodDisruptionBudget "api-pdb" is currently violated`.

Quel est le problème et comment le résoudre proprement ?


### Mini-Défi : Le Drain Bloqué

**Incident SRE** : Vous lancez `kubectl drain worker-02`, mais la commande reste bloquée indéfiniment avec le message :
`Cannot evict pod: PodDisruptionBudget "api-pdb" is currently violated`.

Quel est le problème et comment le résoudre proprement ?

(Réponse : L'application a un PDB exigeant `minAvailable: 2`, mais il n'y a plus assez de place sur les autres nœuds du cluster pour démarrer le second pod. Solution : Ajouter un nouveau worker node au cluster ou augmenter temporairement les ressources disponibles pour débloquer l'éviction).