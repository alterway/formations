# Daemonset

```bash
kubectl create deploy prometheus-daemonset --port=9100 --image=prom/node-exporter --dry-run=client -o yaml | \
    sed '/null\|{}\|replicas/d;/status/,$d;s/Deployment/DaemonSet/g' > node-exporter-ds.yaml

kubectl apply -f node-exporter-ds.yaml

kubectl get ds
```

ou

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  annotations:
  labels:
    app: prometheus-daemonset
  name: prometheus-daemonset
spec:
  selector:
    matchLabels:
      app: prometheus-daemonset
  template:
    metadata:
      labels:
        app: prometheus-daemonset
    spec:
      containers:
      - image: prom/node-exporter
        imagePullPolicy: Always
        name: node-exporter
        ports:
        - containerPort: 9100
          protocol: TCP
```

### Node affinity / NodeSelector

Pour faire simple, ajouter une Taint à un nœud revient à appliquer une mauvaise odeur sur ce nœud. Seuls les Pods qui tolèrent cette mauvaise odeur pourront être exécutés sur le nœud.

Tout comme les Labels, une ou plusieurs Taints peuvent être appliquées à un nœud; cela signifie que le nœud ne doit accepter aucun pod qui ne tolère pas l’ensemble de ces Taints.

Les Taints sont de la forme: key=value:Effect.

Signification du champ “Effects”
Le champ “Effects” peut prendre les trois valeurs ci-dessous:

`NoSchedule` - L’exécution des pods non tolérants à la Taint ne sera pas planifiée sur ce nœud. Il s’agit d’une contrainte forte pour le Scheduler Kubernetes.

`PreferNoSchedule` - Le Scheduler Kubernetes évitera de placer un Pod qui ne tolère pas la Taint sur le nœud, mais ce n’est pas obligatoire. Il s’agit d’une contrainte douce pour le Scheduler Kubernetes.

`NoExecute` - Le pod sera expulsé du nœud (s’il est déjà en cours d’exécution sur le nœud) ou ne sera pas planifié sur le nœud (s’il n’est pas encore exécuté sur le nœud). Il s’agit d’une contrainte forte pour le Scheduler Kubernetes.

### Gestion des Taints

```bash 
kubectl get nodes master -o jsonpath="{.spec.taints}"
```

La Taint nommée node-role.kubernetes.io/master="":NoSchedule a été apposée par kubeadm  sur le noeud maître du cluster. Elle permettra au Scheduler de ne pas planifier des Pods classiques sur le noeud maître du cluster et de réserver celui-ci aux Pods systèmes tels que le Serveur d'API, le Scheduler, le Controller ou encore le kube-proxy et le plugin CNI.

Il est possible de supprimer cette Taint très simplement, afin de permettre l’exécution de Pods applicatifs sur le noeud maître. Cette opération est déconseillée pour la production mais peut-être utile dans le cadre d’un cluster Kubernetes de développement par exemple.



```bash

kubectl taint node master node-role.kubernetes.io/master-

```

Pour remettre la Taint en place:

```bash

kubectl taint node master node-role.kubernetes.io/master="":NoSchedule

```


### Première solution

```bash

kubectl label node master node-exporter=true
kubectl label node node1 node-exporter=true

```

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  annotations:
  labels:
    app: prometheus-daemonset
  name: prometheus-daemonset
spec:
  selector:
    matchLabels:
      app: prometheus-daemonset
  template:
    metadata:
      labels:
        app: prometheus-daemonset
    spec:
      nodeSelector:
         node-exporter: "true"
      tolerations:
      - key: "node-role.kubernetes.io/master"
        effect: NoSchedule
      containers:
      - image: prom/node-exporter
        imagePullPolicy: Always
        name: node-exporter
        ports:
        - containerPort: 9100
          protocol: TCP
```


