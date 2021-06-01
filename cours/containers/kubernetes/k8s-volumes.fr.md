# KUBERNETES : Stockage

### Kubernetes : Volumes

- Fournir du stockage persistent aux PODs
    - Definis au niveau pod
- On le même cycle de vie que le pod
    - Quand le pod est supprimé le volume aussi
    - Les différents type de volumes sont implémentés comme des puglins
    - Les comportement sous-jacents dépendent du backend
- Fonctionnent de la même façon que les volumes Docker pour les volumes hôte :
    - `EmptyDir` ~= volumes docker
    - `HostPath` ~= volumes hôte

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

- On déclare d'abord le volume et on l'affecte à un service :

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


### Kubernetes : Storage Class

- Permet de définir les différents types de stockage disponibles
- Utilisé par les `Persistent Volumes` pour solliciter un espace de stockage au travers des `Persistent Volume Claims`


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

### Kubernetes : PersistentVolumeClaims

- Ressource utilisée et vue comme une requête utilisateur pour solliciter du stockage persistant en définissant :
    - une quantité de stockage
    - un type d'accès
    - un namespace pour le montage
- Offre aux PV une variété d'options en fonction du cas d'utilisation
- Utilisé par les `StatefulSets` pour solliciter du stockage (Utilisaltion du champ `volumeClaimTemplates`)


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
        claimName: myclaim```

### Kubernetes : PersistentVolume

- Composant de stockage dans le cluster kubernetes
- Stockage externe aux noeuds du cluster
- Cycle de vie d'indépendant du pod qui le consomme
- Peut être provisionné manuellement par un administrateur ou dynamiquement grâce un `StorageClass`
- Supporte différent mode d'accès
    - RWO - read-write par un noeud unique
    - ROX - read-only par plusieurs noeuds
    - RWX - read-write par plusieurs noeuds

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

### Kubernetes : CSI

- [Container Storage Interface](https://github.com/container-storage-interface/spec/blob/master/spec.md)
- Implémentation Standardisée du stockage
- Équivalent de CNI mais pour les volumes
- Avant Kubernetes 1.13, tous les drivers de volumes étaient *in tree*
- Le but de la séparation est de sortir du code du *core* de Kubernetes
- GA depuis Kubernetes 1.13

### Kubernetes : CSI

- La plupart des volumes supportés dans Kubernetes supportent maintenant CSI:
  - [Amazon EBS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
  - [Google PD](https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver)
  - [Cinder](https://github.com/kubernetes/cloud-provider-openstack/tree/master/pkg/csi/cinder)
  - [GlusterFS](https://github.com/gluster/gluster-csi-driver)
  - La liste exhaustive est disponible [ici](https://kubernetes-csi.github.io/docs/drivers.html)

