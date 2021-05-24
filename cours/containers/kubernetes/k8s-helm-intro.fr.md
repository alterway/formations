# KUBERNETES : Introduction à Helm
 
### kubernetes : Helm CNCF graduation status

- Le 30 avril 2020, Helm était le 10e projet à être *diplômé* (graduate) au sein de la CNCF

  (aux côtés de Containerd, Prometheus et Kubernetes lui-même)

- Il s'agit d'une reconnaissance de la CNCF pour les projets qui
  - démontrent une adoption florissante, un processus de gouvernance ouvert,
  - qui ont un engagement fort envers la communauté, la durabilité et l'inclusivité.

A voir :

-  [CNCF announcement](https://www.cncf.io/announcement/2020/04/30/cloud-native-computing-foundation-announces-helm-graduation/)
  et [Helm announcement](https://helm.sh/blog/celebrating-helms-cncf-graduation/)

### Kubernetes : Helm différence entre charts et packages

- Une application conçue pour faciliter l'installation et la gestion des applications sur Kubernetes.
- Il utilise un format de paquetage appelé `Charts`.
- Il est comparable à apt/yum/homebrew.
- Un chart contient des manifestes yaml
- Sur la plupart des distributions, un package ne peut être installé qu'une seule fois
  (l'installation d'une autre version remplace celle installée)
- Un chart peut être installé plusieurs fois
- Chaque installation est appelée une *version*
- Cela permet d'installer par ex. 10 instances de MongoDB
  (avec des versions et configurations potentiellement différentes)  

### Kubernetes : Helm concepts

- `helm` est un outil CLI

- Il est utilisé pour trouver, installer, mettre à jour *des charts*

- Un `Chart` est une archive contenant des bundles YAML modélisés. Un chart est pratiquement un regroupement de ressources Kubernetes pré-configurées.

- `Release` : Une instance d'un chart helm s'éxécutant dans un cluster Kubernetes.
- `Repository` : répertoire ou espace (public ou privé) où sont regroupés les `charts`.
  
- Les charts sont versionnés

- Les charts peuvent être stockés sur des référentiels privés ou publics


### Kubernetes : Helm installation premiers pas

- Installer Helm (sur une distribution Linux):
- `curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3 | bash`
  
- Voir la liste des `charts` disponibles sur les répertoire officiel : `helm search`
- Afficher la liste des `charts` disponibles pour _prometheus_ : `helm search prometheus`
- Afficher les options disponibles dans un `chart` Helm:  `helm inspect stable/prometheus`


### Kubernetes : Helm - Charts et repositories

- Un **repository** (repo) est une collection de charts

- C'est simplement un ensemble de fichiers
  locaux ou hébergés sur un serveur web statiquement
- On peut ajouter des **repos** à helm en leur donnant un surnom
- Le surnom sert à référencer les charts de ce **repo**

  (they can be hosted by a static HTTP server, or on a local directory)
- Par exemple `helm install hello/world` : le chart `world` dans le **repo** `hello`, hello peut être quelque chose comme https://alterway.fr/charts/


### Kubernetes : Helm -  Manager les repositories

Vérifions quels référentiels nous avons et ajoutons le référentiel `stable`

  (le repo `stable` contient un ensemble des charts officiels)

```bash

# Lister vos repos:
  helm repo list

# Ajouter the `stable` repo:
  helm repo add stable https://charts.helm.sh/stable
```

### Kubernetes : Helm - Chercher les Charts disponibles

- On peut chercher les charts avec la commande suivante `helm search`

- Il faut spécifier ou chercher `repo` ou `hub`

```bash
# Chercher nginx dans tous les repos ajoutés précédemment
  helm search repo nginx

# Chercher nginx sur le hub Helm:
  
  helm search hub nginx
```

[Helm Hub](https://hub.helm.sh/) indexe tout un tas de repo, en utilisant le serveur [Monocular](https://github.com/helm/monocular).

### Kubernetes : Helm - Charts et releases

- "Installer un chart"  veut dire installer une **release**

- Il faut donner un nom a cette release

  (ou utiliser le flag  `--generate-name` pourque helm le fasse automatiquement pour nous)

```bash
# Installer le chart nginx :
  helm install nginx stable/nginx

# List the releases:
  helm list
```

### Kubernetes : Helm - Voir les resources d'une release

- Il est possible d'utiliser un selecteur (label)

```bash
# Lister toutes les resources créées dans une release
  kubectl get all --selector=release=nginx
```


### Kubernetes : Helm -  Configurer une release

- By default, `stable/nginx` creates a service of type `LoadBalancer`

- We would like to change that to a `NodePort`

- We could use `kubectl edit service nginx-nginx`, but ...

  ... our changes would get overwritten next time we update that chart!

- Instead, we are going to *set a value*

- Values are parameters that the chart can use to change its behavior

- Values have default values

- Each chart is free to define its own values and their defaults

### Kubernetes : Helm - Voir les différentes valeurs

- Il est possible d'inspecter une release avec  les commandes  `helm show` or `helm inspect`

```bash
# Look at the README for nginx:
 
  helm show readme stable/nginx
 
# Look at the values and their defaults:
  helm show values stable/nginx
```

The `values` may or may not have useful comments.

The `readme` may or may not have (accurate) explanations for the values.

(If we're unlucky, there won't be any indication about how to use the values!)

### Kubernetes : Helm - Chager les valeurs

- Values can be set when installing a chart, or when upgrading it

- We are going to update `nginx` to change the type of the service

```bash
# Update `nginx`:
 
  helm upgrade nginx stable/nginx --set service.type=NodePort
```

Note that we have to specify the chart that we use (`stable/nginx`),
even if we just want to update some values.

We can set multiple values. If we want to set many values, we can use `-f`/`--values` and pass a YAML file with all the values.

All unspecified values will take the default values defined in the chart.

### Kubernetes : Helm -  Connecting to nginx

- Let's check the nginx server that we just installed

- Note: its readiness probe has a 60s delay

  (so it will take 60s after the initial deployment before the service works)

```bash
# Check the node port allocated to the service:
  kubectl get service nginx-nginx
  PORT=$(kubectl get service nginx-nginx -o jsonpath={..nodePort})

# Connect to it, checking the demo app on `/sample/`:
  curl localhost:$PORT/sample/
```
