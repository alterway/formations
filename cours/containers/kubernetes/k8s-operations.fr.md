# KUBECTL : Usage Avancé

- Il est possible de mettre à jour un service sans incident grâce ce qui est appelé le _rolling-update_.
- Avec les _rolling updates_, les ressources qu'expose un objet `Service` se mettent à jour progressivement.
- Seuls les objets `Deployment`, `DaemonSet` et `StatefulSet` support les _rolling updates_.
- Les arguments `maxSurge` et `maxUnavailabe` définissent le rythme du _rolling update_.
- La commande `kubectl rollout` permet de suivre les _rolling updates_ effectués.


### Kubectl : Usage avancé

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: frontend
  replicas: 2
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      name: nginx
      labels:
        app: frontend
    spec:
      containers:
        - image: nginx:1.9.1
          name: nginx
```

### Kubectl : Usage avancé

- Certaines commandes qui modifient un déploimement accepte un flag optionnel `--record`
- Ce flag stocke la ligne de commande dans le déploiement
- Et est copié aussi dans le `replicaSet` (annotation)
- Cela permet de suivre quelle commande a créé ou modifié ce `replicatset`

```console

$ kubectl create -f nginx.yaml --record
deployment.apps/nginx created

# Voir les informations
kubectl rollout history
```

### Kubectl : Usage avancé

- Utiliser le flag `--record`

```console
# déployer l'image worker:v0.2
kubectl create deployment worker --image=dockercoins/worker:v0.2

# Roll back `worker` vers l'image version 0.1:
kubectl set image deployment worker worker=dockercoins/worker:v0.1 --record

# Le remettre sur la version 0.2:
kubectl set image deployment worker worker=dockercoins/worker:v0.2 --record

# Voir l'historique des changement:
kubectl rollout history deployment worker
```

### Kubectl : Usage avancé

- Il est possible d'augmenter le nombre de pods avec la commande `kubectl scale` :

```console
kubectl scale --replicas=5 deployment nginx
```

- Il est possible de changer l'image d'un container utilisée par un _Deployment_ :

```console
kubectl set image deployment nginx nginx=nginx:1.15
```


### Kubectl : Usage avancé

- Dry run. Afficher les objets de l'API correspondant sans les créer :

```console
kubectl run nginx --image=nginx --dry-run
```

- Démarrer un container en utiliser une commande différente et des arguments différents :

```console
kubectl run nginx --image=nginx \
--command -- <cmd> <arg1> ... <argN>
```

- Démarrer un Cron Job qui calcule π et l'affiche toutes les 5 minutes :

```console
kubectl run pi --schedule="0/5 * * * ?" --image=perl --restart=OnFailure \
-- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

### Kubectl : Usage avancé

- Se connecter à un container:

```console
kubectl run -it busybox --image=busybox -- sh
```

- S'attacher à un container existant :

```console
kubectl attach my-pod -i
```

- Accéder à un service via un port :

```console
kubectl port-forward my-svc 6000
```

### Kubectl : Logging

- Utiliser `kubectl` pour diagnostiquer les applications et le cluster kubernetes :

```console
kubectl cluster-info
kubectl get events
kubectl describe node <NODE_NAME>
kubectl  logs (-f) <POD_NAME>
```


### Kubectl : Logs 

- Voir les logs containers `kubectl logs`
- Il est possible de donner un _nom de pod_ ou un _type/nom_
  par exemple si l'on donne un nom de déploiement ou de replica set, les logs correspondront au premier pod
- Par défaut les logs affichées sont celles du premier container dans le pod. 

```console
# exemple :
kubectl logs deploy/nginx
```

- Faire un `CTRL-C`pour arrêter la sortie

### Kubectl : Afficher les logs en temps réel 

`kubectl logs` supporte les options suivantes :
   - `-f/--follow` pour suivre les affichage des logs en temps réel (comme pour `tail -f`)
   - `--tail` pour n'afficher que les `n` lignes à partir de la fin de la sortie
   - `--since` pour n'afficher que les logs à partir d'une certaine date
   - `--timestamps`affichera le timestamp du message

```console
# exemple :
kubectl logs deploy/pingpong --tail 100 --follow --since=5s
# Affichera toutes les logs depuis 5 secondes et commencera au 100eme messages et continuera l'affichage des nouveaux messages
```

### Kubectl : Afficher les logs de plusieurs pods

- Lorsque on spécifie un nom de déploiement, seuls les logs d'un seul pod sont affichés

- Pour afficher les logs de plusieurs pod il faudra utiliser un `selecteur` (label)

```console
kubectl logs -l app=my-app --tail 100 # -f 
```

### Kubectl : un outil très pratique pour les logs : 

[stern](https://github.com/wercker/stern)

![pod network](images/stern-1.png)

### Kubectl : Maintenance

- Obtenir la liste des noeuds ainsi que les informations détaillées :

```console
kubectl get nodes
kubectl describe nodes
```

### Kubectl : Maintenance

- Marquer le noeud comme _unschedulable_ (+ drainer les pods) et _schedulable_ :

```console
kubectl cordon <NODE_NAME>
kubectl drain <NDOE_NAME>
kubectl uncordon <NODE_NAME>
```

### Kubectl : Contexts

- Dans le cas ou votre kubeconfig comporte plusieurs clusters

```console

# lister les contextes
kubectl config get-contexts

# Se déplacer dans un contexte 
kubectl config use-context <nom-du-contexte>


# ou

alias kubectx='kubectl config use-context '

# ex: kubectx <nom-du-cluster>

```

### Kubectl : Se déplacer dans un NS de manière permanente

Évite de toujours préciser le flag `-n`

```console

kubectl get ns

kubectl config set-context --current --namespace <nom-du-namespace>

# ou

alias kubens='kubectl config set-context --current --namespace '

# ex: kubens kube-system 

```

### Kubectl : Installer des plugins 

`krew` est un manager de plugins pour `kubectl`

installation de krew (<https://krew.sigs.k8s.io/docs/user-guide/setup/install/>)


```console

kubectl krew install example

kubectl example deploy

```

Liste des plugins : <https://krew.sigs.k8s.io/plugins/>


----


