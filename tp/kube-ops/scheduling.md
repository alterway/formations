# Scheduling

Machine : **master**

```bash
training@master$ mkdir scheduling
training@master$ cd scheduling
training@master$ kubectl create namespace scheduling
```

## Taints and Tolerations

1. Nous allons commencer par mettre une taint sur le noeud worker :

```bash
training@master$ kubectl taint nodes worker dedicated=experimental:NoSchedule

node/worker tainted
```

2. Nous pouvons faire un describe sur le noeud pour voir que notre taint a bien été prise en compte :

```bash
training@master$ kubectl describe node worker

CreationTimestamp:  Sun, 01 Nov 2020 09:49:52 +0000
Taints:             dedicated=experimental:NoSchedule
Unschedulable:      false
```

3. Essayons de déployer un pod sans toleration :

```bash
training@master$ touch pod-without-toleration.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-without-toleration
  namespace: scheduling
spec:
  containers:
  - name: nginx
    image: nginx
```

4. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f pod-without-toleration.yaml

pod/pod-without-toleration created
```

5. Voyons voir sur quel noeud notre pod a été schedule :

```bash
training@master$ kubectl get pods -n scheduling pod-without-toleration -o wide

NAME                     READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
pod-without-toleration   0/1     Pending   0          11m   <none>   <none>   <none>           <none>
```

Notre pod n'ayant pas de toleration pour la taint que nous avons mis sur le noeud worker, il ne peut pas se trouver dessus.

6. Définissons maintenant un pod avec un toleration a la taint definie plus haut :

```bash
training@master$ touch pod-toleration.yaml
```

Avec le contenu yaml suivant :

```yaml
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
```

7. Créeons ce pod :

```bash
training@master$ kubectl apply -f pod-toleration.yaml

pod/pod-toleration created
```

8. Nous pouvons voir dans quel noeud notre pod a été schedule :

```bash
training@master$ kubectl get pods -n scheduling pod-toleration -o wide

NAME             READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-toleration   1/1     Running   0          49s   10.44.0.1   worker   <none>           <none>
```

Le pod peut maintenant être schedule sur le noeud worker

8. Supprimons les objets que créés dans cet exercice :

```bash
training@master$ kubectl delete -f pod-toleration.yaml -f pod-without-toleration.yaml

pod "pod-toleration" deleted
pod "pod-without-toleration" deleted

kubectl taint nodes worker dedicated:NoSchedule-

node/worker untainted
```

## NodeSelector

0. Nous allons enlever la taint sur le master pour pouvoir schedule des pods dessus :

```bash
training@master$ kubectl taint nodes master node-role.kubernetes.io/master:NoSchedule-

node/master untainted
```

1. Nous allons commencer par mettre un label sur le noeud worker "disk=ssd" :

```bash
training@master$ kubectl label nodes worker disk=ssd

node/worker labeled
```

2. Nous pouvons faire un describe sur notre noeud worker pour voir que notre label a bien été pris en compte :

```bash
training@master$ kubectl describe nodes worker

Name:               worker
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    disk=ssd
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=worker
                    kubernetes.io/os=linux
```

3. Définissons un pod que l'on va scheduler sur le noeud worker à l'aide du label defini ci dessus :

```bash
training@master$ touch pod-nodeselector.yaml
```

Avec le contenu yaml suivant :

```yaml
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
```

4. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f pod-nodeselector.yaml

pod/pod-nodeselector created
```

5. Voyons voir dans quel noeud notre pod a été mis :

```bash
training@master$ kubectl get pods -n scheduling pod-nodeselector -o wide

NAME               READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-nodeselector   1/1     Running   0          17s   10.44.0.1   worker   <none>           <none>
```

Sans surpise, sur le noeud worker.

6. Supprimons le pod créé dans cet exercice :

```bash
training@master$ kubectl delete -f pod-nodeselector.yaml

pod "pod-nodeselector" deleted
```

## Node Affinity/AntiAffinity

1. Définissons un pod, avec une nodeAffinity lui imposant d'aller dans un noeud ayant comme label "disk=ssd", autrement dit le noeud worker :

```bash
training@master$ touch pod-nodeaffinity.yaml
```

Avec le contenu yaml suivant :

```yaml
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
```

2. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f pod-nodeaffinity.yaml

pod/pod-nodeaffinity created
```

3. Voyons voir dans quel noeud ce pod a été mis :

```bash
training@master$ kubectl get pods -n scheduling pod-nodeaffinity -o wide

NAME               READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-nodeaffinity   1/1     Running   0          36s   10.44.0.1   worker   <none>           <none>
```

Sans surprise, dans le noeud worker.

## Pod Affinity/AntiAffinity

1. Définissons un pod, avec une podAntiAffinity lui imposant d'aller dans un noeud ayant ne comportant pas le pod pod-nodeaffinity :

```bash
training@master$ touch pod-podantiaffinity.yaml
```

Avec le contenu yaml suivant :

```yaml
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
```

2. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f pod-podantiaffinity.yaml

pod/pod-podantiaffinity created
```

3. Voyons voir dans quel noeud ce pod a été mis :

```bash
training@master$ kubectl get pods -n scheduling pod-podantiaffinity -o wide

NAME                  READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-podantiaffinity   1/1     Running   0          14s   10.32.0.4   master   <none>           <none>
```

Cette fois-ci, sur le noeud master.

## NodeName

1. Définissons un pod que l'on va scheduler dans le noeud worker avec la propriété nodename :

```bash
training@master$ touch pod-nodename.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-nodename
  namespace: scheduling
spec:
  containers:
  - name: nginx
    image: nginx
  nodeName: worker
```

2. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f pod-nodename.yaml

pod/pod-nodename created
```

3. Regardons dans quel noeud ce pod se trouve :

```bash
training@master$ kubectl get pods -n scheduling pod-nodename -o wide

NAME           READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
pod-nodename   1/1     Running   0          4s    10.44.0.4   worker   <none>           <none>
```

Sans surprise le noeud worker. :)

## Clean Up

Nous pouvons supprimer les ressources générées par cet exercice de la façon suivante :

```bash
training@master$ kubectl delete -f .

pod "pod-nodeaffinity" deleted
pod "pod-nodename" deleted
pod "pod-podantiaffinity" deleted
Error from server (NotFound): error when deleting "pod-nodeselector.yaml": pods "pod-nodeselector" not found
Error from server (NotFound): error when deleting "pod-toleration.yaml": pods "pod-toleration" not found
Error from server (NotFound): error when deleting "pod-without-toleration.yaml": pods "pod-without-toleration" not found
```
