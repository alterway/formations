# RBAC

Machine : **master**

```bash
training@master$ mkdir rbac
training@master$ cd rbac
training@master$ kubectl create namespace rbac
```

## Service Accounts

1. Nous allons créer 3 services accounts :

```bash
training@master$ touch example-serviceaccount.yaml
```

Avec respectivement les contenus yaml suivants :

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: example-serviceaccount
  namespace: rbac
```

2. Créeons ce services account :

```bash
training@master$ kubectl apply -f example-serviceaccount.yaml

serviceaccount/example-serviceaccount created
```

3. Nous pouvons voir les services accounts avec la commande suivante :

```bash
training@master$ kubectl get serviceaccounts -n rbac

NAME                          SECRETS   AGE
example-serviceaccount        1         6s
default                       1         2m5s
```

4. Nous pouvons faire un describe sur le service account pour voir plusieurs informations à son sujet :

```bash
kubectl describe serviceaccounts -n rbac

Name:                default
Namespace:           rbac
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   default-token-4mpqg
Tokens:              default-token-4mpqg
Events:              <none>
```

> Note : Le token utilisé par le service account est stocké dans un secret, que l'on peut voir ci-dessus

## User

0. Créer un utilisateur unix mario :

```bash
training@master$ useradd mario -m -s /bin/bash
training@master$ cd /home/mario
```

1. Commençons par générer une clé privée pour notre utilisateur :

```bash
training@master$ sudo openssl genrsa -out mario.key 2048

Generating RSA private key, 2048 bit long modulus (2 primes)
.....................................................................+++++
.................+++++
e is 65537 (0x010001)
```

2. Nous devons également générer un CSR pour notre utilisateur :

```bash
training@master$ sudo openssl req -new -key mario.key -out mario.csr -subj "/CN=mario"
```

3. Enfin, nous devons signer le csr avec la CA de Kubernetes :

```bash
training@master$ sudo openssl x509 -req \
-in mario.csr \
-CA /etc/kubernetes/pki/ca.crt \
-CAkey /etc/kubernetes/pki/ca.key \
-CAcreateserial \
-out mario.crt -days 500
```

4. Nous allons maitenant creer un kubeconfig pour notre utilisateur :

```bash
training@master$ sudo cp /home/training/.kube/config /home/mario/.kube/config
training@master$ sudo kubectl config set-credentials mario --client-certificate=/home/mario/mario.crt --client-key=/home/mario/mario.key --kubeconfig .kube/config

ser "mario" set.

training@master$ sudo kubectl config set-context mario@kubernetes --cluster=kubernetes --user=mario --kubeconfig .kube/config

Context "mario@kubernetes" created.

training@master$ sudo kubectl config use-context mario@kubernetes --kubeconfig .kube/config

Switched to context "mario@kubernetes".

training@master$ sudo kubectl config delete-context kubernetes-admin@kubernetes --kubeconfig .kube/config

deleted context kubernetes-admin@kubernetes from .kube/config
```

5. Un petit chown pour terminer :

```bash
training@master$ sudo chown -R mario:mario /home/mario
```

6. Testons notre kubeconfig :

```bash
training@master$ sudo su - mario

mario@master$ kubectl get pods

Error from server (Forbidden): pods is forbidden: User "mario" cannot list resource "pods" in API group "" in the namespace "default"

mario@master$ exit
```

## Roles/RoleBinding

1. Commençons par créer un role pod-reader permettant de lire les pods sur le namespace rbac. Nous allons donc créer un fichier pod-reader.yaml

```bash
training@master$ touch pod-reader.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: rbac
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

2. Nous allons maintenant créer un role similaire, mais contenant cette fois ci des droits de création et de mise à jour, en plus des droits de lecture :

```bash
training@master$ touch pod-creator.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-creator
  namespace: rbac
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list", "create", "update", "patch"]
```

3. Créeons donc ces roles :

```bash
training@master$ kubectl apply -f pod-reader.yaml -f pod-creator.yaml

role.rbac.authorization.k8s.io/pod-reader created
role.rbac.authorization.k8s.io/pod-creator created
```

4. Nous pouvons consulter ces roles de la façon suivante :

```bash
training@master$ kubectl describe roles -n rbac pod-reader

Name:         pod-reader
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list]

training@master$ kubectl describe roles -n rbac pod-creator

Name:         pod-creator
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list create update patch]
```

5. Nous allons maintenant associer ces roles aux utilisateurs reader et creator. Nous allons donc créer des rolesbindings :  

```bash
training@master$ touch read-pods.yaml
training@master$ touch create-pods.yaml
```

Avec respectivement les contenus yaml suivants :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: rbac
subjects:
- kind: User
  name: reader
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: create-pods
  namespace: rbac
subjects:
- kind: User
  name: creator
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-creator
  apiGroup: rbac.authorization.k8s.io
```

6. Créeons donc ces rolesbindings :

```bash
training@master$ kubectl apply -f read-pods.yaml -f create-pods.yaml

rolebinding.rbac.authorization.k8s.io/read-pods created
rolebinding.rbac.authorization.k8s.io/create-pods created
```

7. Nous pouvons consulter ces rolebindings de la façon suivante :

```bash
training@master$ kubectl describe rolebindings -n rbac create-pods


Name:         create-pods
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  pod-creator
Subjects:
  Kind  Name     Namespace
  ----  ----     ---------
  User  creator

training@master$ kubectl describe rolebindings -n rbac read-pods

Name:         read-pods
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  pod-reader
Subjects:
  Kind  Name    Namespace
  ----  ----    ---------
  User  reader
```

8. Nous allons maintenant tenter de créer un pod en tant qu'utilisateur reader :

```bash
training@master$ kubectl run --image nginx test-rbac -n rbac --as reader

Error from server (Forbidden): pods is forbidden: User "reader" cannot create resource "pods" in API group "" in the namespace "rbac"
```

9. Essayons maintenant en tant que creator :

```bash
training@master$ kubectl run --image nginx test-rbac -n rbac --as creator

pod/nginx created
```

10. Maintenant, nous allons essayer de récupérer des informations sur ces pods en tant que unauthorized :

```bash
training@master$ kubectl get pods test-rbac -n rbac --as unauthorized

Error from server (Forbidden): pods "test-rbac" is forbidden: User "unauthorized" cannot get resource "pods" in API group "" in the namespace "rbac"
```

11. Essayons maintenant en tant que reader :

```bash
training@master$ kubectl get pods test-rbac -n rbac --as reader

NAME        READY   STATUS    RESTARTS   AGE
test-rbac   1/1     Running   0          58s
```

## ClusterRoles/ClusteRoleBinding

1. Commençons par créer un secret dans le namespace **default** :

```bash
training@master$ touch secret-rbac.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-rbac
  namespace : default
type: Opaque
stringData:
  iam: asecret
```

2. Nous allons créer un clusterrole permettant de lire les secrets, quelque soit le namespace dans lequel ils se trouvent :

```bash
training@master$ touch secret-reader.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- resources: ["secrets"]
  verbs: ["get", "watch", "list"]
  apiGroups: [""]
```

3. Nous allons également créer un clusterrole permettant de récupérer des informations sur les noeuds du cluster :

```bash
training@master$ touch node-reader.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- resources: ["nodes"]
  verbs: ["get", "watch", "list"]
  apiGroups: [""]
```

4. Créeons maintenant ces clusterroles :

```bash
training@master$ kubectl apply -f secret-reader.yaml -f node-reader.yaml -f secret-rbac.yaml

clusterrole.rbac.authorization.k8s.io/secret-reader created
clusterrole.rbac.authorization.k8s.io/node-reader created
secret/secret-rbac created
```

5. Nous allons maintenant lier ces clusterroles à l'utilisateur reader. Nous allons donc créer des clusterrole binding :

```bash
training@master$ touch read-secrets-global.yaml
training@master$ touch read-nodes-global.yaml
```

Avec respcetivement les contenus yaml suivants :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: User
  name: reader
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-nodes-global
subjects:
- kind: User
  name: reader
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

6. Créeons donc ces clusterrole bindings :

```bash
training@master$ kubectl apply -f read-secrets-global.yaml -f read-nodes-global.yaml

clusterrolebinding.rbac.authorization.k8s.io/read-secrets-global created
clusterrolebinding.rbac.authorization.k8s.io/read-nodes-global created
```

7. Essayons maintenant de lire le secret se trouvant dans le namespace default en tant que unauthorized :

```bash
training@master$ kubectl get secrets secret-rbac --as unauthorized

Error from server (Forbidden): secrets "secret-rbac" is forbidden: User "unauthorized" cannot get resource "secrets" in API group "" in the namespace "default"
```

8. Essayons maintenant en tant que reader :

```bash
training@master$ kubectl get secrets secret-rbac -n default --as reader

NAME          TYPE     DATA   AGE
secret-rbac   Opaque   1      10m
```

9. De même, essayons de lister les noeuds en tant que unauthorized :

```bash
training@master$ kubectl get nodes --as unauthorized

Error from server (Forbidden): nodes is forbidden: User "unauthorized" cannot list resource "nodes" in API group "" at the cluster scope
```

10. Essayons maintenant en tant que reader :

```bash
training@master$ kubectl get nodes --as reader

NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   25h   v1.19.3
worker   Ready    <none>   25h   v1.19.3
```

## CleanUp

```bash
training@master$ kubectl delete -f .

rolebinding.rbac.authorization.k8s.io "create-pods" deleted
serviceaccount "example-serviceaccount" deleted
clusterrole.rbac.authorization.k8s.io "node-reader" deleted
role.rbac.authorization.k8s.io "pod-creator" deleted
role.rbac.authorization.k8s.io "pod-reader" deleted
clusterrolebinding.rbac.authorization.k8s.io "read-nodes-global" deleted
rolebinding.rbac.authorization.k8s.io "read-pods" deleted
clusterrolebinding.rbac.authorization.k8s.io "read-secrets-global" deleted
secret "secret-rbac" deleted
clusterrole.rbac.authorization.k8s.io "secret-reader" deleted
```
