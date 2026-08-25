# KUBERNETES : Ordonnancement & Stratégies de Placement {-}

### L'Objectif : Maîtriser le Placement des Pods

```
       ATTIRER des Pods                            REPOUSSER des Pods
  (Affinité & Sélecteurs de Nœuds)              (Taints & Tolerations)
               │                                           │
               ▼                                           ▼
"Ce pod IA DOIT tourner sur                    "Ce nœud GPU est réservé,
 des machines équipées de GPU"                  aucun pod standard n'y entre !"
```

![](images/kubernetes/affinities.png){height="220px"}

### 1. Du Simple `nodeSelector` à la `nodeAffinity`

```yaml
# Méthode 1 : nodeSelector basique
spec:
  nodeSelector:
    disktype: ssd

# Méthode 2 : nodeAffinity Avancée (Hard vs Soft)
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution: # Hard (Obligatoire)
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values: [eu-west-1a, eu-west-1b]
      preferredDuringSchedulingIgnoredDuringExecution: # Soft (Préférentiel)
      - weight: 80
        preference:
          matchExpressions:
          - key: instance-type
            operator: In
            values: [c5.xlarge]
```

### 2. Haute Disponibilité : `podAntiAffinity` & `topologySpreadConstraints`

Pour éviter que tous vos pods ne tombent si une seule zone de disponibilité (AZ) du Cloud crashe :

```yaml
spec:
  topologySpreadConstraints:
  - maxSkew: 1                             # Tolérance max de déséquilibre : 1 pod d'écart
    topologyKey: topology.kubernetes.io/zone # Répartir entre les datacenters / AZs
    whenUnsatisfiable: DoNotSchedule       # Bloquer si la règle n'est pas respectée
    labelSelector:
      matchLabels:
        app: bookstore-api
```

- *`topologySpreadConstraints` est le standard moderne recommandé pour équilibrer parfaitement les charges.

### 3. Taints & Tolerations : La Ségrégation des Nœuds

![](images/kubernetes/taint-toleration.png){height="220px"}

- **Taint (sur le Nœud)** : `kubectl taint nodes node-gpu dedicated=gpu:NoSchedule`
- **Toleration (sur le Pod)** : Seul un Pod ayant cette tolérance peut s'installer sur le nœud.
- **Les 3 Effets** :
  1. `NoSchedule` : Empêche le placement des nouveaux pods non tolérants.
  2. `PreferNoSchedule` : Évite si possible, mais accepte en dernier recours.
  3. `NoExecute` : **Expulse immédiatement** les pods déjà présents s'ils ne tolèrent pas le taint !

### Résumé Visuel des Règles de Placement

| Mécanisme | Portée | Type de Règle | Cas d'Usage Typique |
| :--- | :--- | :--- | :--- |
| **`nodeSelector`** | Nœud | Binaire (Strict) | Cibler un type d'instance simple (ex: SSD) |
| **`nodeAffinity`** | Nœud | Hard (`required`) / Soft (`preferred`) | Ciblage multi-zones & architectures CPU |
| **`podAntiAffinity`** | Pod $\leftrightarrow$ Pod | Hard / Soft | Répartir les réplicas sur des hôtes distincts |
| **`topologySpread`** | Nœuds / Zones | Étalement uniforme | Équilibrer les pods sur plusieurs AZs |
| **`Taints / Tolerations`** | Nœud $\leftrightarrow$ Pod | Répulsion (`NoSchedule` / `NoExecute`) | Nœuds GPU, isolation Control Plane, maintenance |

### Mini-Défi : Le Pod Éjecté

**Question flash** : Vous exécutez la commande suivante sur un worker node hébergeant 10 pods de production :
`kubectl taint node worker-1 maintenance=true:NoExecute`

Que se passe-t-il pour ces 10 pods ?

*(Réponse : S'ils n'ont pas de `tolerations` explicite pour `maintenance=true`, ils sont **immédiatement tués et expulsés** (NoExecute). Le Deployment Controller recréera de nouveaux pods sur les autres nœuds sains).*
