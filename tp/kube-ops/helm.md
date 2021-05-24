# Helm

Machine : **master**

```bash
training@master$ mkdir helm
training@master$ cd helm
training@master$ kubectl create namespace helm
```

## Installation d'un echo-server avec Helm

1. Commençons par l'installation de Helm :

```bash
training@master$ curl -Lo helm.tar.gz https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz
training@master$ tar xvf helm.tar.gz
training@master$ sudo mv linux-amd64/helm /usr/local/bin
training@master$ rm -rf helm.tar.gz linux-amd64
```

2. Nous pouvons tester l'installation de la façon suivante :

```bash
training@master$ helm version

version.BuildInfo{Version:"v3.3.4", GitCommit:"a61ce5633af99708171414353ed49547cf05013d", GitTreeState:"clean", GoVersion:"go1.14.9"}
```

3. Les artifacts Helm sont stockes sur des repositories. Il est nécessaire d'ajouter. Nous allons ajouter le repo **ealenn** contenant le chart **echo-server** :

```bash
training@master$ helm repo add ealenn https://ealenn.github.io/charts

"ealenn" has been added to your repositories
```

4. Une fois notre repository ajouté, nous pouvons installer n'importe quel chart se trouvant dans ce repository. Installons donc notre echo-server :

```bash
training@master$ helm install echo-server ealenn/echo-server

NAME: echo-server
LAST DEPLOYED: Tue Oct 27 10:21:27 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

5. Nous pouvons lister les charts installés de la façon suivante :

```bash
training@master$ helm list

NAME       	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART            	APP VERSION
echo-server	default  	1       	2020-10-27 10:21:27.307028704 +0000 UTC	deployed	echo-server-0.3.0	0.4.0
```

6. Nous pouvons voir les pods générés par l'installation :

```bash
training@master$ kubectl get pods

NAME                           READY   STATUS    RESTARTS   AGE
echo-server-79cc9789cb-hqmlt   1/1     Running   0          2m10s
```

7. Quant à la désinstallation, elle se fait de la façon suivante :

```bash
training@master$ helm uninstall echo-server

release "echo-server" uninstalled
```

## Installation avec un fichier values.yaml

1. Commençons par créer un fichier values.yaml :

```bash
training@master$ touch values.yaml
```

Avec le contenu yaml suivant :

```yaml
replicaCount: 3

image:
  tag: "0.4.1"
```

2. Nous allons cette fois ci installer notre echo-server dans le namespace **helm**, configure à l'aide du fichier values.yaml ci dessus :

```bash
training@master$ helm install echo-server ealenn/echo-server --values values.yaml --namespace helm

NAME: echo-server
LAST DEPLOYED: Sat Oct 31 17:57:50 2020
NAMESPACE: helm
STATUS: deployed
REVISION: 1
```

3. Nous allons maintenant voir si notre chart bien génère 3 pods :

```bash
training@master$ kubectl get pods -n helm

NAME                           READY   STATUS    RESTARTS   AGE
echo-server-66d9c454b5-8crn7   1/1     Running   0          32s
echo-server-66d9c454b5-wdr7p   1/1     Running   0          32s
echo-server-66d9c454b5-z6cwt   1/1     Running   0          32s
```

4. Nous pouvons maintenant désinstaller notre echo-server :

```bash
training@master$ helm uninstall echo-server -n helm

release "echo-server" uninstalled
```
