### Exercice 18/30 : Échec de résolution DNS interne dû à une mauvaise configuration de `dnsPolicy` (Niveau : Moyen / Avancé)

* **Objectif :** Diagnostiquer et corriger une rupture de la résolution de noms de domaine internes au cluster (`.cluster.local`) générée par une surcharge invalide de la politique DNS du Pod.
* **Contexte :** Un ingénieur système a souhaité forcer l'utilisation d'un serveur DNS externe (ex. `8.8.8.8`) pour un outil de supervision. Depuis cette modification, l'outil est incapable de joindre les autres microservices du vcluster par leur nom de Service.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La politique "dnsPolicy: None" a été définie pour forcer un serveur DNS externe, mais sans inclure les domaines de recherche K8s ni le résolveur CoreDNS du cluster.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitor-tool
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitor-tool
  template:
    metadata:
      labels:
        app: monitor-tool
    spec:
      # ERREUR : dnsPolicy sur "None" sans ajouter le résolveur DNS interne coupe la résolution des Services K8s
      dnsPolicy: None
      dnsConfig:
        nameservers:
          - 8.8.8.8
      containers:
      - name: probe
        image: alpine/k8s:1.37.0
        command: ["sh", "-c", "until nslookup kubernetes.default.svc.cluster.local; do echo 'DNS resolution failed'; sleep 5; done"]

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitor-tool
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitor-tool
  template:
    metadata:
      labels:
        app: monitor-tool
    spec:
      # CORRECTION : Utilisation de la politique par défaut "ClusterFirst" pour conserver le DNS interne du cluster (CoreDNS)
      dnsPolicy: ClusterFirst
      dnsConfig:
        # Optionnel : Ajout d'un résolveur DNS externe en secours via les options si nécessaire, sans détruire la résolution interne
        options:
          - name: ndots
            value: "2"
      containers:
      - name: probe
        image: alpine/k8s:1.37.0
        command: ["sh", "-c", "until nslookup kubernetes.default.svc.cluster.local; do echo 'DNS resolution failed'; sleep 5; done"]

```

**Démarche de résolution pour l'apprenant :**

1. Consulter les journaux du Pod en échec : `kubectl logs -f deployment/monitor-tool`.
2. Observer que les requêtes vers `kubernetes.default.svc.cluster.local` échouent systématiquement (`nslookup: can't resolve...`).
3. Tester la résolution de noms externes vs internes depuis le Pod via un shell interactif :
`kubectl exec -it deployment/monitor-tool -- nslookup google.com` (fonctionne).
`kubectl exec -it deployment/monitor-tool -- nslookup kubernetes.default` (échoue).
4. Inspecter la configuration réseau du Pod : `kubectl get pod <nom-du-pod> -o yaml` et vérifier le bloc `dnsPolicy`.
5. Constater que `dnsPolicy: None` shunte totalement CoreDNS et le suffixe de recherche (`default.svc.cluster.local`).
6. Remettre `dnsPolicy: ClusterFirst` (ou compléter la structure `dnsConfig` avec l'IP de `kube-dns` et les `searches`) pour restaurer la résolution DNS interne.

---

