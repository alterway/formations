### Exercice 29/30 : Refus de création de Pod par restriction sur les paramètres noyau (`SysctlForbidden`) (Niveau : Ultra compliqué / Expert)

* **Objectif :** Diagnostiquer et corriger un échec de déploiement causé par la tentative de configuration d'un paramètre noyau Linux non sécurisé (*unsafe sysctl*) dans le `securityContext` d'un Pod.
* **Contexte :** Pour optimiser les performances d'un proxy NGINX gérant un volume important de connexions HTTP simultanées, un ingénieur système a ajouté des paramètres de tuning réseau Linux (`sysctls`) dans la spécification du Pod. Le Pod refuse de se lancer et le contrôleur émet une erreur de validation.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : "net.ipv4.tcp_tw_reuse" est classé comme "unsafe sysctl" dans Kubernetes.
# Sans autorisation explicite au niveau du Kubelet hôte (--allowed-unsafe-sysctls), l'API Server/Kubelet rejette le Pod avec une erreur SysctlForbidden.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: high-traffic-proxy
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: high-traffic-proxy
  template:
    metadata:
      labels:
        app: high-traffic-proxy
    spec:
      securityContext:
        sysctls:
        # Safe sysctl (autorisé par défaut depuis Kubernetes 1.22+)
        - name: net.core.somaxconn
          value: "4096"
        # ERREUR : Unsafe sysctl non autorisé par défaut par le Kubelet du nœud
        - name: net.ipv4.tcp_tw_reuse
          value: "1"
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: high-traffic-proxy
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: high-traffic-proxy
  template:
    metadata:
      labels:
        app: high-traffic-proxy
    spec:
      securityContext:
        sysctls:
        # CORRECTION : Conservation uniquement du paramètre "safe" (net.core.somaxconn).
        # Les paramètres unsafe doivent être retirés du manifeste Pod et appliqués via un DaemonSet privilégié ou directement au niveau de l'OS du nœud hôte.
        - name: net.core.somaxconn
          value: "4096"
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80

```

**Démarche de résolution pour l'apprenant :**

1. Inspecter les Pods : `kubectl get pods` (statut `SysctlForbidden` ou `CreateContainerConfigError`).
2. Examiner la raison du rejet via les événements : `kubectl describe pod <nom-du-pod>`.
3. Analyser le message d'erreur émis par le Kubelet : `Error: sysctl "net.ipv4.tcp_tw_reuse" is not whitelisted`.
4. Consulter la documentation des paramètres `sysctl` dans Kubernetes et faire la distinction entre :
* **Safe sysctls** (ex. `net.core.somaxconn`, `net.ipv4.ip_local_port_range` dans les namespaces réseau isolés).
* **Unsafe sysctls** (ex. `net.ipv4.tcp_tw_reuse`), qui sont bloqués sauf si l'administrateur du cluster modifie la configuration du Kubelet avec le drapeau `--allowed-unsafe-sysctls`.


5. Retirer la directive `net.ipv4.tcp_tw_reuse` du bloc `securityContext.sysctls` pour autoriser le démarrage immédiat du Pod dans le vcluster.

---
