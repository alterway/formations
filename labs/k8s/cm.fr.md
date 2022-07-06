# ConfigMaps



<hr>

Machine : **master**

<hr>

## All in One


1. Commençons par définir un manifest :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch cm.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
    redis-config: |
      maxmemory 2mb
      maxmemory-policy allkeys-lru

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-env
data:
   redis_host: "redis-svc"
   redis_port: "6349"

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
data:
   log_level: "NOTICE"
---

apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: REDIS_HOST
          valueFrom:
            configMapKeyRef:
              name: redis-env
              key: redis_host
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: env-config
              key: log_level
  restartPolicy: Never


---

apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod-v
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "cat /etc/config/redis-config" ]
      volumeMounts:
      - name: redis-conf-volume
        mountPath: /etc/config
  volumes:
    - name: redis-conf-volume
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: redis-config
  restartPolicy: Never

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


2. Appliquons ce manifest

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f cm.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


3. Vérifions que les variables d'envronnement et fichier ont bien été affectés

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl logs dapi-test-pod
kubectl logs dapi-test-pod-v
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Configmap à partir d'un fichier

1. Créer un fichier `valeurs.txt` avec les valeurs suivantes :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
cle1: valeur1
cle2: valeur2
cleN: valeurN
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


2. Créer un fichier `valeurs.json` avec les valeurs suivantes :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.json .numberLines}
{cle1: valeur1, cle2: valeur2, cleN: valeur2}.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


3. Créer les configmaps

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl create configmap cmjson --from-file=valeurs.json
kubectl create configmap cmtxt --from-file=valeurs.txt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Vérifier le contenu des cm

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get cm -o yaml cmjson
kubectl get cm -o yaml cmtxt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


5. Utilisation dans un pod

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh","-c","cat /etc/config/keys" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: cmjson
        items:
        - key: valeurs.json
          path: keys
  restartPolicy: Never
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


<hr>


