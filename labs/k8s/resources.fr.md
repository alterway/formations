# Resources Handling

Machine : **master**

```bash
training@master$ mkdir resources
training@master$ cd resources
training@master$ kubectl create namespace resources
```

## Limit/Request for a pod

1. Nous allons commencer par créer un pod qui réclame des ressources et qui a une limite de ressources également :

```bash
training@master$ touch test-resources.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-resources
  namespace: resources
spec:
  containers:
  - name: app
    image: redis
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

2. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f test-resources.yaml

pod/test-resources created
```

3. Nous pouvons faire un describe sur notre pod pour voir que notre les requests/limits de ressources ont bien été prises en comptes :

```bash
training@master$ kubectl describe pods -n resources test-resources

...
Host Port:      <none>
State:          Running
  Started:      Wed, 28 Oct 2020 13:18:59 +0000
Ready:          True
Restart Count:  0
Limits:
  cpu:     500m
  memory:  128Mi
Requests:
  cpu:        250m
  memory:     128Mi
Environment:  <none>
Mounts:
  /var/run/secrets/kubernetes.io/serviceaccount from default-token-587zl (ro)
...
```

## Limit Ranges

1. Nous allons donc créer une limit range définissant une limit et une request par défaut pour nos pods :

```bash
training@master$ touch mem-limit-range.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
  namespace: resources
spec:
  limits:
  - default:
      memory: 768Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```

2. Créeons donc cette limitRange :

```bash
training@master$ kubectl apply -f mem-limit-range.yaml

limitrange/mem-limit-range created
```

3. Nous pouvons consulter notre limitRange de la facon suivante :

```bash
training@master$ kubectl describe -n resources limitrange mem-limit-range

Name:       mem-limit-range
Namespace:  resources
Type        Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---  ---  ---------------  -------------  -----------------------
Container   memory    -    -    256Mi            768Mi          -
```

4. Nous allons maintenant créer un pod, sans définir une request/limit de ressources :

```bash
training@master$ touch test2-resources.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test2-resources
  namespace: resources
spec:
  containers:
  - name: app
    image: redis
```

5. Créeons donc ce pod :

```bash
training@master$ kubectl apply -f test2-resources.yaml

pod/test2-resources created
```

6. Faisons maintenant un describe sur ce pod, nous voyons bien que la limit de RAM est a 768Mi et la request est de 256Mi :

```bash
training@master$ kubectl describe pods -n resources test2-resources

...
Host Port:      <none>
State:          Running
  Started:      Wed, 28 Oct 2020 13:34:12 +0000
Ready:          True
Restart Count:  0
Limits:
  memory:  768Mi
Requests:
  memory:     256Mi
Environment:  <none>
Mounts:
  /var/run/secrets/kubernetes.io/serviceaccount from default-token-587zl (ro)
...
```
## Resource Quota

1. Commençons par créer une resource-quota sur note namespace de 1Gi en requests et 2Gi en limits :

```bash
training@master$ touch resource-quota.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-quota
  namespace: resources
spec:
  hard:
    requests.memory: 1Gi
    limits.memory: 2Gi
```

2. Créeons cette resource-quota :

```bash
training@master$ kubectl apply -f resource-quota.yaml

resourcequota/resource-quota created
```

3. Nous pouvons consulter notre Resource Quota de la facon suivante :

```bash
training@master$ kubectl describe -n resources resourcequota

Name:            resource-quota
Namespace:       resources
Resource         Used   Hard
--------         ----   ----
limits.memory    896Mi  2Gi
requests.memory  384Mi  1Gi
```

4. Nous allons maintenant définir un pod redis avec une request de 768Mi (Sachant que nous avons deja un pod avec 128Mi de request et un autre avec 256Mi) :

```bash
training@master$ touch test3-resources.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test3-resources
  namespace: resources
spec:
  containers:
  - name: app
    image: redis
    resources:
      requests:
        memory: "768Mi"
        cpu: "250m"
```

5. Essayons de créer ce pod :

```bash
training@master$ kubectl apply -f test3-resources.yaml

Error from server (Forbidden): error when creating "test3-resources.yaml": pods "test3-resources" is forbidden: exceeded quota: resource-quota, requested: requests.memory=768Mi, used: requests.memory=384Mi, limited: requests.memory=1Gi
```

La création échoue donc puisque la request demandée, s'ajoutant aux requests des deux pods existants, est supérieur à celle définie par la resource quota qui est de 1Gi.

## Clean up

Nous pouvons maintenant supprimer les ressources que nous avons crées dans ces exercices :

```bash
training@master$ kubectl delete -f .

limitrange "mem-limit-range" deleted
resourcequota "resource-quota" deleted
pod "test-resources" deleted
pod "test2-resources" deleted
Error from server (NotFound): error when deleting "test3-resources.yaml": pods "test3-resources" not found
```
