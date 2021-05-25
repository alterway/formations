# KUBERNETES : Utilisation et Déploiement des Ressources

### Kubernetes : Kubectl

- Le seul (ou presque) outil pour interagir avec des clusters Kubernetes
- Utilise un fichier de configuration (kubeconfig) pour communiquer avec l'API de Kubernetes
- Le(s) fichier(s) se trouve(nt) par défaut dans `~/.kube/config`
- Le fichier de config. contient :
    - L'adresse(URI) de l'APIServer
    - Les chemins des certificats TLS utilisés pour l'authentification

- Fichier `kubeconfig` peut être passé en paramètre de kubectl avec le _flag_ `--kubeconfig`

### Kubeconfig

Un seul fichier pour gérer tous ses clusters avec trois informations :

- Serveurs (IP, CA Cert, Nom)
- Users (Nom, Certificat, Clé)
- Context, association d'un user et d'un serveur

Stocké par défaut dans ~/.kube/config

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


### Kubernetes : Kubectl explain

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

### Kubernetes : Type de nom

- Les noms de ressources les plus courants ont 3 formes:

    - singulier (par exemple, node, service, deployment)
    - pluriel (par exemple, nodes, services, deployments)
    - court (par exemple no, svc, deploy)

- Certaines ressources n'ont pas de nom court

- Les points de terminaison (endpoints) ont uniquement une forme plurielle

### Kubernetes : Kubectl get

- Afficher les noeuds du cluster :

```console
kubectl get nodes
```

- Ces commandes sont équivalentes:

```console
kubectl get no
kubectl get nodes
```

### Kubernetes : Kubectl

- plus d'infos

```console
kubectl get nodes -o wide
```

- Sortie yaml / json 


```console
kubectl get nodes -o yaml
kubectl get nodes -o json
```

### Kubernetes : Kubectl

- Utiliser `jq`
  
```console
kubectl get nodes -o json |
        jq ".items[] | {name:.metadata.name} + .status.capacity"
```

### Kubernetes : Kubectl

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

### Kubernetes : Kubectl

- Afficher les pods (pour le namespace _default_)

```console
kubectl get pods
kubectl get pod
```

### Kubernetes : Kubectl

- Afficher les services (pour le _namespace_ `default`):

```console
kubectl get services
kubectl get svc
```

### Kubernetes : Kubectl describe

- `kubectl describe`a besoin d'un type de ressource et optionnelement un nom de ressource
- Il est possible de fournir un _prefixe_ de nom de ressource

- ex:
  
```console
 kubectl describe node/node1
 kubectl describe node node1
```


### Kubernetes : Création d'objets Kubernetes

- Les objets Kubernetes sont créés sous la forme de fichiers JSON ou YAML et envoyés à l'APIServer
- Possible d'utiliser la commande `kubectl run`, mais limitée aux `Deployments` et aux `Jobs`
- L'utilisation de fichiers YAML permet de les stocker dans un système de contrôle de version comme git, mercurial, etc...
- La documentation de référence pour l'API Kubernetes <https://kubernetes.io/docs/reference/#api-reference>

### Kubernetes : Création d'objets Kubernetes

- Pour créer un object Kubernetes depuis votre fichier YAML, utilisez la commande `kubectl create` :

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

### Kubernetes : Kubernetes Dashboard

- Interface graphique web pour les clusters Kubernetes
- Permet de gérer les différents objets Kubernetes créés dans le(s) cluster(s).
- Installé par défaut dans minikube


### Kubernetes : Kubernetes Dashboard

![](images/kubernetes/ui-dashboard.png)


### Kubernetes : Kubernetes Dashboard

- Interface web pour manager les ressources kubernetes
- Le dashboard requiere une authentification (token ou kubeconfg)
- Plusieurs alternatives open source existent :
   - [k9s](https://github.com/derailed/k9s) 
   - [octant](https://octant.dev/)
   - [skooner](https://github.com/skooner-k8s/skooner)
   - [lens](https://k8slens.dev/)
   - ...
  
  
### Kubernetes : Kubernetes Dashboard

- Pour déployer le Dashboard, exécuter la commande suivante:

```console
$ kubectl apply -f kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

```

- Pour accéder au Dashboard, il faut établir une communication entre votre poste et le cluster Kubernetes :

```console
$ kubectl proxy
```

- L'accès se fait désormais sur :

<http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/>

