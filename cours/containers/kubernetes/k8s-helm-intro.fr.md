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

- `Release` : Une instance d'un chart helm s'exécutant dans un cluster Kubernetes.
- `Repository` : répertoire ou espace (public ou privé) où sont regroupés les `charts`.
  
- Les charts sont versionnés

- Les charts peuvent être stockés sur des référentiels privés ou publics


### Kubernetes : Helm Chart Structure

- Structure par défaut d'un chart

```console
mychart/
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

### Kubernetes : Helm Chart : Mode de fonctionnement

![](images/helm.png)

### Kubernetes : Helm installation premiers pas

- Installer Helm (sur une distribution Linux):
```console
curl \
  https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3 | bash
```
  
- Voir la liste des `charts` disponibles sur les répertoires officiels : `helm search`
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

- Il faut donner un nom à cette **Release**

  (ou utiliser le flag  `--generate-name` pour que helm le fasse automatiquement pour nous)

```bash
# Installer le chart nginx :
  helm install nginx stable/nginx

# List the releases:
  helm list
```

### Kubernetes : Helm - Voir les ressources d'une release

- Il est possible d'utiliser un sélecteur (label)

```bash
# Lister toutes les resources créées dans une release
  kubectl get all --selector=release=nginx
```


### Kubernetes : Helm -  Configurer une release


- Par défaut, le chart `stable/nginx` crée un service de type` LoadBalancer`

- On veut changer cela en un `NodePort`

- on peut utiliser `kubectl edit service nginx-nginx`, mais ...

  ... nos modifications seraient écrasées la prochaine fois qu'on met à jour ce Chart !

- On va pour cela définir une valeur pour le type de service

- Les valeurs sont des paramètres que le **Chart** peut utiliser pour modifier son comportement

- Les valeurs ont des valeurs par défaut

- Chaque **Chart** peut de définir ses propres valeurs et leurs valeurs par défaut

### Kubernetes : Helm - Voir les différentes valeurs

- Il est possible d'inspecter une release avec les commandes  `helm show` or `helm inspect`

```bash
# Look at the README for nginx:
 
  helm show readme stable/nginx
 
# Look at the values and their defaults:
  helm show values stable/nginx
```

Les `values` n'ont peut être pas de commentaires utiles.

Le fichier `readme` peut ou pas, donner des informations sur ces `values`.

### Kubernetes : Helm - Changer les valeurs

- Les valeurs peuvent être définies lors de l'installation d'un Chart ou lors de sa mise à jour
    `helm install` `helm upgrade`

- Dans notre exemple, on va  mettre à jour `nginx` pour changer le type de service

```bash
# Update `nginx`:
 
  helm upgrade nginx stable/nginx --set service.type=NodePort
```

### Kubernetes : Helm - Créer un chart  

- Utilisation de la commande : `helm create myapp` va permettre de créer la structure de répertoire et de fichiers d'un chart "standard"
- Par défaut, ce Chart déploie un `nginx` en templétisant les `services`, `deployment`, `serviceAccount`, etc...
- C'est une bonne base pour démarrer


### Kubernetes : Helm - A quoi d'autre peut servir un chart Helm

- Outre le fait de déployer des applications, on peut gérer d'autres choses avec helm, grâce à la puissance du langage de template
- Gérer facilement les Roles / Rolebinding / ClusterRole / ClusterRoleBinding
- Des paramétrages d'opérateurs
- ...  


