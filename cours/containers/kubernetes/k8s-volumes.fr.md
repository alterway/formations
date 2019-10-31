# Kubernetes : Stockage

### Kubernetes : Volumes

- Fournir du stockage persistent aux PODs
- Fonctionnent de la même façon que les volumes Docker pour les volumes hôte :
    - EmptyDir ~= volumes docker
    - HostPath ~= volumes hôte
- Support de multiples backend de stockage :
    - GCE : PD
    - AWS : EBS
    - GlusterFS / NFS
    - Ceph
    - iSCSI

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


### Kubernetes : PersistentVolumeClaims

- Ressource utilisée et vue comme une requête pour solliciter du stockage persistant
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


### Kubernetes : PersistentVolume

- Composant de stockage dans le cluster kubernetes
- Stockage externe aux noeuds du cluster
- Cycle de vie d'indépendant du pod qui le consomme
- Peut être provisionné manuellement par un administrateur ou dynamiquement grâce un `StorageClass`

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

