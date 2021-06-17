# Liveness and Readiness probe


<hr>

Machine : **master**

<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir healthchecking
cd healthchecking
kubectl create namespace healthchecking
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Liveness probe, avec un fichier

1. Commençons par créer un ficher yaml décrivant un pod avec une liveness probe.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch file-liveness.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: file-liveness
  namespace: healthchecking
spec:
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 10; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Nous allons donc créer ce pod de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f file-liveness.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/file-liveness created*

3. Au bout de quelques secondes, nous pouvons faire un describe sur le pod et observer le résultat suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n healthchecking file-liveness

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  29s               default-scheduler  Successfully assigned default/liveness-exec to worker
  Normal   Pulling    29s               kubelet            Pulling image "busybox"
  Normal   Pulled     27s               kubelet            Successfully pulled image "busybox" in 1.59651835s
  Normal   Created    27s               kubelet            Created container liveness
  Normal   Started    27s               kubelet            Started container liveness
  Warning  Unhealthy  5s (x3 over 15s)  kubelet            Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
  Normal   Killing    5s                kubelet            Container liveness failed liveness probe, will be restarted
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

La liveness probe fini donc par échouer comme prévu, étant donne que le fichier /tmp/healthy n'existe plus. On remarque également que Kubernetes kill le conteneur a l'intérieur du pod et le recrée.

## Liveness probe, avec une requête http

Nous allons cette fois mettre en place une liveness probe mais avec une requête http exécutée périodiquement.

1. Commençons par créer un fichier http-liveness.yaml :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch http-liveness.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: http-liveness
  namespace: healthchecking
spec:
  containers:
  - name: liveness
    image: nginx
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cette fois ci, la liveness probe utilise une requête http avec la méthode GET sur la racine toute les 3 secondes. La liveness probe échouera selon le code d'erreur de la requête http.

2. Créons donc ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f http-liveness.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


*pod/http-liveness created*

3. Si nous faisons un describe sur le pod, nous devrions voir que tout se passe bien pour l'instant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n healthchecking http-liveness
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  118s  default-scheduler  Successfully assigned healthchecking/http-liveness to worker
  Normal  Pulling    118s  kubelet            Pulling image "nginx"
  Normal  Pulled     114s  kubelet            Successfully pulled image "nginx" in 3.862745132s
  Normal  Created    114s  kubelet            Created container liveness
  Normal  Started    113s  kubelet            Started container liveness
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Nous allons supprimer la page d'accueil de nginx dans le conteneur, ce qui entraînera un code d'erreur 400 pour la requête http de la liveness probe :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl exec -n healthchecking http-liveness rm /usr/share/nginx/html/index.html
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Au bout de quelques secondes, on devrait voir que la liveness probe échoue et le conteneur est recréé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n healthchecking http-liveness

Type     Reason     Age                From               Message
----     ------     ----               ----               -------
Normal   Scheduled  59s                default-scheduler  Successfully assigned healthchecking/http-liveness to worker
Normal   Pulled     57s                kubelet            Successfully pulled image "nginx" in 1.609742987s
Normal   Pulling    34s (x2 over 58s)  kubelet            Pulling image "nginx"
Warning  Unhealthy  34s (x3 over 40s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 403
Normal   Killing    34s                kubelet            Container liveness failed liveness probe, will be restarted
Normal   Created    32s (x2 over 57s)  kubelet            Created container liveness
Normal   Started    32s (x2 over 57s)  kubelet            Started container liveness
Normal   Pulled     32s                kubelet            Successfully pulled image "nginx" in 2.031773864s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On voit que le conteneur a été tué par Kubernetes étant donné que la liveness probe a échoué.


<hr>

## Readiness Probe

<hr>

Nous allons maintenant voir une autre façon de faire du healthchecking sur un pod : la readiness probe. Elle permet à Kubernetes de savoir lorsque l'application se trouvant dans un pod a bel et bien démarré. Comme la liveness probe, elle fait ça a l'aide de commandes, de requêtes http/tcp, etc.

1. Commençons par créer un fichier file-readiness.yaml :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch file-readiness.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: file-readiness
  namespace: healthchecking
spec:
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - sleep 60; touch /tmp/healthy; sleep 600
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ce pod est un peu similaire à celui de file-liveness dans l'exercice 1. Cette fois ci, le pod attend 30 secondes au démarrage avant de créer un fichier /tmp/healthy. Ce pod contient également une readiness probe vérifiant l'existence de ce fichier /tmp/healthy.

2. Créons donc ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f file-readiness.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/file-readiness created*

3. Si on fait on describe tout de suite après la création du pod, on devrait voir le pod n'est pas encore prêt :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n healthchecking file-readiness  

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  39s               default-scheduler  Successfully assigned healthchecking/file-readiness to worker
  Normal   Pulling    38s               kubelet            Pulling image "busybox"
  Normal   Pulled     37s               kubelet            Successfully pulled image "busybox" in 1.64435698s
  Normal   Created    37s               kubelet            Created container liveness
  Normal   Started    36s               kubelet            Started container liveness
  Warning  Unhealthy  1s (x7 over 31s)  kubelet            Readiness probe failed: cat: can't open '/tmp/healthy': No such file or directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Au bout d'environ une minute, on devrait voir le pod entrant dans l'état ready (1/1) :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods -n healthchecking

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

NAME             READY   STATUS             RESTARTS   AGE
file-liveness    0/1     CrashLoopBackOff   7          14m
file-readiness   1/1     Running            0          105s
http-liveness    1/1     Running            1          6m3s  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Clean up

Nous allons supprimer les ressources créées par cet exercice de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f .
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>