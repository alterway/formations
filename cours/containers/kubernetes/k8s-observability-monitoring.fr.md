# KUBERNETES : Observabilité et Monitoring

### Sondes : Readiness, Liveness et StartUP

- Permettent à Kubernetes de sonder l'état d'un pod et d'agir en conséquence
- 3 types de sonde : Readiness, Liveness, StartUp
- 4 manières de sonder :
  - TCP : ping TCP sur un port donné
  - HTTP: http GET sur une url donnée
  - Command: Exécute une commande dans le conteneur
  - grpc : standard GRPC Health Checking Protocol

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


### Différents types de sondes : `httpGet`

- Effectuer une requête HTTP GET vers le conteneur
- La requête sera effectuée par la Kubelet
    (ne nécessite pas de binaires supplémentaires dans l'image du conteneur)
- Le paramètre port doit être spécifié
- Les paramètres `path` et `httpHeaders` supplémentaires peuvent être spécifiés de manière optionnelle
- Kubernetes utilise le code de statut HTTP de la réponse :
    - 200-399 = succès
    - tout autre code = échec


    


### Différents types de sondes : `exec`

- Exécute un programme arbitraire à l'intérieur du conteneur
    (comme avec kubectl exec ou docker exec)
- Le programme doit être disponible dans l'image du conteneur
- Kubernetes utilise le code de sortie du programme
     (convention UNIX standard : 0 = succès, toute autre valeur = échec)


     

### Différents types de sondes : `tcpSocket`

- Kubernetes vérifie si le port TCP indiqué accepte des connexions
- Il n'y a pas de vérification supplémentaire
    🫥 Il est tout à fait possible qu'un processus soit défaillant, tout en continuant à accepter des connexions TCP !


### Différents types de sondes : `grpc`

- Disponible en version bêta depuis Kubernetes 1.24
- Exploite le protocole standard GRPC Health Checking

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-grpc
spec:
  containers:
  - name: agnhost
    image: registry.k8s.io/e2e-test-images/agnhost:2.35
    command: ["/agnhost", "grpc-health-checking"]
    ports:
    - containerPort: 5000
    - containerPort: 8080
    readinessProbe:
      grpc:
        port: 5000
```

Plus d'informations : <https://kubernetes.io/blog/2022/05/13/grpc-probes-now-in-beta/>



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

     


### Sondes : gérer les délais et seuils 

- **initialDelaySeconds**

    - Une probe peut avoir un paramètre `initialDelaySeconds` (défaut : 0).
    - Kubernetes attendra ce délai avant d'exécuter le probe pour la première fois.
    - Il est généralement préférable d'utiliser un startupProbe à la place.
      (mais ce paramètre existait avant l'implémentation des startup probes)

- temps et seuils

     - Les probes sont exécutées à intervalles de periodSeconds (défaut : 10).
     - Le délai d'expiration d'un probe est défini avec timeoutSeconds (défaut : 1).
     - Si une probe prend plus de temps que cela, il est considéré comme un ÉCHEC.
     - Pour les probes de liveness et de startup, cela entraîne la terminaison et le redémarrage du conteneur.
     - Une probe est considérée comme réussi après successThreshold succès (défaut : 1).
     - Une probe est considérée comme en échec après failureThreshold échecs (défaut : 3).
     - Tous ces paramètres peuvent être définis indépendamment pour chaque probe. 

     



### Sondes : Startup Probe Bonnes pratiques

- Si une startupProbe échoue, Kubernetes redémarre le conteneur correspondant.
     
- En d'autres termes : avec les paramètres par défaut, le conteneur **doit** démarrer en **30 secondes**.
     (failureThreshold × periodSeconds)
         
- C'est pourquoi il faut presque toujours ajuster les paramètres d'une startupProbe.
      (spécifiquement, son failureThreshold)
          
- Parfois, il est plus facile d'utiliser une readinessProbe à la place.(voir la prochaine diapositive pour plus de détails)
    
### Sondes : Liveness Probe Bonnes pratiques

- N'utilisez pas de probes de liveness pour des problèmes qui ne peuvent pas être résolus par un redémarrage.
   Sinon, les pods redémarrent sans raison, créant une charge inutile.
     
- Ne dépendez pas d'autres services au sein d'une probe de liveness.
     Sinon, Possibilités d'échecs en cascade.(exemple : probe de liveness d'un serveur web qui effectue des requêtes vers une base de données)Assurez-vous que les probes de liveness répondent rapidement.
       
- Le délai d'expiration par défaut des probes est de 1 seconde (cela peut être ajusté).
     
- Si la probe prend plus de temps que cela, il finira par provoquer un redémarrage.

- Une startupProbe nécessite généralement de modifier le `failureThreshold`.
  
- Une `startupProbe` nécessite généralement également une `readinessProbe`. 
  
- Une seule `readinessProbe` peut remplir les deux rôles.


### Sondes : Readiness Probe Bonnes pratiques

- Presque toujours bénéfique.
- Sauf pour :
    - les service web qui n'ont pas de route dédiée "health" ou "ping".
    - toutes les requêtes sont "coûteuses" (par exemple, nombreux appels externes).

     

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


