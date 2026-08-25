# KUBERNETES : Opérations Avancées au Quotidien {-}

### L'Arsenal Opérationnel de l'Ingénieur Platform

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                 OPÉRATIONS EN DIRECT                        │
│                                                             │
│  ► Tunneling Sécurisé  : kubectl port-forward               │
│  ► Transfert Fichiers  : kubectl cp                         │
│  ► Automatisation CI/CD: kubectl wait --for=condition=...   │
│  ► Débogage Live       : kubectl exec / kubectl attach      │
└─────────────────────────────────────────────────────────────┘
```

### 1. Tunnel Sécurisé : `kubectl port-forward`

Accéder à une base de données PostgreSQL ou une UI interne sans jamais exposer de port public sur Internet :

```bash
# Rediriger le port local 5432 vers le port 5432 du Pod postgres
kubectl port-forward pod/postgres-0 5432:5432

# Rediriger vers un Service ou un Deployment
kubectl port-forward svc/prometheus-k8s 9090:9090 -n monitoring
```

- Le trafic passe à travers le tunnel HTTPS chiffré de l'APIServer !

### 2. Automatisation CI/CD : `kubectl wait`

Fini les boucles `sleep 30` fragiles et hasardeuses dans vos pipelines CI/CD !

```bash
# Attendre que le déploiement soit 100% opérationnel avec un timeout de 2 minutes
kubectl rollout status deployment/bookstore-api --timeout=120s

# Attendre qu'une condition spécifique soit validée
kubectl wait --for=condition=ready pod -l app=bookstore-api --timeout=60s

# Attendre la fin d'un Job de migration de base de données
kubectl wait --for=condition=complete job/db-migration --timeout=180s
```

### 3. Transfert de Données : `kubectl cp`

```bash
# Copier un fichier de log local vers un conteneur
kubectl cp dump.sql default/postgres-0:/tmp/dump.sql

# Récupérer un fichier généré à l'intérieur d'un pod
kubectl cp default/reporting-pod:/app/report.pdf ./report.pdf -c app-container
```

### Mini-Défi : Le Pipeline CI/CD Résilient

**Objectif** : Vous écrivez un script de déploiement qui applique un manifest, attend que l'application soit prête, et effectue un rollback automatique immédiat si le déploiement échoue au bout de 90 secondes.



### Mini-Défi : Le Pipeline CI/CD Résilient

**Objectif** : Vous écrivez un script de déploiement qui applique un manifest, attend que l'application soit prête, et effectue un rollback automatique immédiat si le déploiement échoue au bout de 90 secondes.

```bash
# Le script SRE parfait :
kubectl apply -f app-deployment.yaml
if ! kubectl rollout status deployment/web-app --timeout=90s; then
    echo "Déploiement échoué ! Rollback immédiat..."
    kubectl rollout undo deployment/web-app
    exit 1
fi
echo "Déploiement réussi avec succès !"
```

