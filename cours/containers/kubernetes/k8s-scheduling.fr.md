# KUBERNETES : Gestion des placements des pods

### "Taints" et "Tolerations"

Un noeud avec un taint empeche l'execution sur lui-même des pods qui ne tolèrent pas ce "taint"

- Les "taints" et "tolerations" fonctionnent ensemble
- Les "taints" sont appliqués aux noeuds
- Les "tolerations" sont décrites aux niveau des pods
- On peut mettre plusieurs "taints" sur un noeuds (il faudra que le pod tolère tous ces taints)
- Les taints sont définis ainsi : `key=value:Effect`


### "Taints" et "Tolerations" : Champ "Effect"

Ce champ peut avoir 3 valeurs : `NoSchedule`, `PreferNoSchedule`, `NoExecute`

- NoSchedule : Contrainte forte, seuls les pods supportant le "taint" pourront s'éxécuter sur le noeud.
- PreferNoSchedule: Contrainte faible, le scheduler de kubernetes **évitera** de placer un pod qui ne tolère pas ce taint sur le noeud, mais pourra le faire si besoin
- NoExecute : Contrainte forte, les pods seront expulsés du noeud / ne pourront pas s'exécuter sur le noeuds


### "Taints" et "Tolerations" : Operateur

- Par valeur par défaut est `Equal` (`key=value:Effect`)
- Mais peut avoir aussi comme valeur `Exist` (`keyExist:Effect`) 


### "Taints" et "Tolerations" : Utilisation des "taints"

En ligne de commande

- Ajouter un taint
    - `kubectl taint nodes THENODE special=true:NoExecute`
    - `kubectl taint node node1 node-role.kubernetes.io/master="":NoSchedule`
    - `kubectl taint node node2 test:NoSchedule`

- Supprimer un taint
    - `kubectl taint nodes THENODE special=true:NoExecute-`
    - `kubectl taint node node1 node-role.kubernetes.io/master-`
    - `kubectl taint node node2 test:NoSchedule-`

- Lister les tains d'un noeud
    - `kubectl get nodes THENODE -o jsonpath="{.spec.taints}"`
    - `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master"}]`


### "Taints" et "Tolerations" : Utilisation des "tolerations"

- Les "tolerations" peuvent être décrite au niveau des pods ou au niveau des templates de pods danns les replicaset, daemonset, statefulset et deployment.

- Ces "tolerations" permettront aux pods de s'éxécuter sur les noeuds qui ont le "taint" en correspondance.


### "Taints" et "Tolerations" : Exemples 

- Quand il n'y a pas de values dans le taint

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

### "Taints" et "Tolerations" : Exemples (suite)

- Quand il y a une values

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


### "Taints" et "Tolerations" : Cas particuliers

Une clé vide avec un opérateur Exist fera en sorte que le pod s'excutera sur tous les noeuds quelques soit leurs "taint"

exemple :

```yaml
tolerations:
- operator: "Exists"
```


### nodeSelector

- Champs clé valeur au niveau des podSpecs
- Pour que le pod puisse s'éxécuter il faut que le noeuds est l'ensemble des labels correspondants
  
Exemples 

- Pose du label sur un noeud
    - `kubectl label nodes <node-name> <label-key>=<label-value>`
    - ex: `kubectl label nodes node1 disktype=ssd`

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
- Possibilité de d'écrire des préférences soft ou hard  (pod déployé malgré tout)
- Contraintes dépendantes de labels présents dans d'autres pods

### Node Affinity

- Égal conceptuellement au nodeSelector, mais avec la possibilité de faire du **soft** (should) ou **hard** (must)
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


### Autre exemple

```yaml
...
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disktype
                operator: In
                values:
                - ssd
```

### Pod Affinity

```yaml
...
  template:
    metadata:
      labels:
        app: redis
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - redis
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis-server
        image: redis:3.2-alpine
...
```

### Pod anti-Affinity`

```yaml
...
template:
    metadata:
      labels:
        app: web
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web
            topologyKey: "kubernetes.io/hostname"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - redis
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        
    ...

```

