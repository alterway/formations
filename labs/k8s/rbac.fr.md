# RBAC

<hr>

Machine : **master**

<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir rbac
cd rbac
kubectl create namespace rbac
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

## Service Accounts

1. Nous allons créer 1 service accounts :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch example-serviceaccount.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec respectivement les contenus yaml suivants :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: example-serviceaccount
  namespace: rbac
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Créons ce service account :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f example-serviceaccount.yaml

serviceaccount/example-serviceaccount created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Nous pouvons voir les services accounts avec la commande suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get serviceaccounts -n rbac

NAME                          SECRETS   AGE
example-serviceaccount        1         6s
default                       1         2m5s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Nous pouvons faire un describe sur le service account pour voir plusieurs informations à son sujet :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe serviceaccounts -n rbac

Name:                default
Namespace:           rbac
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   default-token-4mpqg
Tokens:              default-token-4mpqg
Events:              <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

> Note : Le token utilisé par le service account est stocké dans un secret, que l'on peut voir ci-dessus

## User

0. Créer un utilisateur unix avec votre tri-gramme

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
TRIG="hel" # Remplacer avec votre trigramme par exemple
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo useradd ${TRIG} -m -s /bin/bash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Commençons par générer une clé privée un CSR pour notre utilisateur :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo openssl req -new -newkey rsa:4096 -nodes -keyout ${TRIG}-kubernetes.key -out ${TRIG}-kubernetes.csr -subj "/CN=${TRIG}/O=devops"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Encodons en base64 le CSR généré

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
base64 ${TRIG}-kubernetes.csr | tr -d '\n' > ${TRIG}.csr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Mettons le csr encodé dans une variable

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
REQUEST=$(cat ${TRIG}.csr)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Faisons une request de signature pour le csr généré au niveau du cluster

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
cat << EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${TRIG}-kubernetes-csr
spec:
  groups:
  - system:authenticated
  request: $REQUEST
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Vérifions que la request est passée

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get csr
# Pending
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


6. Approuvons le certificat

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl certificate approve ${TRIG}-kubernetes-csr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

7. Vérifions que la request est signée

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get csr
# Approved,Issued
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


8. Génération du certificat utilisateur

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get csr ${TRIG}-kubernetes-csr -o jsonpath='{.status.certificate}' | base64 --decode > ${TRIG}-kubernetes-csr.crt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

9. Génération de la CA du cluster k8s

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > kubernetes-ca.crt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


10. Création du kubeconfig
 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=kubernetes-ca.crt --kubeconfig=${TRIG}-kubernetes-config --embed-certs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

11. Mise à jour du context

⚠️ <font color=red>Veuillez vérifier le propriétaire des fichiers  ${TRIG}-kubernetes-csr.crt et ${TRIG}-kubernetes.key </font>

Changer le propriétaire avec votre compte unix si ils sont en **root** ex: `sudo chown ubuntu: et ${TRIG}-kubernetes.key`


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl config set-credentials ${TRIG} --client-certificate=${TRIG}-kubernetes-csr.crt --client-key=${TRIG}-kubernetes.key --embed-certs --kubeconfig=${TRIG}-kubernetes-config

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



12. Optionnellement positionnement sur un namespace

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}

kubectl config set-context ${TRIG} --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}') --namespace=rbac --user=${TRIG} --kubeconfig=${TRIG}-kubernetes-config

KUBECONFIG=hel-kubernetes-config kubectx hel

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

13. Déplacements

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}


sudo mkdir -p /home/${TRIG}/.kube
sudo cp ${TRIG}-kubernetes-config /home/${TRIG}/.kube/config
sudo chown -R ${TRIG}:${TRIG} /home/${TRIG}/.kube
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Testons notre kubeconfig :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo su - ${TRIG}

kubectl get pods

Error from server (Forbidden): pods is forbidden: User "${TRIG}" cannot list resource "pods" in API group "" in the namespace "default"


#!!!  A faire pour repasser sur ubuntu ou utiliser un autre onglet
exit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Roles/RoleBinding

1. Commençons par créer un rôle pod-reader permettant de lire les pods sur le namespace rbac. Nous allons donc créer un fichier pod-reader.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-reader.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: rbac
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Nous allons maintenant créer un rôle similaire, mais contenant cette fois ci des droits de création et de mise à jour, en plus des droits de lecture :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-creator.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-creator
  namespace: rbac
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list", "create", "update", "patch"]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Créons donc ces rôles :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-reader.yaml -f pod-creator.yaml

role.rbac.authorization.k8s.io/pod-reader created
role.rbac.authorization.k8s.io/pod-creator created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Nous pouvons consulter ces rôles de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe roles -n rbac pod-reader

Name:         pod-reader
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list]

kubectl describe roles -n rbac pod-creator

Name:         pod-creator
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list create update patch]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


5. Nous allons associer dans un premier le rôle pod reader au user ${TRIG} précédemment créé
   En ligne de commande

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl create rolebinding hel-pod-reader --role=pod-reader --user=hel -n rbac
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Vérifier qu'il n'y a plus d'erreur 
  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
# ! En tant que ubuntu 
kubectl run --image nginx nginx -n rbac

# En tant que hel
kubectl get po -n rbac

# Essayer de supprimer le pod en tant que hel
kubectl delete po nginx -n rbac  #! erreur
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

7. Refaire l'exercice avec le rôle pod-creator
  
  ...

8. Nous allons maintenant associer ces rôles aux utilisateurs reader et creator. Nous allons donc créer des rolesbindings :  

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch read-pods.yaml
touch create-pods.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec respectivement les contenus yaml suivants :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

9. Créons donc ces rolesbindings :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f read-pods.yaml -f create-pods.yaml

rolebinding.rbac.authorization.k8s.io/read-pods created
rolebinding.rbac.authorization.k8s.io/create-pods created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

10. Nous pouvons consulter ces rolebindings de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe rolebindings -n rbac create-pods


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

kubectl describe rolebindings -n rbac read-pods

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

11. Nous allons maintenant tenter de créer un pod en tant qu'utilisateur reader :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl run --image nginx test-rbac -n rbac --as reader

Error from server (Forbidden): pods is forbidden: User "reader" cannot create resource "pods" in API group "" in the namespace "rbac"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

12. Essayons maintenant en tant que creator :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl run --image nginx test-rbac -n rbac --as creator

pod/nginx created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

13. Maintenant, nous allons essayer de récupérer des informations sur ces pods en tant que unauthorized :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods test-rbac -n rbac --as unauthorized

Error from server (Forbidden): pods "test-rbac" is forbidden: User "unauthorized" cannot get resource "pods" in API group "" in the namespace "rbac"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

14. Essayons maintenant en tant que reader :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods test-rbac -n rbac --as reader

NAME        READY   STATUS    RESTARTS   AGE
test-rbac   1/1     Running   0          58s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## ClusterRoles/ClusteRoleBinding

15. Commençons par créer un secret dans le namespace **default** :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch secret-rbac.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Secret
metadata:
  name: secret-rbac
  namespace : default
type: Opaque
stringData:
  iam: asecret
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

16. Nous allons créer un clusterrole permettant de lire les secrets, quelque soit le namespace dans lequel ils se trouvent :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch secret-reader.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- resources: ["secrets"]
  verbs: ["get", "watch", "list"]
  apiGroups: [""]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

17. Nous allons également créer un clusterrole permettant de récupérer des informations sur les noeuds du cluster :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch node-reader.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- resources: ["nodes"]
  verbs: ["get", "watch", "list"]
  apiGroups: [""]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

18. Créons maintenant ces clusterroles :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f secret-reader.yaml -f node-reader.yaml -f secret-rbac.yaml

clusterrole.rbac.authorization.k8s.io/secret-reader created
clusterrole.rbac.authorization.k8s.io/node-reader created
secret/secret-rbac created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

19. Nous allons maintenant lier ces clusterroles à l'utilisateur reader. Nous allons donc créer des clusterrole binding :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch read-secrets-global.yaml
touch read-nodes-global.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec respectivement les contenus yaml suivants :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

20. Créons donc ces clusterrole bindings :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f read-secrets-global.yaml -f read-nodes-global.yaml

clusterrolebinding.rbac.authorization.k8s.io/read-secrets-global created
clusterrolebinding.rbac.authorization.k8s.io/read-nodes-global created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

21. Essayons maintenant de lire le secret se trouvant dans le namespace default en tant que unauthorized :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get secrets secret-rbac --as unauthorized

Error from server (Forbidden): secrets "secret-rbac" is forbidden: User "unauthorized" cannot get resource "secrets" in API group "" in the namespace "default"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

22. Essayons maintenant en tant que reader :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get secrets secret-rbac -n default --as reader

NAME          TYPE     DATA   AGE
secret-rbac   Opaque   1      10m
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

23. De même, essayons de lister les noeuds en tant que unauthorized :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get nodes --as unauthorized

Error from server (Forbidden): nodes is forbidden: User "unauthorized" cannot list resource "nodes" in API group "" at the cluster scope
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

24. Essayons maintenant en tant que reader :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get nodes --as reader

NAME     STATUS   ROLES    AGE   VERSION
master   Ready    master   25h   v1.19.3
worker   Ready    <none>   25h   v1.19.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## CleanUp

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f .

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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


<hr>

