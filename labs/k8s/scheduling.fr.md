
# Scheduling

<hr>
Machine : master
<hr>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir scheduling
cd scheduling
kubectl create namespace scheduling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Taints and Tolerations

1. Nous allons commencer par mettre un **taint** sur les noeuds node1 et node2:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl taint nodes node1 dedicated=experimental:NoSchedule
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*node/node1 tainted*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl taint nodes node2 dedicated=experimental:NoSchedule
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*node/node2 tainted*


2. Nous pouvons faire un describe sur le noeud pour voir que notre taint a bien été prise en compte :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe node node1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

CreationTimestamp:  Sun, 01 Nov 2020 09:49:52 +0000
Taints:             dedicated=experimental:NoSchedule
Unschedulable:      false
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Essayons de déployer un pod sans toleration :

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-without-toleration.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-without-toleration
  namespace: scheduling
spec:
  containers:
  - name: nginx
    image: nginx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Créons donc ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-without-toleration.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/pod-without-toleration created*

5. Voyons voir sur quel noeud notre pod a été schedulé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -n scheduling pod-without-toleration -o wide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME                     READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
pod-without-toleration   0/1     Pending   0          11m   <none>   <none>   <none>           <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Notre pod n’ayant pas de toleration pour la taint que nous avons mis sur les noeuds node1 et node2, il n'a pu être déployé.

6. Définissons maintenant un pod avec un toleration avec la taint définie plus haut :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-toleration.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-toleration
  namespace: scheduling
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "dedicated"
    value: "experimental"
    operator: "Equal"
    effect: "NoSchedule"

  
7. Créons ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-toleration.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


*pod/pod-toleration created*


8. Nous pouvons voir sur quel noeud notre pod a été schedulé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -n scheduling pod-toleration -o wide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME             READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-toleration   1/1     Running   0          49s   10.44.0.1   node1   <none>           <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Le pod peut maintenant être schedulé sur le noeud node1

9. Supprimons les objets créés dans cet exercice :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f pod-toleration.yaml -f pod-without-toleration.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod "pod-toleration" deleted*

*pod "pod-without-toleration" deleted*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl taint nodes node1 dedicated:NoSchedule-
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*node/node1 untainted*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl taint nodes node2 dedicated:NoSchedule-
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*node/node2 untainted*

<hr>

**NodeSelector**


1. Nous allons enlever la taint sur le master pour pouvoir scheduler des pods dessus :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl taint nodes master node-role.kubernetes.io/master:NoSchedule-
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*node/master untainted*


2. Nous allons commencer par mettre un label sur le noeud node2 “disk=ssd” :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl label nodes node2 disk=ssd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*node/node2 labeled*


3. Nous pouvons faire un describe sur le noeud node2 pour voir que notre label a bien été pris en compte :
  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe nodes node2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
Name:               node2
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    disk=ssd
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=worker
                    kubernetes.io/os=linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Définissons un pod que l’on va scheduler sur le noeud node2 à l’aide du label défini ci-dessus :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-nodeselector.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodeselector
  namespace: scheduling
spec:
  containers:
  - name: nginx
    image: nginx
  nodeSelector:
    disk: ssd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Créons donc ce pod :
   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-nodeselector.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/pod-nodeselector created*

6. Voyons voir dans quel noeud notre pod a été mis :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -n scheduling pod-nodeselector -o wide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME               READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-nodeselector   1/1     Running   0          17s   10.44.0.1   node2   <none>           <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Sans surprise, sur le noeud node2.*

7. Supprimons le pod créé dans cet exercice :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f pod-nodeselector.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod "pod-nodeselector" deleted*

<hr> 

## Node Affinity/AntiAffinity

<hr>

1. Définissons un pod, avec une nodeAffinity lui imposant d’aller dans un noeud ayant comme label “disk=ssd”, autrement dit le noeud node2 :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-nodeaffinity.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodeaffinity
  namespace: scheduling
  labels:
    pod: alone
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values:
            - ssd
  containers:
  - name: pod-nodeaffinity
    image: nginx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Créons donc ce pod :
  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-nodeaffinity.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/pod-nodeaffinity created*


3. Voyons voir dans quel noeud ce pod a été mis :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
kubectl get pods -n scheduling pod-nodeaffinity -o wide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME               READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-nodeaffinity   1/1     Running   0          36s   10.44.0.1        node2   <none>           <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Sans surprise, dans le noeud node2.*

<hr>

## Pod Affinity/AntiAffinity

<hr>

1. Définissons un pod, avec une podAntiAffinity lui imposant d’aller dans un noeud ne comportant pas le pod pod-nodeaffinity :
  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}  
touch pod-podantiaffinity.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-podantiaffinity
  namespace: scheduling
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: pod
                operator: In
                values:
                - alone
          topologyKey: "kubernetes.io/hostname"
  containers:
  - name: pod-podantiaffinity
    image: nginx

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


2. Créons donc ce pod :


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-podantiaffinity.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/pod-podantiaffinity created*

3. Voyons voir dans quel noeud ce pod a été mis :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -n scheduling pod-podantiaffinity -o wide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME                  READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-podantiaffinity   1/1     Running   0          14s   10.32.0.4   master   <none>           <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cette fois-ci, soit sur le noeud master ou node1.

<hr>

## NodeName

<hr>

1. Définissons un pod que l’on va scheduler dans le noeud master avec la propriété nodename :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-nodename.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodename
  namespace: scheduling
spec:
  containers:
  - name: nginx
    image: nginx
  nodeName: master
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Créons donc ce pod :
   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-nodename.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


*pod/pod-nodename created*

3. Regardons dans quel noeud ce pod se trouve :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -n scheduling pod-nodename -o wide
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME           READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-nodename   1/1     Running   0          4s    10.44.0.4       master   <none>           <none>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sans surprise le noeud master. :)

## Clean Up

Nous pouvons supprimer les ressources générées par cet exercice de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
pod "pod-nodeaffinity" deleted
pod "pod-nodename" deleted
pod "pod-podantiaffinity" deleted
Error from server (NotFound): error when deleting "pod-nodeselector.yaml": pods "pod-nodeselector" not found
Error from server (NotFound): error when deleting "pod-toleration.yaml": pods "pod-toleration" not found
Error from server (NotFound): error when deleting "pod-without-toleration.yaml": pods "pod-without-toleration" not found
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>