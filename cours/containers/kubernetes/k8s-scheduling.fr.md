# KUBERNETES : Gestion des placements de pods

### Scheduling manuel

### Taints et Tolerations

Un nœud avec un taint empêche l'exécution sur lui-même des pods qui ne tolèrent pas ce _taint_

- Les _taints_ et _tolerations_ fonctionnent ensemble
- Les _taints_ sont appliqués aux nœuds
- Les _tolerations_ sont décrites aux niveau des pods
- On peut mettre plusieurs _taints_ sur un nœuds (il faudra que le pod tolère tous ces _taints_)
- Les _taints_ sont définis ainsi : `key=value:Effect`


![](images/kubernetes/taint-toleration.png){height="350px"}


### Taints et Tolerations : Champ "Effect"

Ce champ peut avoir 3 valeurs : `NoSchedule`, `PreferNoSchedule`, `NoExecute`

- NoSchedule : Contrainte forte, seuls les pods supportant le _taint_ pourront s'exécuter sur le nœud.
- PreferNoSchedule: Contrainte faible, le scheduler de kubernetes **évitera** de placer un pod qui ne tolère pas ce taint sur le nœud, mais pourra le faire si besoin
- NoExecute : Contrainte forte, les pods seront expulsés du nœud / ne pourront pas s'exécuter sur le nœuds


### Taints et Tolerations : Operateur

- Par valeur par défaut est `Equal` (`key=value:Effect`)
- Mais peut avoir aussi comme valeur `Exist` (`keyExist:Effect`) 


### Taints et Tolerations : Utilisation des _taints_

En ligne de commande

- Ajouter un taint
    - `kubectl taint nodes THENODE special=true:NoExecute`
    - `kubectl taint node worker-0 node-role.kubernetes.io/master="":NoSchedule`
    - `kubectl taint node worker-2 test:NoSchedule`

- Supprimer un taint
    - `kubectl taint nodes THENODE special=true:NoExecute-`
    - `kubectl taint node worker-0 node-role.kubernetes.io/master-`
    - `kubectl taint node worker-2 test:NoSchedule-`

- Lister les tains d'un nœud
    - `kubectl get nodes THENODE -o jsonpath="{.spec.taints}"`
    - `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master"}]`


### Taints et Tolerations : Utilisation des _tolerations_

- Les _tolerations_ peuvent être décrites au niveau des pods ou au niveau des templates de pods dans les replicaset, daemonset, statefulset et deployment.

- Ces _tolerations_ permettront aux pods de s'exécuter sur les nœuds qui ont le _taint_ correspondant.


### Taints et Tolerations : Exemples 

- Quand il n'y a pas de valeur (_value_) dans le taint

```yaml
apiVersion: v1
kind: Pod
metadata:
...
spec:
  tolerations:
    - key: node-role.kubernetes.io/master
      effect: NoSchedule
```

### Taints et Tolerations : Exemples (suite)

- Quand il y a une valeur (_value_)

```yaml
apiVersion: v1
kind: Pod
metadata:
...
spec:
  tolerations:
    - key:  special
      value: "true"
      effect: NoExecute
      Operator: Equal
```


### Taints et Tolerations : Cas particulier

Une clé vide avec un opérateur _Exist_ fera en sorte que le pod s'exécutera sur tous les nœuds quelque soit leurs _taints_

exemple :

```yaml
tolerations:
- operator: "Exists"
```


### nodeSelector

- Champs clé valeur au niveau des podSpecs
- Pour que le pod puisse s'exécuter il faut que le nœud ait l'ensemble des labels correspondants
  
![](images/kubernetes/nodeselector.png){height="450px"}


### nodeSelector exemple

Exemples 

- Pose du label sur un nœud
    - `kubectl label nodes <node-name> <label-key>=<label-value>`
    - ex: `kubectl label nodes worker-0 disktype=ssd`

- Utilisation dans un pod


```yaml

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    disktype: ssd

```


### Affinité / Anti-affinité

Ce système permet de gérer très finement les règles de placement des pods en regard de la simplicité du nodeSelector

- Le langage permettant d'exprimer les affinités / anti-affinités est riche de possibilités
- Possibilité de d'écrire des préférences `soft` (pod déployé malgré tout) ou `hard` (pod déployé uniquement si les règles sont respectées)
- Contraintes dépendantes de labels présents dans d'autres pods


![](images/kubernetes/affinities.png){height="550px"}



### Node Affinity

- Égal conceptuellement au _nodeSelector_, mais avec la possibilité de faire du **soft** (should) ou **hard** (must)
- Soft : `preferredDuringSchedulingIgnoredDuringExecution`
- Hard :  `requiredDuringSchedulingIgnoredDuringExecution`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In # (NotIn, Exists, DoesNotExist, Gt, Lt)
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In # (NotIn, Exists, DoesNotExist, Gt, Lt)
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```


### Un autre exemple

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
             - ssd
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```

### Pod Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0

```

### Pod anti-Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: topology.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: topology.kubernetes.io/zone
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0

```



