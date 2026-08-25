# KUBERNETES : Stockage Persistant & CSI {-}

### Éphémère vs Persistant : L'Architecture du Stockage

```
           ÉPHÉMÈRE                                       PERSISTANT
  (Meurt avec le Pod)                         (Survit à la destruction du Pod)
           │                                                  │
           ▼                                                  ▼
  emptyDir / configMap / secret                  PersistentVolumeClaim (PVC)
  Cache local, scratchpad, RAM                   Bases de données, fichiers partagés
```

![](images/kubernetes/persistent-volume-claims-k8.png){height="220px"}

### Les Volumes Éphémères

1. **`emptyDir`** :
   - Créé au démarrage du Pod, détruit à sa mort.
   - Idéal pour partager des fichiers temporaires entre un conteneur principal et un sidecar.
   - Peut être monté en RAM (`medium: Memory`) pour des performances maximales.
2. **`hostPath`** :
   - Monte un dossier physique du Worker Node (ex: `/var/log`).
   - ⚠️ *Danger en production* : Si le pod migre sur un autre nœud, il ne retrouve pas ses données.

### Le Trio Gagnant : StorageClass, PV & PVC

```
  1. L'Administrateur déclare le fournisseur
     [ StorageClass: "fast-ssd" ] (AWS gp3, GCP pd-ssd, Ceph)
                  │
                  ▼ (Provisionnement Dynamique automatique)
  2. Le Développeur demande du stockage
     [ PersistentVolumeClaim (PVC) : 50Gi, ReadWriteOnce ]
                  │
                  ▼ (Liaison / Binding automatique)
  3. Kubernetes crée le volume physique
     [ PersistentVolume (PV) : 50Gi alloué sur le Cloud/SAN ]
                  │
                  ▼
  4. Monté dans le Pod : /var/lib/postgresql/data
```

![](images/kubernetes/storage-class.png){height="220px"}

### Les Modes d'Accès aux Volumes

| Mode d'Accès | Abréviation | Description | Exemples Typiques |
| :--- | :--- | :--- | :--- |
| **ReadWriteOnce** | `RWO` | Montable en lecture/écriture par **1 seul Nœud à la fois** | Disques Blocs Cloud (AWS EBS, GCP PD, Azure Disk) |
| **ReadOnlyMany** | `ROX` | Montable en lecture seule par **plusieurs Nœuds** | Dépôt de binaires, modèles IA statiques |
| **ReadWriteMany** | `RWX` | Montable en lecture/écriture par **plusieurs Nœuds simultanément** | NFS, CephFS, AWS EFS, Azure Files |
| **ReadWriteOncePod** | `RWOP` | Montable en lecture/écriture par **1 seul Pod unique** | Verrouillage exclusif haute sécurité |

### Exemple de Manifeste PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: premium-ssd-csi
  resources:
    requests:
      storage: 50Gi
```

- Le StorageClass s'occupe d'appeler l'API Cloud (via le driver **CSI**) pour créer le disque automatiquement.

### Politiques de Récupération (Reclaim Policy)

Que devient le disque physique (PV) quand le développeur supprime le PVC ?

- **`Delete` (par défaut)** : Le volume physique dans le Cloud/SAN est **immédiatement détruit**.
- **`Retain` (recommandé en production)** : Le volume physique est conservé avec ses données pour permettre une récupération manuelle en cas d'erreur humaine.

### Mini-Défi : Le PVC Bloqué en Pending

**Scénario d'incident** : Vous créez un PVC avec `storageClassName: standard` et `accessModes: [ReadWriteMany]` sur un cluster EKS avec disques EBS.

Le PVC reste indéfiniment en statut `Pending`. Pourquoi ?


### Mini-Défi : Le PVC Bloqué en Pending

**Scénario d'incident** : Vous créez un PVC avec `storageClassName: standard` et `accessModes: [ReadWriteMany]` sur un cluster EKS avec disques EBS.

Le PVC reste indéfiniment en statut `Pending`. Pourquoi ?

(Réponse : Les disques blocs EBS d'AWS ne supportent que le mode **ReadWriteOnce** (RWO). Le provisionneur CSI refuse d'allouer un disque EBS pour une demande de type ReadWriteMany (RWX), qui nécessite un système de fichiers distribué comme EFS / NFS)
