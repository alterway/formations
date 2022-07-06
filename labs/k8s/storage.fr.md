# Stockage


<hr>
Machine : **master**
<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir storage
cd storage
kubectl create namespace storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## PersistentVolume et PersistentVolumeClaim

1. Commençons par définir un persistantvolume :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch postgres-pv.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Nous allons donc créer ce pv :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f postgres-pv.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*persistentvolume/postgres-pv created*

3. Nous pouvons récupérer des informations sur ce pv de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pv -n storage postgres-pv

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Nous allons maintenant définir un persistantvolumeclaim :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch postgres-pvc.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Nous allons créer ce pvc :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f postgres-pvc.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*persistentvolumeclaim/postgres-pvc created
*
6. Nous pouvons maintenant inspecter ce pvc :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pvc -n storage postgres-pvc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME           STATUS   VOLUME        CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-pvc   Bound    postgres-pv   10Gi       RWO            manual         14s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Notre pvc est maintenant **bound** a notre pv.

7. Nous allons maintenant définir un pod utilisant ce pvc :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch postgres-with-pvc-pod.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
          subPath: pgdata
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

8. Créons donc ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f postgres-with-pvc-pod.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/postgres-with-pvc-pod created*

9. Inspectons ce pod, nous devrions voir qu'il utilise bien notre pvc :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n storage postgres-with-pvc-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
Volumes:
  postgres-volume:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  postgres-pvc
    ReadOnly:   false
...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


<hr>

## Longhorn (rancher)

<hr>


1. Nous allons commencer par installer longhorn :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME: longhorn
LAST DEPLOYED: Fri Jul  1 11:45:19 2022
NAMESPACE: longhorn-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Longhorn is now installed on the cluster!

Please wait a few minutes for other Longhorn components such as CSI deployments, Engine Images, and Instance Managers to be initialized.

Visit our documentation at https://longhorn.io/docs/

...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Par défaut, lonhorn une classe de stockage (storageclasses) , que nous pouvons voir de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe storageclass longhorn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
Name:            longhorn
IsDefaultClass:  Yes
Annotations:     longhorn.io/last-applied-configmap=kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: longhorn
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: "Delete"
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "3"
  staleReplicaTimeout: "30"
  fromBackup: ""
  fsType: "ext4"
  dataLocality: "disabled"
,storageclass.kubernetes.io/is-default-class=true
Provisioner:           driver.longhorn.io
Parameters:            dataLocality=disabled,fromBackup=,fsType=ext4,numberOfReplicas=3,staleReplicaTimeout=30
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


3. Nous allons maintenant définir un pvc utilisant la storageclass longhorn :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch postgres-longhorn-pvc.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-longhorn-pvc
  namespace: storage
spec:
  storageClassName: longhorn
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Créons donc ce pvc :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f postgres-longhorn-pvc.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*persistentvolumeclaim/postgres-openebs-pvc created*

5. Que nous pouvons inspecter de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pvc -n storage postgres-longhorn-pvc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
postgres-longhorn-pvc   Bound    pvc-69b06a24-90e3-4ad9-8a25-5d7f4d216616   3Gi        RWO            longhorn       32s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Nous pouvons également voir qu'un pv a été généré de façon automatique :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pv -n storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                          STORAGECLASS          REASON   AGE
pvc-69b06a24-90e3-4ad9-8a25-5d7f4d216616   3Gi        RWO            Delete           Bound    storage/postgres-longhorn-pvc   longhorn                73s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


7. Utilisation de ce pvc 


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch postgres-with-longhorn-pvc-pod.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: postgres-with-longhorn-pvc-pod
  namespace: storage
spec:
  volumes:
    - name: postgres-volume
      persistentVolumeClaim:
        claimName: postgres-longhorn-pvc
  containers:
    - name: postgres-with-pvc
      image: postgres
      env:
      - name: POSTGRES_PASSWORD
        value: password
      volumeMounts:
        - mountPath: "/var/lib/postgresql/data"
          name: postgres-volume
          subPath: pgdata
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


8. Créons donc ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f postgres-with-longhorn-pvc-pod.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/postgres-with-longhorn-pvc-pod created*

9. Inspectons ce pod, nous devrions voir qu'il utilise bien notre pvc :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n storage postgres-with-longhorn-pvc-pod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

## Clean Up

<hr>

Nous pouvons supprimer les objets générés par cet exercice de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f postgres-longhorn-pvc.yaml -f postgres-pv.yaml -f postgres-pvc.yaml -f postgres-with-pvc-pod.yaml -f postgres-with-longhorn-pvc-pod.yaml

persistentvolumeclaim "postgres-openebs-pvc" deleted
persistentvolume "postgres-pv" deleted
persistentvolumeclaim "postgres-pvc" deleted
pod "postgres-with-pvc-pod" deleted
pod "postgres-with-longhorn-pvc-pod" deleted
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



<hr>

## ConfigMaps


<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
    redis-config: |
      maxmemory 2mb
      maxmemory-policy allkeys-lru

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-env
data:
   redis_host: "redis-svc"
   redis_port: "6349"

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
data:
   log_level: "NOTICE"
---

apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: REDIS_HOST
          valueFrom:
            configMapKeyRef:
              name: redis-env
              key: redis_host
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: env-config
              key: log_level
  restartPolicy: Never


---

apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod-v
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "cat /etc/config/" ]
      volumeMounts:
      - name: redis-conf-volume
        mountPath: /etc/config
  volumes:
    - name: redis-conf-volume
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: redis-config
  restartPolicy: Never

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>
