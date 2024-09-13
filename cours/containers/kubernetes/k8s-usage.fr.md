# KUBERNETES : Utilisation et Déploiement des Ressources

### Kubernetes : `kubectl`

![kubectl](images/kubectl.svg){height="200px"}

- Le seul (ou presque) outil pour interagir avec des clusters Kubernetes
- Utilise un fichier de configuration (kubeconfig) pour communiquer avec l'API de Kubernetes
- Le(s) fichier(s) se trouve(nt) par défaut dans `~/.kube/config`
- Le fichier de config. contient :
    - L'adresse(URI) de l'APIServer
    - Les chemins des certificats TLS utilisés pour l'authentification

- Fichier `kubeconfig` peut être passé en paramètre de kubectl avec le _flag_ `--kubeconfig`
    . `kubectl --kubeconfig=/opt/k8s/config get po`


- Fichier `kubeconfig` peut être passé en paramètre de kubectl avec la variable d'nvironnement `KUBECONFIG`
    . `KUBECONFIG=/opt/k8s/config kubectl get pods`

### Kubeconfig 1/4

Un seul fichier pour gérer tous les clusters avec trois informations :

- Serveurs (IP, CA Cert, Nom)
- Users (Nom, Certificat, Clé)
- Context, association d'un user et d'un serveur


### Kubeconfig 2/4

![Synthèse architecture](images/kubeconfig-structure.png){height="400px"}

### Kubeconfig 3/4


```yaml

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FU..
    server: https://akshlprod001-e419e3f0.hcp.northeurope.azmk8s.io:443
  name: aks-hl-prod-001
contexts:
- context:
    cluster: aks-hl-prod-001
    namespace: velero
    user: clusterUser_rg-hl-prod-001_aks-hl-prod-001
  name: aks-hl-prod-001
current-context: aks-hl-prod-001
kind: Config
preferences: {}
users:
- name: clusterUser_rg-hl-prod-001_aks-hl-prod-001
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t..
    client-key-data: LS0tLS1CRUdJTiBSU0Eg..
    token: 0ad033b165e2f7a4f705ca6defef8555ff501345e2324cf337b68820d85dc65bae39c47bb58ad913b0385a0d7eb5df6e872dbd1fe62fd34ca6e4ed58b2e8a733

```

### Kubeconfig 3/4

Lorsque vous accédez à plusieurs clusters Kubernetes, vous aurez de nombreux fichiers kubeconfig.

Par défaut, kubectl recherche uniquement un fichier nommé config dans le répertoire $HOME/.kube. 

Alors, comment pouvons-nous fusionner plusieurs fichiers kubeconfig en un seul ?


- 1. Faire une copie de votre fichier kubeconfig (au cas ou ...)

```bash
cp ~/.kube/config ~/.kube/config-backup 
```

- 2. Définir la variable d'environnement KUBECONFIG

La variable d'environnement KUBECONFIG est une liste de chemins vers des fichiers de configuration, par exemple :

```bash
export KUBECONFIG=~/.kube/config:/path/cluster1/config:/path/cluster2/config:/path/cluster3/config
```

-  3. Fusionner tous les fichiers kubeconfig en un seul
  
```bash
kubectl config view --flatten > all-in-one-kubeconfig.yaml
```

- 4. Remplacer l'ancien fichier de configuration par le nouveau fusionné

```bash
mv all-in-one-kubeconfig.yaml ~/.kube/config
```

- 5. Tester !

```bash
kubectl config get-contexts
```


### Kubernetes : Kubectl

![kubectl](images/kubernetes/kubectl2.png){height="500px"}



### Kubernetes : Kubectl

- Afficher la liste des ressources API supportées par le serveur:

```console
$ kubectl api-resources
NAME                              SHORTNAMES   APIGROUP                             NAMESPACED   KIND
configmaps                        cm                                                true         ConfigMap
limitranges                       limits                                            true         LimitRange
namespaces                        ns                                                false        Namespace
nodes                             no                                                false        Node
persistentvolumeclaims            pvc                                               true         PersistentVolumeClaim
persistentvolumes                 pv                                                false        PersistentVolume
pods                              po                                                true         Pod
secrets                                                                             true         Secret
services                          svc                                               true         Service
daemonsets                        ds           apps                                 true         DaemonSet
deployments                       deploy       apps                                 true         Deployment
replicasets                       rs           apps                                 true         ReplicaSet
statefulsets                      sts          apps                                 true         StatefulSet
horizontalpodautoscalers          hpa          autoscaling                          true         HorizontalPodAutoscaler
cronjobs                          cj           batch                                true         CronJob
jobs                                           batch                                true         Job
ingresses                         ing          extensions                           true         Ingress
```

- Pourquoi utiliser kubectl api-resources ?
    - Découverte: Pour connaître les ressources disponibles dans votre cluster.
    - Documentation: Pour obtenir des informations sur les différentes ressources et leurs propriétés.
    - Développement: Pour créer des scripts et des outils d'automatisation.
    - Dépannage: Pour identifier les problèmes liés à des ressources spécifiques.



### Kubernetes : `kubectl explain`

- Le "man pages" de kubernetes
- Explorer les types et définitions

```console
kubectl explain type
```

- Expliquer la définition d'un champs de ressource, ex:

```console
kubectl explain node.spec
```

- Boucler sur les définitions
  
```console
kubectl explain node --recursive
```

### Kubernetes : `Kind`

- Les noms de ressources les plus courants ont 3 formes:

    - singulier (par exemple, node, service, deployment)
    - pluriel (par exemple, nodes, services, deployments)
    - court (par exemple no, svc, deploy)

- Certaines ressources n'ont pas de nom court (clusterroles, clusterrolebindings, roles ...)

- Les points de terminaison (endpoints) ont uniquement une forme plurielle ou courte (ep)

### Kubernetes : `kubectl get`

- Afficher les noeuds du cluster :

```console
kubectl get nodes
```

- Ces commandes sont équivalentes:

```console
kubectl get no
kubectl get nodes
```

### Kubernetes : `kubectl get` 

- plus d'infos

```console
kubectl get nodes -o wide
```

- Sortie yaml / json 


```console
kubectl get nodes -o yaml
kubectl get nodes -o json
```


- Utiliser JSONPath

    - Plus d'infos : https://kubernetes.io/docs/reference/kubectl/jsonpath/

```console 

kubectl get pods -o=jsonpath='{@}'
kubectl get pods -o=jsonpath='{.items[0]}'

kubectl get pods  \
  --output=jsonpath='{.items[0].metadata.name}'

```


### Kubernetes : `kubectl get`

- Utiliser `jq`
  
```console
kubectl get nodes -o json |
        jq ".items[] | {name:.metadata.name} + .status.capacity"
```



⚠ : Il faut utiliser `jq` quand on a besoin de `regexp` car JSONPath ne les supporte pas.

ex: 

```console

# KO :
kubectl get pods -o jsonpath='{.items[?(@.metadata.name=~/^test$/)].metadata.name}'

# OK :
kubectl get pods -o json | jq -r '.items[] | select(.metadata.name | test("test-")).spec.containers[].image'

```

### Kubernetes : `kubectl get`

- Afficher les _namespaces_

```console
kubectl get ns
kubectl get namespaces
```

- Par défaut, kubectl utilise le _namespace_ `default`
- Il est possible de sélectionner un _namespace_ avec l'option `-n` ou `--namespace`

```console
kubectl -n kube-system get pods
```

### Kubernetes : `kubectl get`

- Afficher les pods (pour le namespace _default_)

```console
kubectl get pods
kubectl get pod
```

### Kubernetes : `kubectl get`

- Afficher les services (pour le _namespace_ `default`):

```console
kubectl get services
kubectl get svc
```

### Kubernetes : `kubectl get`

- Afficher les ressources d'un `namespace` particulier
- Utilisable avec la plupart des commandes `kubectl`

```console
kubectl get pods --namespace=kube-system
kubectl get pods -n kube-system
kubectl create -n NNN ...
kubectl run -n NNN ...
kubectl delete -n NNN ...
# ...
```
### Kubernetes : `kubectl get`

- Pour lister des ressources dans tous les namespaces : `--all-namespaces`
- Depuis kubernetes 1.14 on peut utiliser le flag `-A` en raccourci
- Il est possible de l'utiliser avec beaucoup de commande kubectl pour manipuler toutes les ressources 

```console
kubectl get pods --all-namespaces
# ou
kubectl get pods -A
# autres actions
kubectl delete -A ...
kubectl label -A ...
```


### Kubectl : Se déplacer dans un Namespace de manière permanente (comme un `cd`)

Évite de toujours préciser le flag `-n`

```console

kubectl get ns

kubectl config set-context --current --namespace <nom-du-namespace>

# ou

alias kubens='kubectl config set-context --current --namespace '

# ex: kubens kube-system 

```




### Kubernetes : namespace `kube-public` 

`kube-public` est créé par `kubeadm` 


```console
kubectl get all -n kube-public
```

- Le configMap contient les informations données par la commande
  `kubectl cluster-info`

```console
kubectl -n kube-public get configmaps
# voir le contenu du configmap (cm)
kubectl -n kube-public get configmap cluster-info -o yaml
# Ce configmap est lisible par tout le monde sans authentification
curl -k https://{NodeIP}/api/v1/namespaces/kube-public/configmaps/cluster-info

# Contient le kubeconfig
```

- Ce configmap contient l'url de l'API du serveur, et la clé publique de l'AC

- Ce fichier ne contient pas de clés client ni de tokens

- Il ne s'agit pas d'informations sensibles
  


### Kubernetes : kubeconfig

- Extraire le kubeconfig du configmap `cluster-info`

```console
curl -sk https://<IP PRIV>/api/v1/namespaces/kube-public/configmaps/cluster-info \
     | jq -r .data.kubeconfig
```


### Kubernetes : namespace `kube-node-lease` 

Qu'est-ce qu'un Lease dans Kubernetes ?
Un Lease est un objet qui expire après un certain temps s'il n'est pas renouvelé. Dans le contexte de kube-node-lease, chaque nœud du cluster a un Lease associé. La kubelet (l'agent Kubernetes s'exécutant sur chaque nœud) envoie régulièrement des mises à jour à ce Lease pour indiquer qu'il est toujours en fonctionnement.

- Ce namespace particulier existe depuis la 1.14
- Il contient un objet `lease`par noeud
- Ces `leases` permettent d'implémenter une nouvelle méthode pour vérifier l'état de santé des noeuds
- Voir (KEP-0009)[https://github.com/kubernetes/enhancements/blob/master/keps/sig-node/0009-node-heartbeat.md] pour plus d'information


### Kubernetes : `kubectl describe`

- `kubectl describe` a besoin d'un type de ressource et optionnellement un nom de ressource
- Il est possible de fournir un _préfixe_ de nom de ressource

- ex:
  
```console
 kubectl describe node/worker-0
 kubectl describe node worker-0
```

- Pourquoi utiliser kubectl describe ? :

    - Dépannage: Pour comprendre pourquoi un objet ne fonctionne pas comme prévu.
    - Audit: Pour vérifier la configuration d'un objet et s'assurer qu'elle correspond à vos attentes.
    - Apprentissage: Pour mieux comprendre la structure et le fonctionnement des différents objets Kubernetes.


### Kubernetes : Création d'objets Kubernetes

- Les objets Kubernetes sont créés sous la forme de fichiers JSON ou YAML et envoyés à l'APIServer

- Possible d'utiliser la commande `kubectl run`, mais limitée aux `deployments` et aux `jobs`

- L'utilisation de fichiers YAML permet de les stocker dans un système de contrôle de version comme git, mercurial, etc...

- La documentation de référence pour l'API Kubernetes <https://kubernetes.io/docs/reference/#api-reference>


### Kubernetes : Créer un pod en ligne de commande

- Cette commande avant la 1.18 créait un `deployment`
- Depuis elle démarre un simple `pod`

```console
# Création d'un pod en tâche de fond
kubectl run pingu --image=alpine -- ping 127.1
```

```console
# Création d'un pod en intératif
kubectl run -i --tty my-pod --image=debian -- /bin/bash
```

⚠ : Notez le `--`entre le nom de l'image et la commande à lancer

### Kubernetes : Créer un déploiement (par exemple) en ligne de commande 

- `kubectl create deployment` ...
- Depuis kubernetes 1.19, il est possible de préciser une commande au moment du `create`

```console
kubectl create deployment pingu --image=alpine -- ping 127.1
```

⚠ : Notez le `--`entre le nom de l'image et la commande à lancer



### Kubernetes : Création d'objets Kubernetes

- Pour créer un object Kubernetes depuis votre fichier `YAML`, utilisez la commande `kubectl create` :

```console
kubectl create -f object.yaml
```

- Il est possible de créer des objets Kubernetes à partir d'une URL :

```console
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/guestbook/frontend-deployment.yaml
```

### Kubernetes : Création d'objets Kubernetes

- Pour les supprimer exécuter simplement :

```console
kubectl delete -f object.yaml
```

- Mettre à jour un objet Kubernetes en écrasant la configuration existante:

```console
kubectl replace -f object.yaml
kubectl apply -f object.yaml
```


⚠ : Il est possible d'utiliser `apply` pour créer des resources.  

### Kubernetes : Kubernetes Dashboard

- Interface graphique web pour les clusters Kubernetes
- Permet de gérer les différents objets Kubernetes créés dans le(s) cluster(s).
- Installé par défaut dans minikube


### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/dashboard-0.png){height="500px"}


### Kubernetes : Kubernetes Dashboard

- Interface web pour manager les ressources kubernetes
- Le dashboard requière une authentification (token ou kubeconfg)
- Plusieurs alternatives open source existent :
   - [k9s](https://github.com/derailed/k9s) 
   - [octant](https://octant.dev/)
   - [skooner](https://github.com/skooner-k8s/skooner)
   - [lens](https://k8slens.dev/)
   - ...
  
  
### Kubernetes : Kubernetes Dashboard

Étape 1: Déployer le Dashboard

```console
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

```

Étape 2: Créer un compte de service et un rôle d'administration

1. Créer un fichier YAML pour le compte de service:

```yaml
# dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

2. Appliquer le fichier YAML pour créer le compte de service:

```console
kubectl apply -f dashboard-adminuser.yaml
````

### Kubernetes : Kubernetes Dashboard

3. Créer un fichier YAML pour le rôle d'administration:

```yaml
# admin-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```


4. Appliquer le fichier YAML pour créer le rôle d'administration:

```console

kubectl apply -f admin-role-binding.yaml

```

### Kubernetes : Kubernetes Dashboard

Étape 3: Récupérer le token d'accès

```console
kubectl -n kubernetes-dashboard create token admin-user
```

Étape 4: Accéder au Dashboard

Démarrer un proxy pour accéder au Dashboard:

```console
kubectl proxy
```

- Cela démarre un proxy à l'adresse <http://localhost:8001>
- Ouvrir le Dashboard dans votre navigateur:
    - Accédez à l'URL suivante dans votre navigateur:
<http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>

- Se connecter avec le token:
    - Lorsque vous êtes invité à vous connecter, choisissez l'option "Token" et entrez le token que vous avez récupéré à l'Étape 3.

![](images/kubernetes/dashboard.png){height="200px"}




### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/dashboard-node.png){height="700px"}



### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/dashboard-node.png){height="700px"}


### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/dashboard-ns.png){height="700px"}


### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/dashboard-pod.png){height="700px"}



