# KUBERNETES : Observabilité et Monitoring

### Sondes : Readiness, Liveness et StartUP

- Permettent à Kubernetes de sonder l'état d'un pod et d'agir en conséquence
- 3 types de sonde : Readiness, Liveness, StartUp
- 3 manières de sonder :
  - TCP : ping TCP sur un port donné
  - HTTP: http GET sur une url donnée
  - Command: Exécute une commande dans le conteneur

### Sondes : Readiness

- Gère le trafic à destination du pod
- Un pod avec une sonde readiness *NotReady* ne reçoit aucun trafic
- Permet d'attendre que le service dans le conteneur soit prêt avant de router du trafic
- Un pod *Ready* est ensuite enregistrer dans les *endpoints* du service associé

### Sondes : Liveness

- Gère le redémarrage du conteneur en cas d'incident
- Un pod avec une sonde liveness sans succès est redémarré au bout d'un intervalle défini
- Permet de redémarrer automatiquement les pods "tombés" en erreur

### Sondes : Startup

- Disponible en bêta à partir de la version 1.18
- Utiles pour les applications qui ont un démarrage lent
- Permet de ne pas augmenter les `initialDelaySeconds` des Readiness et Liveness
- Elle sert à savoir quand l'application est prête
- Les 3 sondes combinées permet de gérer très finement la disponibilité de l'application


### Sondes : Exemples

```yaml
aapiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: my-app-container
    image: my-image
    ports:
    - containerPort: 8080
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Authorization
          value: Bearer my-token
      initialDelaySeconds: 15
      periodSeconds: 5
      timeoutSeconds: 1
      failureThreshold: 3
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 2
      failureThreshold: 5
    startupProbe:
      exec:
        command:
        - cat /etc/nginx/nginx.conf
      initialDelaySeconds: 10
      timeoutSeconds: 5
```


### Sondes : Exemple Kubernetes API

L'API Kubernetes inclut également des points de terminaison de contrôle d'état : healthz (obsolète), readyz, livez.

```console
kubectl get --raw='/readyz?verbose'
```
### Sondes : Exemple Kubernetes API


Point de terminaison **readyz**

```console
[+]ping ok
[+]log ok
[+]etcd ok
[+]informer-sync ok
[+]poststarthook/start-kube-apiserver-admission-initializer ok
[+]poststarthook/generic-apiserver-start-informers ok
[+]poststarthook/priority-and-fairness-config-consumer ok
[+]poststarthook/priority-and-fairness-filter ok
[+]poststarthook/start-apiextensions-informers ok
[+]poststarthook/start-apiextensions-controllers ok
[+]poststarthook/crd-informer-synced ok
[+]poststarthook/bootstrap-controller ok
[+]poststarthook/rbac/bootstrap-roles ok
[+]poststarthook/scheduling/bootstrap-system-priority-classes ok
[+]poststarthook/priority-and-fairness-config-producer ok
[+]poststarthook/start-cluster-authentication-info-controller ok
[+]poststarthook/aggregator-reload-proxy-client-cert ok
[+]poststarthook/start-kube-aggregator-informers ok
[+]poststarthook/apiservice-registration-controller ok
[+]poststarthook/apiservice-status-available-controller ok
[+]poststarthook/kube-apiserver-autoregistration ok
[+]autoregister-completion ok
[+]poststarthook/apiservice-openapi-controller ok
[+]shutdown ok
readyz check passed
```


### Sondes : Exemple Kubernetes API

 
 Point de terminaison **livez**

```console`
kubectl get --raw='/livez?verbose'
```

### Sondes : Exemple Kubernetes API

```console
+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-kube-apiserver-admission-initializer ok
[+]poststarthook/generic-apiserver-start-informers ok
[+]poststarthook/priority-and-fairness-config-consumer ok
[+]poststarthook/priority-and-fairness-filter ok
[+]poststarthook/start-apiextensions-informers ok
[+]poststarthook/start-apiextensions-controllers ok
[+]poststarthook/crd-informer-synced ok
[+]poststarthook/bootstrap-controller ok
[+]poststarthook/rbac/bootstrap-roles ok
[+]poststarthook/scheduling/bootstrap-system-priority-classes ok
[+]poststarthook/priority-and-fairness-config-producer ok
[+]poststarthook/start-cluster-authentication-info-controller ok
[+]poststarthook/aggregator-reload-proxy-client-cert ok
[+]poststarthook/start-kube-aggregator-informers ok
[+]poststarthook/apiservice-registration-controller ok
[+]poststarthook/apiservice-status-available-controller ok
[+]poststarthook/kube-apiserver-autoregistration ok
[+]autoregister-completion ok
[+]poststarthook/apiservice-openapi-controller ok
livez check passed
```
