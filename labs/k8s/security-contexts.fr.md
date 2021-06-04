# Security contexts

Machine : **master**

```bash
training@master$ mkdir security-contexts
training@master$ cd security-contexts
training@master$ kubectl create namespace security-contexts
```

## Run container as user

1. Définissons un simple pod postgres :

```bash
training@master$ touch pod-as-root.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-as-root
  namespace: security-contexts
spec:
  containers:
  - name: pod-as-root
    image: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: password
```

2. Créeons ce pod :

```bash
training@master$ kubectl apply -f pod-as-root.yaml

pod/pod-as-root created
```

3. Exécutons la commande id dans ce contenur pour connaitre l'utilisateur avec lequel le conteneur est exécuté :

```bash
training@master$ kubectl exec -it pod-as-root -n security-contexts -- id

uid=0(root) gid=0(root) groups=0(root)
```

4. Définissons maintenant ce moment pod, mais exécuté en tant qu'utilisateur "postgres" :

```bash
training@master$ touch pod-as-user.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-as-user
  namespace: security-contexts
spec:
  containers:
  - name: pod-as-user
    image: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: password
  securityContext:
    runAsUser: 999
    runAsGroup: 999
```

5. Créeons ce pod

```bash
training@master$ kubectl apply -f pod-as-user.yaml

pod/pod-as-user created
```

6. Exécutons à nouveau la commande id :

```bash
training@master$ kubectl exec -it pod-as-user -n security-contexts -- id

uid=999(postgres) gid=999(postgres) groups=999(postgres)
```

Le conteneur est donc exécuté en tant que "postgres".

## Set Capabilities

1. Nous allons definir un pod avec les capabilities par défaut :

```bash
training@master$ touch pod-default-capabilities.yaml
```

Avec le contenu yaml :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-default-capabilities
  namespace: security-contexts
spec:
  containers:
  - name: pod-default-capabilities
    image: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: password
```

2. Créeons maintenant ce pod :

```bash
training@master$ kubectl apply -f pod-default-capabilities.yaml

pod/pod-default-capabilities created
```

3. Nous allons faire chown sur le fichier entrypoint docker-entrypoint.sh :

```bash
training@master$ kubectl exec -n security-contexts -it pod-default-capabilities -- chown postgres:postgres /docker-entrypoint.sh
```

4. Nous allons maintenant définir un pod, en lui retirant la capability CHOWN :

```bash
training@master$ touch pod-with-less-capabilities.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-less-capabilities
  namespace: security-contexts
spec:
  containers:
  - name: pod-with-less-capabilities
    image: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: password
    securityContext:
      capabilities:
        drop: ["CHOWN"]
```

5. Créeons maintenant ce pod :

```bash
training@master$ kubectl apply -f pod-with-less-capabilities.yaml

pod/pod-with-less-capabilities created
```

6. Vérifions si nous pouvons exécuter notre chown :

```bash
training@master$ kubectl exec -n security-contexts -it pod-with-less-capabilities -- chown postgres:postgres /docker-entrypoint.sh

chown: changing ownership of '/docker-entrypoint.sh': Operation not permitted
command terminated with exit code 1
```

## Seccomp profile

1. Nous allons maintenant définir un pod, en lui appliquant un profile seccomp interdisant le syscall chmod :

```bash
training@master$ touch pod-with-seccomp.yaml
```

Avec le contenu yaml suivant :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-seccomp
  namespace: security-contexts
spec:
  containers:
  - name: pod-with-seccomp
    image: postgres
    env:
    - name: POSTGRES_PASSWORD
      value: password
    securityContext:
      seccompProfile:
        type: Localhost
        localhostProfile: deny-chown-seccomp.json
```

2. Definissons également un profile seccomp, deny-chown-seccomp.json (à faire sur les deux machines):

```bash
training@master$ sudo mkdir /var/lib/kubelet/seccomp
training@master$ sudo touch /var/lib/kubelet/seccomp/deny-chown-seccomp.json
```

Avec le contenu JSON suivant :

```
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "syscalls": [
    {
      "name": "chmod",
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
```

3. Créeons maintenant ce pod :

```bash
training@master$ kubectl apply -f pod-with-seccomp.yaml

pod/pod-with-seccomp created
```

4. Faisons un describe sur notre pod :

```bash
training@master$ kubectl describe pods -n security-contexts pod-with-seccomp

Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  20s                default-scheduler  Successfully assigned security-contexts/pod-with-seccomp to worker
  Normal   Pulled     17s                kubelet            Successfully pulled image "postgres" in 2.941565485s
  Normal   Pulling    16s (x2 over 20s)  kubelet            Pulling image "postgres"
  Normal   Created    14s (x2 over 17s)  kubelet            Created container pod-with-seccomp
  Normal   Started    14s (x2 over 16s)  kubelet            Started container pod-with-seccomp
  Normal   Pulled     14s                kubelet            Successfully pulled image "postgres" in 1.601043628s
  Warning  BackOff    13s (x2 over 14s)  kubelet            Back-off restarting failed container
```

5. Notre pod a du mal a démarrer, regardons les logs :

```bash
training@master$ kubectl logs -n security-contexts pod-with-seccomp

The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

initdb: error: could not change permissions of directory "/var/lib/postgresql/data": Operation not permitted
fixing permissions on existing directory /var/lib/postgresql/data ...
```

Le conteneur a l'interieur de notre pod échoue car il ne peut pas changer les permissions d'un fichier, notre profile seccomp a bien été pris en compte.

## Clean Up

Supprimons les objets generes par cet exercice :

```bash
training@master$ kubectl delete -f .
```
