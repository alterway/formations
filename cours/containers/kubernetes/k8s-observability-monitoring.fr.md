# Kubernetes : Observabilité et monitoring

### Sondes : Readiness and Liveness

- Permettent à Kubernetes de sonder l'état d'un pod et d'agir en conséquence
- 2 types de sonde : Readiness et Liveness
- 3 manières de sonder :
  - TCP : ping TCP sur un port donné
  - HTTP: http GET sur une url donnée
  - Command: Exécute une commande dans le conteneur

### Sondes : Readiness

- Gère le trafic à destination du pod
- Un pod avec une sonde readiness _NotReady_ ne reçoit aucun trafic
- Permet d'attendre que le service dans le conteneur soit prêt avant de router du trafic
- Un pod _Ready_ est ensuite enregistrer dans les _endpoints_ du service associé

### Sondes : Liveness

- Gère le redémarrage du conteneur en cas d'incident
- Un pod avec une sonde liveness sans succès est redémarré au bout d'un intervalle défini
- Permet de redémarrer automatiquement les pods "tombés" en erreur

### Sondes : Exemple

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
    - name: goproxy
      image: k8s.gcr.io/goproxy:0.1
      ports:
        - containerPort: 8080
      readinessProbe:
        tcpSocket:
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 10
      livenessProbe:
        tcpSocket:
          port: 8080
        initialDelaySeconds: 15
        periodSeconds: 20
```
