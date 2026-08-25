# KUBERNETES : Configuration & Secrets des Applications {-}

### Le Principe 12-Factor : Découpler Code & Configuration

```
  [ Image de Conteneur Immuable ]  +  [ ConfigMap / Secret ]
         (my-app:1.0)                        (dev / staging / prod)
               │                                       │
               └───────────────────┬───────────────────┘
                                   ▼
                         [ Pod Exécutable ]
```

- Une même image binaire doit pouvoir tourner en Dev, Pré-prod et Prod sans être recompilée.
- Les données non sensibles vont dans **ConfigMap**, les secrets d'accès dans **Secret**.

### 1. ConfigMaps : Deux Modes d'Injection

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-config-demo
spec:
  containers:
  - name: app
    image: my-app:1.0
    # Mode A : Injecté comme Variable d'Environnement
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: db_url
    # Mode B : Monté comme Fichier de Configuration
    volumeMounts:
    - name: config-volume
      mountPath: /etc/app/config.json
      subPath: config.json   # <── Ne masque pas les autres fichiers du dossier !
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### Injection Globale : `envFrom`

Pour injecter 50 variables d'un seul coup sans les déclarer une par une :

```yaml
spec:
  containers:
  - name: app
    image: my-app:1.0
    envFrom:
    - configMapRef:
        name: app-environment-vars
    - secretRef:
        name: app-sensitive-credentials
```

### 2. Secrets Kubernetes : Attention aux Fausses Idées !

> **Alerte Sécurité** : Les Secrets Kubernetes natifs sont simplement **encodés en Base64**, ils ne sont **PAS chiffrés** par défaut dans etcd si l'EncryptionConfiguration n'est pas activée !

```bash
# Encoder une valeur
echo -n "SuperSecretPass123" | base64
# -> U3VwZXJTZWNyZXRQYXNzMTIz

# Décoder
echo "U3VwZXJTZWNyZXRQYXNzMTIz" | base64 -d
```

- **Types de Secrets natifs** :
  - `Opaque` : Clés/Valeurs personnalisées (mots de passe, tokens API).
  - `kubernetes.io/tls` : Certificat (`tls.crt`) et clé privée (`tls.key`).
  - `kubernetes.io/dockerconfigjson` : Identifiants de registre privé d'images (`imagePullSecrets`).

### Gestion Industrielle des Secrets (GitOps Ready)

Dans une démarche GitOps, **interdiction de commiter des Secrets K8s en clair dans Git** !

1. **Sealed Secrets (Bitnami)** : Chiffrement asymétrique. Seul le cluster K8s possède la clé privée pour déchiffrer le manifeste commit dans Git.
2. **External Secrets Operator (ESO)** : Synchronise les secrets directement depuis HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager ou Azure Key Vault.

```
 [ AWS Secrets Mgr / Vault ] ──► [ External Secrets Operator ] ──► [ Secret K8s local ]
```

### Mini-Défi : Le Mystère de la Variable Fantôme

**Incident SRE** : Vous modifiez une valeur dans un `ConfigMap` existant via `kubectl edit cm app-config`. 

Pourtant, l'application continue d'utiliser l'ancienne valeur. Pourquoi ?

*(Réponse : Les variables d'environnement (`env` / `envFrom`) sont injectées **au moment du démarrage du processus** dans le conteneur. Elles ne se mettent pas à jour à chaud ! Il faut redémarrer le Pod (`kubectl rollout restart deployment/mon-app`) ou monter le ConfigMap en tant que **Volume**).*
