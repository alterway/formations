# Secrets

<hr>

Machine : **master**

<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir secrets
cd secrets
kubectl create namespace secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Postgres's Password in a secret (As environment variable)

1. Commençons par créer un secret contenant notre mot de passe postgres dans une clé **postgres_password** :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl create secret generic dev-db-secret -n secrets --from-literal postgres_password=password

secret/dev-db-secret created
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Nous pouvons inspecter notre secret de la façon suivante :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe secret -n secrets dev-db-secret
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

Name:         dev-db-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
postgres_password:  8 bytes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Définissons maintenant un pod postgres, utilisant le secret que nous avons créé ci dessus pour le mot de passe de la base de données :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-with-secret.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-secret
  namespace: secrets
spec:
  containers:
  - name: pod-with-secret
    image: postgres
    env:
      - name: POSTGRES_PASSWORD
        valueFrom:
          secretKeyRef:
            name: dev-db-secret
            key: postgres_password
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Exécutons ce pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-with-secret.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/pod-with-secret created*

1. Nous pouvons voir que notre pod utilise bien notre secret via un describe :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n secrets pod-with-secret
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
Ready:          True
Restart Count:  0
Environment:
  POSTGRES_PASSWORD:  <set to the key 'postgres_password' in secret 'dev-db-secret'>  Optional: false
Mounts:
  /var/run/secrets/kubernetes.io/serviceaccount from default-token-4xjhx (ro)
...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Vérifions que le secret est bien utilisé dans notre pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl exec -it -n secrets pod-with-secret -- printenv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
HOSTNAME=pod-with-secret
TERM=xterm
POSTGRES_PASSWORD=password
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Notre secret se trouve bien en tant que variable d'environnement dans notre conteneur.

<hr>

## Secret file as a mount

1. Commençons par créer un secret à partir d'un fichier :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
echo "Iamasecret" > secret.txt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. On va donc créer un secret à partir de ce fichier :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl create secret generic -n secrets secret-file --from-file=secret.txt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*secret/secret-file created*


3. Définissons un pod, qui va monter ce secret en tant que volume :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
touch pod-with-volume-secret.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avec le contenu yaml suivant :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-volume-secret
  namespace: secrets
spec:
  containers:
  - name: pod-with-volume-secret
    image: redis
    volumeMounts:
    - name: secret-mount
      mountPath: "/tmp"
      readOnly: true
  volumes:
  - name: secret-mount
    secret:
      secretName: secret-file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Création du pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f pod-with-volume-secret.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*pod/pod-with-volume-secret created*


5. Nous pouvons faire un describe sur le pod pour voir qu'il utilise bien notre secret en tant que mount :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl describe pods -n secrets pod-with-volume-secret
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
...
Environment:    <none>
Mounts:
  /tmp from secret-mount (ro)
  /var/run/secrets/kubernetes.io/serviceaccount from default-token-4xjhx (ro)
...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Vérifions que le fichier a bien été monte sur le conteneur du pod :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl exec -it -n secrets pod-with-volume-secret -- cat /tmp/secret.txt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Iamasecret*

<hr>
## Kubeseal

1. Commençons par installer Kubeseal :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
curl -Lo kubeseal https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-linux-amd64
chmod +x kubeseal
sudo mv kubeseal /usr/local/bin/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Vérifions son installation :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubeseal --version

kubeseal version: v0.16.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Nous allons également installer l'opérateur via helm :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install --namespace kube-system sealed-secrets stable/sealed-secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}

NAME: sealed-secrets
LAST DEPLOYED: Sun Nov  1 10:18:33 2020
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
You should now be able to create sealed secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. Nous allons maintenant créer un secret :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl create secret generic -n secrets secret-example --dry-run --from-literal=secret=value -o yaml > secret-example.yaml

cat secret-example.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
data:
  secret: dmFsdWU=
kind: Secret
metadata:
  creationTimestamp: null
  name: sealed-secret-example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Et un SealedSecret à partir de ce secret :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubeseal --controller-name=sealed-secrets --controller-namespace=kube-system --format yaml <secret-example.yaml > sealed-secret-example.yaml

cat sealed-secret-example.yaml

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  creationTimestamp: null
  name: secret-example
  namespace: secrets
spec:
  encryptedData:
    secret: AgBy3DUDSGCwPLFOJ+jYp1wm1Wqf9PlCFLvIdUDPMdSr0tBIniBLNBpQbdZ+bqP6Tq7zBhDuJz4hNq5qchgfHXyKb6qxhSP30BuquSBHboO+19NHMEG6GOYT1TatHJwUVFlzGtqHcIRFwwEOZpJs9FRByYMf4jSbfu1Lb9u1E1Q49I3Ycw+LprqSZG4rZXtnBL+d6R1iO9OKsx6uQ3fklSYRyYuNWCrqGPYINcX9pcShvJHa8N30H6xZT8jrTpp+UPNXQTI3iaBHxHMTcc5jQCcduOp5Wgbm4G8OEr1Pd4fiNCb7QBAuiGLQa81RhdN887cifdv6mweDLnsRJk09fWGIyTXTezgCYnpsBQv0RFk/EEFiL7pm7w6zMHjp+ldy8NwonoJ8DL6mXFM2otdstGiDayoELrr47MEMp+Y4VVvbQai2YufUKdbF0/unBeB0BRMCMHYgqkCoKG5UPaekIVaYSPjUvT69WjY6DJnFoMz8uVtTqIaCpFAZ8Lm0G3cpfko3rwUGDefmVi4E8eLmcLn3t8KSdzkY5TLP+s58LFjFeDPz+OWvxnJ+1NmOig4OgzhItC0ngtulwhY2lXbuLgNhkjTXHTqRlCF4PXu/vcYHFhq4sBp+bTCvVsJYJTBpkNNCefT51KMTIg+xqOWC73/FqFwujJ4JAue4N99Fvh+7qbEYEw5sPPv6CmwuO0oVzNv52bjBRQ==
  template:
    metadata:
      creationTimestamp: null
      name: secret-example
      namespace: secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

6. Nous pouvons créer notre secret à partir de notre Sealed Secret :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -f sealed-secret-example.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*sealedsecret.bitnami.com/secret-example created*


7. Nous pouvons voir qu'un Sealed Secret a été créé :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get sealedsecrets -n secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME             AGE
secret-example   25s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

8. Ainsi qu'un Secret à partir de notre Sealed Secret :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get secrets -n secrets secret-example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME                  TYPE                                  DATA   AGE
secret-example        Opaque                                1      2m13s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

## Clean up

Supprimons les différents objets créés par ces exercices :

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -f .
kubectl delete secret secret-file -n secrets
kubectl delete secret dev-db-secret -n secrets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<hr>

