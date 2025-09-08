
```yaml
# ============================================================
# ETAPE 1 : Namespace, ResourceQuota, LimitRange, ConfigMap, Secret
# ============================================================

apiVersion: v1
kind: Namespace
metadata:
  name: bookstore
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: bookstore-quota
  namespace: bookstore
spec:
  hard:
    pods: "15"
    services: "10"
    persistentvolumeclaims: "5"
    requests.cpu: "6"
    requests.memory: 12Gi
    limits.cpu: "12"
    limits.memory: 24Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: bookstore-limitrange
  namespace: bookstore
spec:
  limits:
  - type: Container
    defaultRequest:
      cpu: "100m"
      memory: 128Mi
    default:
      cpu: "500m"
      memory: 512Mi
    max:
      cpu: "2"
      memory: 2Gi
    min:
      cpu: "50m"
      memory: 64Mi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: bookstore-config
  namespace: bookstore
data:
  FRONTEND_TITLE: "BookStore Demo"
  API_URL: "http://bookstore-api:8000"
---
apiVersion: v1
kind: Secret
metadata:
  name: bookstore-secret
  namespace: bookstore
type: Opaque
stringData:
  DB_USER: bookstore
  DB_PASSWORD: supersecret
  REDIS_PASSWORD: redissecret





# ============================================================
# ETAPE 2 : PostgreSQL StatefulSet + PVC
# ============================================================
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: bookstore
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: bookstore
spec:
  serviceName: "postgres"
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:16
        env:
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: bookstore-secret
              key: DB_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: bookstore-secret
              key: DB_PASSWORD
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: bookstore
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
    name: postgres

# ============================================================
# ETAPE 2b : Redis StatefulSet + PVC
# ============================================================
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: bookstore
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
  namespace: bookstore
spec:
  serviceName: "redis"
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7
        env:
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: bookstore-secret
              key: REDIS_PASSWORD
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 500Mi
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  namespace: bookstore
spec:
  clusterIP: None
  selector:
    app: redis
  ports:
  - port: 6379
    name: redis

# ============================================================
# ETAPE 2c : Backend API Deployment
# ============================================================
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bookstore-api
  namespace: bookstore
spec:
  replicas: 2
  selector:
    matchLabels:
      app: bookstore-api
  template:
    metadata:
      labels:
        app: bookstore-api
    spec:
      containers:
      - name: api
        image: tiangolo/uvicorn-gunicorn-fastapi:python3.11
        envFrom:
        - configMapRef:
            name: bookstore-config
        - secretRef:
            name: bookstore-secret
        ports:
        - containerPort: 8000

---
apiVersion: v1
kind: Service
metadata:
  name: bookstore-api
  namespace: bookstore
spec:
  selector:
    app: bookstore-api
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP

# ============================================================
# ETAPE 2d : Frontend Deployment
# ============================================================
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bookstore-frontend
  namespace: bookstore
spec:
  replicas: 2
  selector:
    matchLabels:
      app: bookstore-frontend
  template:
    metadata:
      labels:
        app: bookstore-frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.23
        envFrom:
        - configMapRef:
            name: bookstore-config
        ports:
        - containerPort: 80
        volumeMounts:
        - name: frontend-html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: frontend-html
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: bookstore-frontend
  namespace: bookstore
spec:
  selector:
    app: bookstore-frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP


# ============================================================
# ETAPE 3a : Ingress pour exposer le frontend
# ============================================================
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bookstore-ingress
  namespace: bookstore
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: bookstore.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: bookstore-frontend
            port:
              number: 80

# ============================================================
# ETAPE 3b : NetworkPolicy pour isoler le namespace
# ============================================================
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: bookstore-allow-internal
  namespace: bookstore
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector: {}
  policyTypes:
  - Ingress

# ============================================================
# ETAPE 3c : RBAC basique pour observer les pods
# ============================================================
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookstore-observer
  namespace: bookstore
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: bookstore
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods", "services", "events"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: bookstore
subjects:
- kind: ServiceAccount
  name: bookstore-observer
  namespace: bookstore
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io


# ============================================================
# ETAPE 4a : Job - Import de livres
# ============================================================
---
apiVersion: batch/v1
kind: Job
metadata:
  name: import-books-job
  namespace: bookstore
spec:
  template:
    spec:
      containers:
      - name: import-books
        image: busybox:1.36
        command: ["sh", "-c", "echo 'Import de livres terminé !' && sleep 5"]
      restartPolicy: Never
  backoffLimit: 2

# ============================================================
# ETAPE 4b : CronJob - Synchronisation quotidienne
# ============================================================
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-sync-cronjob
  namespace: bookstore
spec:
  schedule: "0 2 * * *"  # tous les jours à 2h du matin
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sync-books
            image: busybox:1.36
            command: ["sh", "-c", "echo 'Synchronisation quotidienne exécutée !'"]
          restartPolicy: OnFailure

# ============================================================
# ETAPE 4c : DaemonSet - Collecte des logs
# ============================================================
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
  namespace: bookstore
spec:
  selector:
    matchLabels:
      app: log-agent
  template:
    metadata:
      labels:
        app: log-agent
    spec:
      containers:
      - name: log-agent
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo $(date) - Log Agent actif; sleep 30; done"]


# ============================================================
# ETAPE 5a : HorizontalPodAutoscaler pour le backend API
# ============================================================
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bookstore-api-hpa
  namespace: bookstore
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: bookstore-api
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

# ============================================================
# ETAPE 5b : PodDisruptionBudget pour le frontend
# ============================================================
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: bookstore-frontend-pdb
  namespace: bookstore
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: bookstore-frontend

# ============================================================
# ETAPE 5c : Deployment avec Affinity/Anti-Affinity et NodeSelector
# ============================================================
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: affinity-demo
  namespace: bookstore
spec:
  replicas: 2
  selector:
    matchLabels:
      app: affinity-demo
  template:
    metadata:
      labels:
        app: affinity-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.23.10
        ports:
        - containerPort: 80
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - affinity-demo
            topologyKey: "kubernetes.io/hostname"
      nodeSelector:
        kubernetes.io/os: linux

# ============================================================
# ETAPE 5d : Pod avec Tolerations (noeud tainté)
# ============================================================
---
apiVersion: v1
kind: Pod
metadata:
  name: tolerant-pod
  namespace: bookstore
spec:
  tolerations:
  - key: "special"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sh", "-c", "echo 'Je tourne sur un noeud tainté !' && sleep 3600"]

# ============================================================
# ETAPE 6a : ServiceAccount et RBAC pour observer les Pods
# ============================================================
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: bookstore-observer-sa
  namespace: bookstore
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: bookstore-observer-role
rules:
- apiGroups: [""]
  resources: ["pods", "nodes", "events"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bookstore-observer-binding
subjects:
- kind: ServiceAccount
  name: bookstore-observer-sa
  namespace: bookstore
roleRef:
  kind: ClusterRole
  name: bookstore-observer-role
  apiGroup: rbac.authorization.k8s.io

# ============================================================
# ETAPE 6b : Pod observateur qui affiche Pods et Events
# ============================================================
---
apiVersion: v1
kind: Pod
metadata:
  name: observer-pod
  namespace: bookstore
spec:
  serviceAccountName: bookstore-observer-sa
  containers:
  - name: kubectl
    image: bitnami/kubectl:1.30
    command:
      - /bin/sh
      - -c
      - |
        echo "==== STREAMING PODS ET EVENTS ===="
        while true; do
          echo ">> PODS:"
          kubectl get pods -n bookstore -o wide
          echo ">> EVENTS:"
          kubectl get events -n bookstore --sort-by=.metadata.creationTimestamp | tail -n 5
          echo "===="
          sleep 20
        done

# ============================================================
# ETAPE 6c : ServiceMonitor (Prometheus Operator)
# ============================================================
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: bookstore-api-monitor
  namespace: bookstore
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: bookstore-api
  namespaceSelector:
    matchNames:
    - bookstore
  endpoints:
  - port: 8000
    interval: 30s

# ============================================================
# ETAPE 6d : Sidecar logs pour le frontend
# ============================================================
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend-with-logger
  namespace: bookstore
spec:
  containers:
  - name: frontend
    image: nginx:1.23
    ports:
    - containerPort: 80
  - name: log-sidecar
    image: busybox:1.36
    command: ["sh", "-c", "tail -n+1 -F /var/log/nginx/access.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  volumes:
  - name: logs
    emptyDir: {}


```


