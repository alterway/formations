# Pod Security Policy

Machine : **master**

```bash
training@master$ mkdir psp
training@master$ cd psp
training@master$ kubectl create namespace psp
```

## Admission Controllers

1. Pour voir les admission controller actives par défaut :

```
kubectl exec -it -n kube-system kube-apiserver-master-1 -- kube-apiserver -h | grep enable-admission-plugins

--admission-control strings              Admission is divided into two phases. In the first phase, only mutating admission plugins run. In the second phase, only validating admission plugins run. The names in the below list may represent a validating plugin, a mutating plugin, or both. The order of plugins in which they are passed to this flag does not matter. Comma-delimited list of: AlwaysAdmit, AlwaysDeny, AlwaysPullImages, CertificateApproval, CertificateSigning, CertificateSubjectRestriction, DefaultIngressClass, DefaultStorageClass, DefaultTolerationSeconds, DenyEscalatingExec, DenyExecOnPrivileged, EventRateLimit, ExtendedResourceToleration, ImagePolicyWebhook, LimitPodHardAntiAffinityTopology, LimitRanger, MutatingAdmissionWebhook, NamespaceAutoProvision, NamespaceExists, NamespaceLifecycle, NodeRestriction, OwnerReferencesPermissionEnforcement, PersistentVolumeClaimResize, PersistentVolumeLabel, PodNodeSelector, PodPreset, PodSecurityPolicy, PodTolerationRestriction, Priority, ResourceQuota, RuntimeClass, SecurityContextDeny, ServiceAccount, StorageObjectInUseProtection, TaintNodesByCondition, ValidatingAdmissionWebhook. (DEPRECATED: Use --enable-admission-plugins or --disable-admission-plugins instead. Will be removed in a future version.)
--enable-admission-plugins strings       admission plugins that should be enabled in addition to default enabled ones (NamespaceLifecycle, LimitRanger, ServiceAccount, TaintNodesByCondition, Priority, DefaultTolerationSeconds, DefaultStorageClass, StorageObjectInUseProtection, PersistentVolumeClaimResize, RuntimeClass, CertificateApproval, CertificateSigning, CertificateSubjectRestriction, DefaultIngressClass, MutatingAdmissionWebhook, ValidatingAdmissionWebhook, ResourceQuota). Comma-delimited list of admission plugins: AlwaysAdmit, AlwaysDeny, AlwaysPullImages, CertificateApproval, CertificateSigning, CertificateSubjectRestriction, DefaultIngressClass, DefaultStorageClass, DefaultTolerationSeconds, DenyEscalatingExec, DenyExecOnPrivileged, EventRateLimit, ExtendedResourceToleration, ImagePolicyWebhook, LimitPodHardAntiAffinityTopology, LimitRanger, MutatingAdmissionWebhook, NamespaceAutoProvision, NamespaceExists, NamespaceLifecycle, NodeRestriction, OwnerReferencesPermissionEnforcement, PersistentVolumeClaimResize, PersistentVolumeLabel, PodNodeSelector, PodPreset, PodSecurityPolicy, PodTolerationRestriction, Priority, ResourceQuota, RuntimeClass, SecurityContextDeny, ServiceAccount, StorageObjectInUseProtection, TaintNodesByCondition, ValidatingAdmissionWebhook. The order of plugins in this flag does not matter.
```

2. Ouvrir le fichier /etc/kubernetes/manifests/kube-apiserver.yaml et noter le passage suivant :

```yaml
containers:
- command:
  - kube-apiserver
  - --advertise-address=10.156.0.3
  - --allow-privileged=true
  - --authorization-mode=Node,RBAC
  - --client-ca-file=/etc/kubernetes/pki/ca.crt
  - --enable-admission-plugins=NodeRestriction
  - --enable-bootstrap-token-auth=true
  - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
```

Notamment la ligne "- --enable-admission-plugins=NodeRestriction". Cette instruction permet d'activer des admissions controllers.

3. Nous allons activer l'admission controller "PodSecurityPolicy", en changeant cette ligne de la façon suivante :

```yaml
- --enable-admission-plugins=NodeRestriction,PodSecurityPolicy
```

La Kubelet se charge de redémarrer le pod kube-apiserver.

## Pod Security Policy

1. Nous allons commencer

```bash
training@master$ kubectl create namespace psp-example
training@master$ kubectl create serviceaccount -n psp-example fake-user
training@master$ kubectl create rolebinding -n psp-example fake-editor --clusterrole=edit --serviceaccount=psp-example:fake-user
```

2. Définissons la pod security policy suivante, imposant aux conteneurs des pods a être exécutés en tant que non root :

```bash
training@master$ touch non-root-pods.yaml
```

Avec le fichier yaml suivant :

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: non-root-pods
spec:
  runAsUser:
    rule: 'MustRunAsNonRoot'
```

3. Nous allons donc créer cet psp :

```bash
kubectl apply -f non-root-pods.yaml
```

4. Définissons maintenant un pod s'exécutant en tant que root :

```bash
touch postgres-as-root.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-as-root
  namespace: psp
spec:
  containers:
    - name:  postgres-as-root
      image: postgres
```

5. Essayons d'exécuter ce pod :

```bash
kubectl apply -f postgres-as-root.yaml
```

6. Nous allons maintenant essayer avec un pod en tant que user :

```bash
postgres-as-user.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-as-user
  namespace: psp
spec:
  containers:
    - name:  postgres-as-user
      image: postgres
      securityContext:
        runAsUser: 999
        runAsGroup: 999
```

7. Essayons de créer ce pod :

```bash
kubectl apply -f postgres-as-user.yaml
```

## Clean Up

Supprimons les ressources générées par cet exercice :

```bash
kubectl delete -f .
```
