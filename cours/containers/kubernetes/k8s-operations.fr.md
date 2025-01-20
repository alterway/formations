# KUBECTL : Usage Avancé


### Kubectl : Usage avancé

- Certaines commandes qui modifient un déploimement accepte un flag optionnel `--record`
- Ce flag stocke la ligne de commande dans le déploiement
- Et est copié aussi dans le `replicaSet` (annotation)
- Cela permet de suivre quelle commande a créé ou modifié ce `replicatset`

```bash

$ kubectl create -f nginx.yaml --record
deployment.apps/nginx created

# Voir les informations
kubectl rollout history
```

### Kubectl : Usage avancé

- Utiliser le flag `--record`

```bash
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

```bash
kubectl scale --replicas=5 deployment nginx
```

- Il est possible de changer l'image d'un container utilisée par un _Deployment_ :

```bash
kubectl set image deployment nginx nginx=nginx:1.15
```


### Kubectl : Usage avancé

- Dry run. Afficher les objets de l'API correspondant sans les créer :

```bash
kubectl run nginx --image=nginx --dry-run=client
kubectl run nginx --image=nginx --dry-run=server
```

- Démarrer un container en utilisant une commande différente et des arguments différents :

```bash
kubectl run nginx --image=nginx \
--command -- <cmd> <arg1> ... <argN>
```

- Démarrer un Cron Job qui calcule π et l'affiche toutes les 5 minutes :

```bash
kubectl run pi --schedule="0/5 * * * ?" --image=perl --restart=OnFailure \
-- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

### Kubectl : Usage avancé

- Se connecter à un container:

```bash
kubectl run -it busybox --image=busybox -- sh
```

- S'attacher à un container existant :

```bash
kubectl attach my-pod -i
```

- Accéder à un service via un port :

```bash
kubectl port-forward my-svc 6000
```

- Mettre en place de l'auto-scaling
ex: Mise à l'échelle automatique avec un minimum de 2 et un maximum de 10 réplicas lorsque l'utilisation du processeur est égale ou supérieure à 70 %


```bash
kubectl autoscale deployment my-Deployments --min=2 --max=10 --cpu-percent=70  
```


### Kubectl : Logging

- Utiliser `kubectl` pour diagnostiquer les applications et le cluster kubernetes :

```bash
kubectl cluster-info
kubectl get events --sort-by='.lastTimestamp'
kubectl describe node <NODE_NAME>
kubectl describe node <node-name> | grep Taints
kubectl  logs (-f) <POD_NAME>
```


### Kubectl : Logs 

- Voir les logs containers `kubectl logs`
- Il est possible de donner un _nom de pod_ ou un _type/nom_
  par exemple si l'on donne un nom de déploiement ou de replica set, les logs correspondront au premier pod
- Par défaut les logs affichées sont celles du premier container dans le pod. 

```bash
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

```bash
# exemple :
kubectl logs deploy/pingpong --tail 100 --follow --since=5s
# Affichera toutes les logs depuis 5 secondes et commencera au 100eme messages et continuera l'affichage des nouveaux messages
```

### Kubectl : Afficher les logs de plusieurs pods

- Lorsque on spécifie un nom de déploiement, seuls les logs d'un seul pod sont affichés

- Pour afficher les logs de plusieurs pod il faudra utiliser un `selecteur` (label)

```bash
kubectl logs -l app=my-app --tail 100 # -f 
```

### Kubectl : un outil très pratique pour les logs : 

[stern](https://github.com/wercker/stern)

![pod network](images/stern-1.png)

### Kubectl : Maintenance

- Obtenir la liste des noeuds ainsi que les informations détaillées :

```bash
kubectl get nodes
kubectl describe nodes
```

### Kubectl : Maintenance

- Marquer le noeud comme _unschedulable_ (+ drainer les pods) et _schedulable_ :

```bash
kubectl cordon <NODE_NAME>
kubectl drain <NDOE_NAME>
kubectl uncordon <NODE_NAME>
```

### Kubectl : Contexts

- Dans le cas ou votre kubeconfig comporte plusieurs clusters

```bash

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

```bash

kubectl get ns

kubectl config set-context --current --namespace <nom-du-namespace>

# ou

alias kubens='kubectl config set-context --current --namespace '

# ex: kubens kube-system 

```

### Kubectl : Installer des plugins 

`krew` est un manager de plugins pour `kubectl`

installation de krew (<https://krew.sigs.k8s.io/docs/user-guide/setup/install/>)


```bash

kubectl krew install example

kubectl example deploy

```

Liste des plugins : <https://krew.sigs.k8s.io/plugins/>
  

très utiles 

- `neat` : permet de d'avoir un ouput "propre" d'une resource kubernetes - très utile pour créer des manifestes à partir de resources existantes
- `ctx` : permet de changer de contexte facilement
- `ns` : permet de changet de namespace facilement
- `node-shell` : Créer un shell racine sur un nœud via kubectl, très pratique sur les CSP
- `df-pv` : Afficher l'utilisation du disque (comme la commande df) pour les volumes persistants
- `popeye` : Analyse vos clusters pour détecter d'éventuels problèmes de ressources
  
  
