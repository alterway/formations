# Kubernetes : Architecture

### Kubernetes : Composants

- Kubernetes est écrit en Go, compilé statiquement.

- Un ensemble de binaires sans dépendances

- Faciles à conteneuriser et à packager

- Peut se déployer uniquement avec des conteneurs sans dépendances d'OS

### Kubernetes : Composants

- kubelet : Service "agent" fonctionnant sur tous les nœuds et assure le fonctionnement des autres services
- kube-apiserver : API server qui permet la configuration d'objet Kubernetes (Pods, Service, Replication Controller, etc.)
- kube-proxy : Permet le forwarding TCP/UDP et le load balancing entre les services et les backend (Pods)
- kube-scheduler : Implémente les fonctionnalités de scheduling
- kube-controller-manager : Responsable de l'état du cluster, boucle infinie qui régule l'état du cluster afin d'atteindre un état désiré
- kubectl : Client qui permet de piloter un cluster Kubernetes

### Kubernetes : kubelet

- Service principal de Kubernetes

- Permet à Kubernetes de s'auto configurer :
    - Surveille un dossier contenant les *manifests* (fichiers YAML des différents composant de K8s).
    - Applique les modifications si besoin (upgrade, rollback).

- Surveille l'état des services du cluster via l'API server (*kube-apiserver*).

- Dossier de manifest sur un noeud master :

```
ls /etc/kubernetes/manifests/
kube-apiserver.yaml  kube-controller-manager.yaml  kube-proxy.yaml  kube-scheduler.yaml  policy-controller.yaml
```

### Kubernetes : kubelet

- Exemple du manifest *kube-proxy* :

```
apiVersion: v1
kind: Pod
metadata:
  name: kube-proxy
  namespace: kube-system
  annotations:
    rkt.alpha.kubernetes.io/stage1-name-override: coreos.com/rkt/stage1-fly
spec:
  hostNetwork: true
  containers:
  - name: kube-proxy
    image: quay.io/coreos/hyperkube:v1.3.6_coreos.0
    command:
    - /hyperkube
    - proxy
    - --master=http://127.0.0.1:8080
    - --proxy-mode=iptables
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  volumes:
  - hostPath:
      path: /usr/share/ca-certificates
    name: ssl-certs-host
```

### Kuberntes : kube-apiserver

- Les configurations d'objets (Pods, Service, RC, etc.) se font via l'API server

- Un point d'accès à l'état du cluster aux autres composants via une API REST

- Tous les composants sont reliés à l'API server

### Kubernetes : kube-scheduler

- Planifie les ressources sur le cluster

- En fonction de règles implicites (CPU, RAM, stockage disponible, etc.)

- En fonction de règles explicites (règles d'affinité et anti-affinité, labels, etc.)

### Kubernetes : kube-proxy

- Responsable de la publication de services

- Utilise *iptables*

- Route les paquets à destination des PODs et réalise le load balancing TCP/UDP

### Kubernetes : kube-controller-manager

- Boucle infinie qui contrôle l'état d'un cluster

- Effectue des opérations pour atteindre un état donné

- De base dans Kubernetes : replication controller, endpoints controller, namespace controller et serviceaccounts controller

### Kubernetes : network-policy-controller

- Implémente l'objet NetworkPolicy

- Contrôle la communication entre les PODs

- Externe à Kubernetes et implémenté par la solution de Networking choisie :
    - OpenShift
    - OpenContrail
    - Romana
    - Calico

### kubernetes : Conclusion

