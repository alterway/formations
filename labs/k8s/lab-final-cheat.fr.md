<hr>
# Solutions pour le lab
<hr>

Troubleshooting Deployments

Fix:

**Deployments**

- Labels dans les spec du pod pour le rattachement au deploy

- Replicas à 0 >> 1

- Limits / Requests trop élévée

- Nom de l'image >> aller voir sur le hub docker

- Command au niveau de conteneur avec typo

- Readiness probe mauvais port

- Liveness /healthy >> /health


**Services**

- target port 8020 invalide

- Service pod selector invalide

- Service port name invalide



```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pi-web
  labels:
    k8s.alterwaylabs.fr: troubleshooting
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pi-web
  template:
    metadata:
      labels:
        app: pi-web
    spec:
      containers:
        - image: kiamol/ch05-pi
          command: ["dotnet", "Pi.Web.dll", "-m", "web"]
          name: web
          ports:
            - containerPort: 80
              name: http
          resources:
            limits:
              cpu: "0.5"            
              memory: "1Gi"
          readinessProbe:
            tcpSocket:
              port: 80
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 80
            periodSeconds: 30
            failureThreshold: 1


---

apiVersion: v1
kind: Service
metadata:
  name: pi-np
  labels:
    k8s.alterwaylabs.fr: troubleshooting
spec:
  selector:
    app: pi-web
  ports:
    - name: http
      port: 8020
      targetPort: http
      nodePort: 30020
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  name: pi-lb
  labels:
    k8s.alterwaylabs.fr: troubleshooting
spec:
  selector:
    app: pi-web
  ports:
    - name: http
      port: 8020
      targetPort: http
  type: LoadBalancer