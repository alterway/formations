# KUBERNETES : Dimensionnement, CPU/RAM & Quotas {-}

### Le Défi SRE : Ni Pénurie, Ni Gaspillage

```
   SUR-ALLOCATION (Gaspillage)                     SOUS-ALLOCATION (Instabilité)
Requests trop hautes = Nœuds vides              Requests trop basses = Noisy neighbors,
   Facture Cloud x3 inutile !                      OOMKilled & CPU Throttling !
```

- **Requests** : Ce que le `kube-scheduler` réserve pour décider sur quel nœud placer le Pod.
- **Limits** : Le plafond absolu imposé par le noyau Linux (cgroups v2) au runtime.

![](images/kubernetes/resource-quota-limitrange.gif){height="220px"}

### CPU vs RAM : Deux Comportements Radicaux

| Ressource | Nature | Comportement en cas de Dépassement | Unité |
| :--- | :--- | :--- | :--- |
| **CPU** | *Compressible* | **CPU Throttling** : Le processus est bridé en temps CPU (latence p99 explose, mais le pod reste vivant). | Millicores (`500m` = 0.5 vCPU) |
| **Mémoire (RAM)** | *Incompressible* | **OOMKilled (Code 137)** : Le Kernel Linux tue instantanément le conteneur via un `SIGKILL`. | Mébibytes (`256Mi`, `1Gi`) |



Un mébibyte (MiB ) est également une unité d'information numérique, mais il est basé sur le système binaire. Un mébibyte équivaut à 1024 x 1024 octets = 1 048 576 octets, soit 2^20 octets. Le terme "mébibyte" a été introduit par la Commission électrotechnique internationale (CEI) en 1998 pour établir une distinction claire avec le mégaoctet basé sur le système décimal. Malheureusement, le terme mébibyte n'a pas encore été adopté par le grand public, de sorte que vous verrez régulièrement "mégaoctet" ou simplement MB, se référant soit à 1 000 000 d'octets, soit à 1 048 576 octets, sans savoir lequel est le bon.

### CPU vs RAM : Deux Comportements Radicaux (Suite)

```yaml
resources:
  requests:
    cpu: "200m"      # 0.2 vCPU garanti
    memory: "256Mi"  # 256 MiB réservés
  limits:
    cpu: "1000m"     # Max 1 vCPU
    memory: "512Mi"  # Au-delà de 512MiB -> Crash OOMKilled !
```

### Les 3 Classes de Qualité de Service (QoS)

Kubernetes classe automatiquement chaque Pod pour savoir qui sacrifier en premier en cas de saturation d'un nœud :

```
1. Guaranteed (Protégé) ──► requests == limits (CPU et RAM) pour tous les conteneurs
2. Burstable (Standard) ──► Au moins 1 request définie, requests < limits
3. BestEffort (Sacrifié) ──► Aucune request ni limit définie
```

> En cas de pénurie de mémoire sur un Worker Node, le Kubelet évince et détruit en priorité les Pods **BestEffort**, puis **Burstable**, et enfin **Guaranteed** en tout dernier recours.

### Gouvernance : LimitRange vs ResourceQuota

```
         LIMITRANGE                             RESOURCEQUOTA
  (S'applique à CHAQUE Pod)             (S'applique à TOUT le Namespace)
             │                                         │
             ▼                                         ▼
Injecte des requests par défaut         Plafonne la consommation totale
et empêche les pods démesurés           (ex: Max 32 vCPU et 64GiB au total)
```

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "20Gi"
    limits.cpu: "20"
    limits.memory: "40Gi"
    pods: "30"
```

### Mini-Défi : Le Mystère du Pod Pending

**Scénario d'incident** : Vous déployez un pod avec `requests.cpu: "4"`. 
En regardant avec `htop` sur le Worker Node, le CPU réel consommé n'est que de 10%. Pourtant, le Pod reste bloqué en statut `Pending`. Pourquoi ?


### Mini-Défi : Le Mystère du Pod Pending

**Scénario d'incident** : Vous déployez un pod avec `requests.cpu: "4"`. 
En regardant avec `htop` sur le Worker Node, le CPU réel consommé n'est que de 10%. Pourtant, le Pod reste bloqué en statut `Pending`. Pourquoi ?

**Réponse** : Le scheduler prend ses décisions sur la base de la **somme des Requests réservées**, et non sur la charge réelle du CPU à l'instant T ! Si les autres pods ont réservé tout le CPU théorique du nœud, le scheduler refuse d'en ajouter un nouveau.

