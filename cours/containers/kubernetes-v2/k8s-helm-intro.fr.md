# KUBERNETES : Gestion de Paquets avec Helm {-}

### Pourquoi Helm ? Le Package Manager Cloud Native

```
 [ 20 Fichiers YAML Complexes ]  ──► Packagés dans un  ──► [ 1 Helm Chart ]
 (Deployments, Services, RBAC,                             (my-app:1.2.0)
  CRDs, Ingress, Secrets...)                                     │
                                                                 ▼
                         Paramétré par un seul fichier : [ values.yaml ]
```

- **Rôle principal** : Idéal pour déployer et maintenir des applications tierces (Prometheus, cert-manager, Ingress-NGINX, Redis).
- Maintient un historique des versions déployées et gère les rollbacks en 1 commande.

### Anatomie d'un Helm Chart

```
my-chart/
├── Chart.yaml          # Métadonnées (Nom, version de l'app, version du chart)
├── values.yaml         # Valeurs par défaut injectées dans les templates
├── templates/          # Gabarits YAML avec moteur Go Template
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl
└── charts/             # Sous-charts / Dépendances éventuelles
```

### Le Moteur de Templating en Action

```yaml
# templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "my-chart.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
```

```yaml
# values.yaml (Dev vs Prod)
service:
  type: ClusterIP
  port: 8080
```

### Commandes Indispensables du Quotidien

```bash
# 1. Ajouter un dépôt officiel (ex: Bitnami)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 2. Installer ou Mettre à jour de façon idempotente
helm upgrade --install my-redis bitnami/redis \
  --namespace databases --create-namespace \
  --set auth.enabled=false

# 3. Tester le rendu YAML sans rien appliquer (Dry Run)
helm template my-release bitnami/redis -f my-values.yaml

# 4. Rollback immédiat vers la révision précédente
helm rollback my-redis 1
```

### Mini-Défi : Le Piège du Template YAML

**Code Review** : Que se passe-t-il si vous passez une chaîne de caractères contenant des deux-points (`:`) dans une valeur Helm sans guillemets dans votre `values.yaml` ?

```yaml
message: Erreur: Connexion refusée # <── Erreur de parsing YAML !
```

*(Réponse : Le parseur YAML interprète la seconde partie comme une nouvelle clé imbriquée invalide et le `helm install` crashe. Il faut toujours quoter les chaînes : `message: "Erreur: Connexion refusée"` et utiliser la fonction `{{ .Values.message | quote }}` dans le template).*
