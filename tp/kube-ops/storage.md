# Stockage

Machine : **master**

```bash
training@master$ mkdir storage
training@master$ cd storage
training@master$ kubectl create namespace storage
```

## PersistentVolume et PersistentVolumeClaim

1. Commençons par définir un persistantvolume :

```bash
training@master$ touch postgres-pv.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
  namespace: storage
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

2. Nous allons donc créer ce pv :

```bash
training@master$ kubectl apply -f postgres-pv.yaml

persistentvolume/postgres-pv created
```

3. Nous pouvons récupérer des informations sur ce pv de la façon suivante :

```bash
training@master$ kubectl describe pv -n storage postgres-pv

Name:            postgres-pv
Labels:          type=local
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    manual
Status:          Available
Claim:           
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        10Gi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /mnt/data
    HostPathType:  
Events:            <none>
```

4. Nous allons maintenant définir un persistantvolumeclaim :

```bash
training@master$ touch postgres-pvc.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: storage
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

5. Nous allons créer ce pvc :

```bash
training@master$ kubectl apply -f postgres-pvc.yaml

persistentvolumeclaim/postgres-pvc created
```

6. Nous pouvons maintenant inspecter ce pvc :

```bash
training@master$ kubectl get pvc -n storage postgres-pvc

NAME           STATUS   VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-pvc   Bound    postgres-pv   10Gi       RWO            manual         14s
```

Notre pvc est maintenant **bound** a notre pv.

7. Nous allons maintenant définir un pod utilisant ce pvc :

```bash
training@master$ touch postgres-with-pvc-pod.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-with-pvc-pod
  namespace: storage
spec:
  volumes:
    - name: postgres-volume
      persistentVolumeClaim:
        claimName: postgres-pvc
  containers:
    - name: postgres-with-pvc
      image: postgres
      env:
      - name: POSTGRES_PASSWORD
        value: password
      volumeMounts:
        - mountPath: "/var/lib/postgresql/data"
          name: postgres-volume
```

8. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f postgres-with-pvc-pod.yaml

pod/postgres-with-pvc-pod created
```

9. Inspectons ce pod, nous devrions voir qu'il utilise bien notre pvc :

```bash
training@master$ kubectl describe pods -n storage postgres-with-pvc-pod

...
Volumes:
  postgres-volume:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  postgres-pvc
    ReadOnly:   false
...
```

## OpenEBS

1. Nous allons commencer par installer OpenEBS :

```bash
training@master$ helm repo add openebs https://openebs.github.io/charts
training@master$ helm repo update
training@master$ kubectl create namespace openebs-system
training@master$ helm install openebs openebs/openebs --namespace openebs-system

NAME: openebs
LAST DEPLOYED: Mon Oct 26 14:20:53 2020
NAMESPACE: openebs
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The OpenEBS has been installed. Check its status by running:

...
```

2. Par défault, OpenEBS cree plusieurs storageclasses, que nous pouvons voir de la façon suivante :

```bash
training@master$ kubectl describe storageclass openebs-jiva-default

Name:            openebs-jiva-default
IsDefaultClass:  No
Annotations:     cas.openebs.io/config=- name: ReplicaCount
  value: "3"
- name: StoragePool
  value: default
#- name: TargetResourceLimits
#  value: |-
#      memory: 1Gi
#      cpu: 100m
#- name: AuxResourceLimits
#  value: |-
#      memory: 0.5Gi
#      cpu: 50m
#- name: ReplicaResourceLimits
#  value: |-
#      memory: 2Gi
,openebs.io/cas-type=jiva
Provisioner:           openebs.io/provisioner-iscsi
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

3. Nous allons définir notre propre storage class utilisant openebs :

```bash
training@master$ touch longhorn.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    cas.openebs.io/config: |
      - name: ReplicaCount
        value: "1"
      - name: StoragePool
        value: default
    openebs.io/cas-type: jiva
  name: longhorn
provisioner: openebs.io/provisioner-iscsi
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

4. Créeons cette storage class :

```bash
training@master$ kubectl apply -f longhorn.yaml

storageclass.storage.k8s.io/longhorn created
```

5. Nous allons maintenant définir un pvc utilisant la storageclass openebs-jiva-default :

```bash
training@master$ touch postgres-openebs-pvc.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-openebs-pvc
  namespace: storage
spec:
  storageClassName: longhorn
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

6. Créeons donc ce pvc :

```bash
training@master$ kubectl apply -f postgres-openebs-pvc.yaml

persistentvolumeclaim/postgres-openebs-pvc created
```

7. Que nous pouvons inspecter de la façon suivante :

```bash
training@master$ kubectl get pvc -n storage postgres-openebs-pvc

NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
postgres-openebs-pvc   Bound    pvc-2aa4e773-290f-4a6b-839f-789f0e86b75d   3Gi        RWO            longhorn   12s
```

8. Nous pouvons également voir qu'un pv a été généré de façon automatique :

```bash
training@master$ kubectl get pv -n storage

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                          STORAGECLASS          REASON   AGE
pvc-2aa4e773-290f-4a6b-839f-789f0e86b75d   3Gi        RWO            Delete           Bound      storage/postgres-openebs-pvc   longhorn              52s
```

## Clean Up

Nous pouvons supprimer les objets générés par cet exercice de la facon suivante :

```bash
training@master$ kubectl delete -f postgres-openebs-pvc.yaml -f postgres-pv.yaml -f postgres-pvc.yaml -f postgres-with-pvc-pod.yaml

persistentvolumeclaim "postgres-openebs-pvc" deleted
persistentvolume "postgres-pv" deleted
persistentvolumeclaim "postgres-pvc" deleted
pod "postgres-with-pvc-pod" deleted
```
