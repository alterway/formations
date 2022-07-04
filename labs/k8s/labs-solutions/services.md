# Services

### NodePort

```bash
kubectl expose deployment nginx-deployment --type=NodePort --port=30000 --target-port=80 --name svc-nginx
```

ou

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-deployment
  name: svc-nginx
 
spec:
  ports:
  - port: 30000
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-deployment
  type: NodePort
```


<hr>
