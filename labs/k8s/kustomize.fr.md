# Kustomize

<hr>

Machine : **master**

<hr>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
mkdir -p kustomize/k8s/base
cd kustomize/k8s/base
kubectl create namespace kustomize
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Installation de kustomize

<https://kubectl.docs.kubernetes.io/installation/kustomize/>

Choisissez !

### Structure à Créer

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
.
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    └── prod
        ├── custom-env.yaml
        ├── database-secret.yaml
        ├── kustomization.yaml
        └── replica-and-rollout-strategy.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#### Contenu de `base/deployment.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  selector:
    matchLabels:
      app: sl-demo-app
  template:
    metadata:
      labels:
        app: sl-demo-app
    spec:
      containers:
      - name: app
        image: nginx:1.19.9
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Contenu de `base/service.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: v1
kind: Service
metadata:
  name: sl-demo-app
spec:
  ports:
    - name: http
      port: 8080
      targetPort: 80
  selector:
    app: sl-demo-app
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



#### Contenu de `base/kustomization.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - service.yaml
  - deployment.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Lancement initial

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl apply -k k8s/base

kubectl get  all -l app=sl-demo-app
kubectl get deploy 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh}
NAME                              READY   STATUS    RESTARTS   AGE
pod/sl-demo-app-bb6494cc6-sd6k7   1/1     Running   0          6m42s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/sl-demo-app   1/1     1            1           6m42s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/sl-demo-app-bb6494cc6   1         1         1       6m42s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Création de l'overlay de production (prod)

#### Contenu du fichier `overlays/prod/replica-and-rollout-strategy.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}

apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  replicas: 10
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Contenu du fichier `overlays/prod/database-secret.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: "DB_PASSWORD"
          valueFrom:
            secretKeyRef:
              name: sl-demo-app
              key: db-password
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#### Contenu du fichier `overlays/prod/custom-env.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sl-demo-app
spec:
  template:
    spec:
      containers:
        - name: app # (1)
          env:
            - name: CUSTOM_ENV_VARIABLE
              value: Value defined by Kustomize ❤️
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Contenu du fichier `overlays/prod/kustomization.yaml`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.yaml .numberLines}
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
commonLabels:
    caas.fr/environment: "prod"
bases:
- ../../base

patchesStrategicMerge:
- custom-env.yaml
- replica-and-rollout-strategy.yaml
- database-secret.yaml

secretGenerator:
- literals:
  - db-password=12345
  name: sl-demo-app
  type: Opaque

images:
- name: nginx
  newName: nginx
  newTag: 1.21.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Lancement overlay prod

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl delete -k k8s/base
kubectl apply -k k8s/overlays/prod

kubectl get  all -l caas.fr/environment=prod
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



<hr>
