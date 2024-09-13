# KUBERNETES : Stockage


### Kubernetes : CSI

- [Container Storage Interface](https://github.com/container-storage-interface/spec/blob/master/spec.md)
- Implémentation Standardisée du stockage
- Équivalent de CNI mais pour les volumes
- Avant Kubernetes 1.13, tous les drivers de volumes étaient *in tree*
- Le but de la séparation est de sortir du code du *core* de Kubernetes
- GA depuis Kubernetes 1.13

![](images/kubernetes/csi.webp){height="400px"}



### Kubernetes : CSI

- La plupart des volumes supportés dans Kubernetes supportent maintenant CSI:
    - [Amazon EBS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
    - [Google PD](https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver)
    - [Cinder](https://github.com/kubernetes/cloud-provider-openstack/tree/master/pkg/csi/cinder)
    - [GlusterFS](https://github.com/gluster/gluster-csi-driver)
    - La liste exhaustive est disponible [ici](https://kubernetes-csi.github.io/docs/drivers.html)
    - Drivers CSI: Chaque système de stockage nécessite un driver CSI spécifique pour s'intégrer à Kubernetes.
    - Points de montage: Les drivers CSI créent des points de montage que Kubernetes peut ensuite attacher aux pods.
   - Cycle de vie des volumes: Le CSI gère le cycle de vie complet des volumes (provisionnement, attachement, détachement, suppression).


![](images/kubernetes/dell-csi.png){height="400px"}



### Kubernetes : Volumes

- Fournir du stockage persistent aux PODs
    - Défini au niveau pod
- On le même cycle de vie que le pod
    - Quand le pod est supprimé le volume aussi
    - Les différents type de volumes sont implémentés comme des plugins
    - Les comportement sous-jacents dépendent du backend
- Fonctionnent de la même façon que les volumes Docker pour les volumes hôte :
    - `EmptyDir` ~= volumes docker
    - `HostPath` ~= volumes hôte


![](images/kubernetes/volumes.webp){height="400px"}





### Type de Volumes

<div class="wrapper">

<div class="left">

- emptyDir
- hostPath
- gcePersistentDisk
- awsElasticBlockStore
- nfs
- iscsi
- fc (fibre channel)
- flocker
- glusterfs
- rbd
- cephfs
  
</div>

<div class="right">

- secret
- persistentVolumeClaim
- downwardAPI
- projected
- azureFileVolume
- azureDisk
- vsphereVolume
- Quobyte
- PortworxVolume
- ScaleIO
- StorageOS
- local
  
</div>
</div>


### Kubernetes : Volumes

- On déclare d'abord le volume et on l'affecte à un "service" (container) :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-persistent-storage
      mountPath: /data/redis
  volumes:
  - name: redis-persistent-storage
    emptyDir: {}
```

### Kubernetes : Volumes

- Autre exemple

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: redis-persistent-storage-host
      mountPath: /data/redis
  volumes:
  - name: redis-persistent-storage-host
    hostPath:
      path: /mnt/data/redis
```


### Type de stockage

- `Persistent Volume` (PV)        : Représentation de bas niveau d'un volume de stockage.
- `Persistent Volume Claim` (PVC) : binding entre un Pod et un Persistent Volume (PV).
- `Storage Class`                 :  Permet de provionner dynamiquement d'un Persistent Volumes (PV).


![](images/kubernetes/storage.png){height="300px"}



### Kubernetes : Storage Class

- Permet de définir les différents types de stockage disponibles
- StorageClass permet le provisionnement dynamique des volumes persistants, lorsque PVC le réclame.
- Utilisé par les `Persistent Volumes` pour solliciter un espace de stockage au travers des `Persistent Volume Claims`
- StorageClass utilise des provisionneurs spécifiques à la plate-forme de stockage ou au fournisseur de cloud pour donner à Kubernetes l'accès au stockage physique.
- Chaque backend de stockage a son propre provisionneur. Le backend de stockage est défini dans le composant StorageClass via l'attribut provisioner.


### Kubernetes : Storage Class

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: slow
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  zones: us-east-1d, us-east-1c
  iopsPerGB: "10"
```

### Kubernetes : Storage Class
Autre exemple 

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-premium
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
    kubernetes.io/cluster-service: "true"
parameters:
  cachingmode: ReadOnly
  kind: Managed
  storageaccounttype: Premium_LRS
provisioner: kubernetes.io/azure-disk
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```

### Kubernetes : Storage Class
Autre exemple 

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: local-path
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

### Kubernetes : PersistentVolume

- Composant de stockage dans le cluster kubernetes
- Stockage externe aux noeuds du cluster
- Cycle de vie d'indépendant du pod qui le consomme
- Peut être provisionné **manuellement** par un administrateur ou **dynamiquement** grâce une `StorageClass`
- Supporte différent mode d'accès
    - RWO - read-write par un noeud unique
    - ROX - read-only par plusieurs noeuds
    - RWX - read-write par plusieurs noeuds


![](images/kubernetes/persistent-volume-claims-k8.png){height="300px"}


### Kubernetes : PersistentVolume

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: persistent-volume-1
spec:
  storageClassName: slow
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/data"
```


### Reclaim Policy

- Les PV qui sont créés dynamiquement par une `StorageClass` auront la politique de récupération spécifiée dans le champ `reclaimPolicy` de la classe, qui peut être `Delete` ou `Retain`.
- Si aucun `reclaimPolicy` n'est spécifié lors de la création d'un objet `StorageClass`, il sera par défaut `delete`.

- Les PV qui sont créés manuellement et gérés via une `StorageClass` auront la politique de récupération qui leur a été attribuée lors de la création.

- La stratégie de récupération s'applique aux volumes persistants et non à la classe de stockage elle-même. Les PV et les PVC créés à l'aide de cette `StorageClass` hériteront de la stratégie de récupération définie dans `StorageClass`.


### Kubernetes : PersistentVolumeClaims

- Le PVC est un binding entre un `pod` et un `PV`. Le pod demande le volume via le PVC.
- Le liage est géré automatiquement par Kubernetes.
- Ressource utilisée et vue comme une requête utilisateur pour solliciter du stockage persistant en définissant :
    - une quantité de stockage
    - un type d'accès
    - un namespace pour le montage
- Offre aux PV une variété d'options en fonction du cas d'utilisation
- Kubernetes recherche un PV qui répond aux critères définis dans le PVC, et s'il y en a un, il fait correspondre la demande au PV.
- Utilisé par les `StatefulSets` pour solliciter du stockage (Utilisation du champ `volumeClaimTemplates`)
- Le PVC doit se trouver dans le même namespace que le pod. Pour chaque pod, un PVC effectue une demande de stockage dans un namespace.
- Les "Claim"" peuvent demander une taille et des modes d'accès spécifiques (par exemple, elles peuvent être montées ReadWriteOnce, ReadOnlyMany ou ReadWriteMany).



![](images/kubernetes/persistent-volume-and-persistent-volume-claim.png){height="300px"}


### Kubernetes : PersistentVolumeClaims

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: storage-claim
spec:
    accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: "slowl"
  selector:
    matchLabels:
      release: "stable"
    matchExpressions:
      - {key: capacity, operator: In, values: [10Gi, 20Gi]}
```

### Kubernetes : PersistentVolumeClaims

Utilisation d'un PVC dans un pod

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: myapp
spec:
  containers:
  - name: myapp
    image: nginx
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: mywebsite
    volumes:
    - name: mywebsite
      persistentVolumeClaim:
        claimName: myclaim
```


### Kubernetes : Provisionnement Dynamique

![](images/kubernetes/storage-class.png){height="700px"}

