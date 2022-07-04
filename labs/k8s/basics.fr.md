# Les Bases

<hr>

Machine : **master**

<hr>

**Namespace**

Aide à résoudre la complexité de l'organisation des objets au sein d'un cluster. Les namespaces permettent de regrouper des objets afin que vous puissiez les filtrer et les contrôler comme une unité. Qu'il s'agisse d'appliquer des politiques de contrôle d'accès personnalisées ou de séparer tous les composants d'un environnement de test, les namespaces sont un concept puissant et flexible pour gérer les objets en tant que groupe.

En ligne de commande

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir basics
cd basics
kubectl create namespace basics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Autre méthode

1. Créons un manifeste de namespace avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Namespace
metadata:
  name: lab
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Appliquons le fichier pour créer le namespace :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f lab-ns.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Vérifions que le namespace lab a bien été créé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get namespace
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

## Lancement du premier pod

**Pod**

Unité d'exécution de base d'une application Kubernetes. Il constitue la plus petite et la plus simple unité dans le modèle d'objets de Kubernetes pouvant être  créer ou déployer. Un Pod représente des process en cours d'exécution dans un cluster.

Pod
Unité d'exécution de base d'une application Kubernetes. Il constitue la plus petite et la plus simple unité dans le modèle d'objets de Kubernetes pouvant être créer ou déployer. Un Pod représente des process en cours d'exécution dans un cluster.

1. Créons un manifeste d'un pod avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: lab-pod
  namespace: lab  
  labels:
    app: web
spec:
  containers:
  - image: nginx
    name: nginx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Appliquons le fichier pour créer le pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f lab-pod.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Vérifions que le pod lab-pod a bien été créé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl -n lab get pods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Deployment**

Un déploiement Kubernetes est un objet Kubernetes qui fournit des mises à jour déclaratives aux applications. Un déploiement permet de décrire le cycle de vie d'une application, comme les images à utiliser, le nombre de pods qu'il devrait y avoir et la manière dont ils doivent être mis à jour. 

1. Créons un déploiement avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab-deployment
  namespace: lab
  labels:
    app: httpd
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.43
        ports:
        - containerPort: 80
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Appliquons le fichier pour créer le déploiement :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f lab-deployment.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Vérifions que le déploiement lab-deployment a bien été créé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl -n lab get deployment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Autres manières de déployer les applications :

A part le type **Deployment**, il existe aussi les **Statefulsets** et les **Daemonsets**. 

Les objets StatefulSet sont conçus pour déployer des applications avec état et des applications en cluster qui enregistrent des données sur un espace de stockage persistant . 

Les DaemonSets sont utilisés pour garantir que tous vos nœuds exécutent une copie d'un pod, ce qui vous permet d'exécuter l'application sur chaque nœud. Lorsque vous ajoutez un nouveau nœud au cluster, un pod est créé automatiquement sur le nœud.



**Service**

Dans Kubernetes, un service est une abstraction qui définit un ensemble logique de pods et une politique permettant d'y accéder (parfois ce modèle est appelé un micro-service). L'ensemble des pods ciblés par un service est généralement déterminé par un "Selector".

1. Créons un manifeste d'un pod avec le contenu yaml suivant :


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: lab
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Appliquons le fichier pour créer le service :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f lab-svc.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Vérifions que le service app-service a bien été créé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl -n lab get svc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

