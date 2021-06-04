# Monitoring

Machine : **master**

```bash
training@master$ mkdir monitoring
training@master$ cd monitoring
training@master$ kubectl create namespace monitoring
```

## Metric Server

1. Nous allons essayer d'obtenir les metrics pour les noeuds de notre cluster :

```bash
training@master$ kubectl top node

error: Metrics API not available
```

... Sans succès.

2. De meme, si nous souhaitons récupérer les metrics de nos pods, nous obtenons une erreur :

```bash
training@master$ kubectl top pod

error: Metrics API not available
```

Nous avons besoin d'installer un metrics server.

3. Nous allons creer un fichier metrics-server.yaml :

```bash
training@master$ touch metrics-server.yaml
```

Avec le contenu yaml suivant :

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:aggregated-metrics-reader
  labels:
    rbac.authorization.k8s.io/aggregate-to-view: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
rules:
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: apiregistration.k8s.io/v1beta1
kind: APIService
metadata:
  name: v1beta1.metrics.k8s.io
spec:
  service:
    name: metrics-server
    namespace: kube-system
  group: metrics.k8s.io
  version: v1beta1
  insecureSkipTLSVerify: true
  groupPriorityMinimum: 100
  versionPriority: 100
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
      containers:
      - name: metrics-server
        image: k8s.gcr.io/metrics-server/metrics-server:v0.3.7
        imagePullPolicy: IfNotPresent
        args:
          - --cert-dir=/tmp
          - --secure-port=4443
          - --kubelet-insecure-tls
          - --kubelet-preferred-address-types=InternalIP
        ports:
        - name: main-port
          containerPort: 4443
          protocol: TCP
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - name: tmp-dir
          mountPath: /tmp
      nodeSelector:
        kubernetes.io/os: linux
---
apiVersion: v1
kind: Service
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    kubernetes.io/name: "Metrics-server"
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    k8s-app: metrics-server
  ports:
  - port: 443
    protocol: TCP
    targetPort: main-port
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  - configmaps
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
```

4. Nous pouvons donc déployer notre metrics-server :

```bash
training@master$ kubectl apply -f metrics-server.yaml

clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
Warning: apiregistration.k8s.io/v1beta1 APIService is deprecated in v1.19+, unavailable in v1.22+; use apiregistration.k8s.io/v1 APIService
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
serviceaccount/metrics-server created
deployment.apps/metrics-server created
service/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
```

5. Après environ 1 minute, nous pouvons refaire notre top node :

```bash
training@master$ kubectl top node

NAME     CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master   180m         9%     1249Mi          15%       
worker   47m          2%     818Mi           10%
```

6. Nous obtenons bien les consommations CPU/RAM pour chaque noeud. Voyons voir maintenant pour les consommations de ressources par nos pods :

```bash
training@master$ kubectl top pod -A

NAMESPACE     NAME                              CPU(cores)   MEMORY(bytes)   
kube-system   coredns-f9fd979d6-9kb87           4m           12Mi            
kube-system   coredns-f9fd979d6-tl95z           3m           12Mi            
kube-system   etcd-master                       20m          41Mi            
kube-system   kube-apiserver-master             48m          294Mi           
kube-system   kube-controller-manager-master    16m          47Mi            
kube-system   kube-proxy-8dvrj                  1m           15Mi            
kube-system   kube-proxy-ll8tb                  1m           15Mi            
kube-system   kube-scheduler-master             4m           21Mi            
kube-system   metrics-server-75f98fdbd5-2lp87   1m           12Mi            
kube-system   weave-net-c4b7d                   2m           58Mi            
kube-system   weave-net-zfqt6                   2m           62Mi
```

Parfait !

## Prometheus/Grafana

Nous allons déployer une stack de monitoring basée sur Prometheus et Grafana via Helm.

1. Commencons par creer le fichier values.yaml pour prometheus :

```bash
training@master$ touch prometheus-values.yaml
```

Avec le contenu yaml suivant :

```yaml
alertmanager:
  persistentVolume:
    storageClass: "openebs-custom-sc"
server:
  persistentVolume:
    storageClass: "openebs-custom-sc"
```

2. Nous pouvons donc installer Prometheus via Helm :

```bash
training@master$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
training@master$ helm install prometheus prometheus-community/prometheus --values prometheus-values.yaml --namespace monitoring

NAME: prometheus
LAST DEPLOYED: Sun Nov  1 16:16:50 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.monitoring.svc.cluster.local
...
```

3. Nous pouvons voir les resources creees de la façon suivante :

```bash
training@master$ kubectl get all -n monitoring
```

4. Nous pouvons également remarquer que deux PV ont ete créés pour les PVC de Prometheus et AlertManager :

```bash
training@master$ kubectl get pvc -n monitoring

NAME                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
prometheus-alertmanager   Bound    pvc-341a1d92-74b4-4ce4-8ad2-8edaf94025c8   2Gi        RWO            openebs-custom-sc   57s
prometheus-server         Bound    pvc-d7f3ac24-cb5c-4702-a501-5d8b85bec8e2   8Gi        RWO            openebs-custom-sc   57s
```

5. Nous allons maintenant passer à l'installation de Grafana. Comme pour Prometheus, nous allons créer un fichier values.yaml pour configurer notre installation :

```bash
training@master$ touch grafana-values.yaml
```

Avec le contenu yaml suivant :

```yaml
persistence:
  enabled: true
  storageClassName: "openebs-custom-sc"
```

5. Nous pouvons donc passer à l'installation de Grafana :

```bash
training@master$ helm repo add grafana https://grafana.github.io/helm-charts
training@master$ helm install grafana grafana/grafana --values grafana-values.yaml --namespace monitoring

NAME: grafana
LAST DEPLOYED: Sun Nov  1 16:26:28 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
...
```

6. Nous pouvons voir les ressources creees par Grafana de la façon suivante :

```bash
training@master$ kubectl get all -n monitoring
```

7. Nous allons faire un port-forward pour se connecter à notre serveur Prometheus :

```bash
training@master$ kubectl --namespace monitoring port-forward --address 0.0.0.0 service/prometheus-server 8080:80

Forwarding from 0.0.0.0:8080 -> 9090
```

8. De même pour Grafana :

```bash
training@master$ kubectl --namespace monitoring port-forward --address 0.0.0.0 service/grafana 8081:80

Forwarding from 0.0.0.0:8081 -> 3000
```

9. Récuperer le mot de passe admin de Grafana :

```bash
training@master$ kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

LP7RithkvOulZE1Yhj95obTSuH4e8qUffsuCaBAR
```

10. Dans Grafana, aller dans Configuration -> Data Sources -> Add data source -> Prometheus, et renseinger "prometheus-server" dans URL :

![](images/grafana2.png)

11. Toujours dans Grafana, aller dans "+" -> Import -> Entrer "6417" dans ID -> Choisir le datasource promethus créé ci dessus :

![](images/grafana3.png)

![](images/grafana4.png)

12. Enjoy :)

![](images/grafana5.png)
