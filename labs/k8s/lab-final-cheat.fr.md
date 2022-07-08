<hr>
# Solutions pour le lab

<hr>

Troubleshooting Deployments

Fixes:

Edited the labels in the Pod spec to match the Deployment selector.

Set the replica count to 1. 0 is perfectly valid, you may want to save compute power when an app's not in use, but it's not a great default :)

Reduced resource requests. Large numbers are valid, but if there are no nodes in the cluster which can provide the power, the Pod stays pending.

Fixed the image name. ErrImagePull tells you the image name is incorrect or your Pod doesn't have permission to pull a private image.

Fix typo in the container command. RunContainerError tells you Kubernetes can't get the container running - you'll see the error in the Pod logs or description, depending on the failure.

Fix readiness probe. It's set to check a TCP socket is listening, but it's using the wrong port. 8020 is the Service port, the app in the container uses port 80.

Fix liveness probe. It's set to check an HTTP endpoint, but /healthy doesn't exist - a 404 response means a failed probe.

Troubleshooting Services

Fixes:

Fixed the target port for the NodePort Service, 8020 is not valid.

Edited the Service selector to match the labels in the Pod spec. If there are no endpoints, that means there are no matching Pods.

Fixed the target port name in the Service spec to match the container spec. Using names instead of port numbers is more flexible, but if the names don't match you won't see an error - just an empty endpoint list.




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