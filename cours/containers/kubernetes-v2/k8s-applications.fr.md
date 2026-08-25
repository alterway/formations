# KUBERNETES : Stratégies de Déploiement & Zéro Downtime {-}

### L'Objectif : Déployer en Pleine Journée Sans Peur !

```
   STRATÉGIE RECREATE                            STRATÉGIE ROLLING UPDATE
[ Ancien Pod ] ──► (Détruit)                    [ V1 ] [ V1 ] ──► [ V1 ] [ V2 ]
         │ (Downtime !)                                            │
         ▼                                                         ▼
[ Nouveau Pod ] ──► (Démarré)                                   [ V2 ] [ V2 ] (0 Downtime)
```

![](images/kubernetes/rolling-update.gif){height="200px"}

### 1. Les 4 Stratégies de Déploiement

| Stratégie | Downtime | Coût Infrastructure | Risque | Cas d'Usage |
| :--- | :--- | :--- | :--- | :--- |
| **`RollingUpdate`** | 0s | Faible (+1 pod de `maxSurge`) | Moyen | Applications stateless standard |
| **`Recreate`** | Oui (10s-2min) | Nul | Faible | Incompatibilité de schéma de BDD entre versions |
| **`Blue/Green`** | 0s | Élevé (+100% de ressources) | Faible | Bascule atomique instantanée après tests réels |
| **`Canary`** | 0s | Modéré (+5-10%) | Très faible | Envoi de 5% du vrai trafic sur la v2 (Argo Rollouts) |

### 2. Le Secret du Zéro Downtime Réel : Les 3 Probes

Sans Probes bien configurées, Kubernetes envoie du trafic utilisateur à des conteneurs qui n'ont même pas fini d'initialiser leur serveur web !

```
   1. StartupProbe ──► "Est-ce que l'application a fini de charger ses dépendances ?"
         │ (Si OK)
         ▼
   2. ReadinessProbe ──► "Est-ce que l'application est prête à recevoir du trafic ?"
         │               (Si KO : Retiré des Endpoints du Service, 0 trafic envoyé !)
         ▼
   3. LivenessProbe ──► "Est-ce que l'application est toujours vivante ou en deadlock ?"
                         (Si KO : Le Kubelet redémarre le conteneur !)
```

![](images/kubernetes/probes.png){height="220px"}

### Exemple de Configuration des Probes

```yaml
spec:
  containers:
  - name: api
    image: my-app:2.0
    startupProbe:
      httpGet:
        path: /healthz
        port: 8080
      failureThreshold: 30
      periodSeconds: 2    # Laisse jusqu'à 60s pour démarrer
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      periodSeconds: 5
    livenessProbe:
      httpGet:
        path: /live
        port: 8080
      periodSeconds: 10
```

### 3. L'Arrêt Propre (Graceful Shutdown)

Lorsqu'un Pod est arrêté (scale down ou rolling update) :

```
1. Le Pod passe en statut Terminating
2. L'IP du Pod est retirée des Endpoints (les nouvelles requêtes ne vont plus vers lui)
3. Exécution du Hook preStop (sleep 5s pour laisser le temps aux iptables de se synchroniser)
4. Envoi du signal SIGTERM au processus applicatif (pour finir les requêtes en cours)
5. Attente jusqu'à terminationGracePeriodSeconds (défaut: 30s)
6. Envoi du SIGKILL destructeur si le processus n'a pas quitté proprement
```

```yaml
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 5"]
```

### Mini-Défi : L'Erreur de la Liveness Probe

**Code Review** : Vous observez qu'en pic de charge, vos Pods se mettent à redémarrer en boucle de façon incontrôlable.

En inspectant la config :
```yaml
livenessProbe:
  httpGet:
    path: /api/v1/check-database-and-heavy-query # <── Requête SQL complexe en BDD !
```

Pourquoi cette configuration est-elle une bombe à retardement en production ?


### Mini-Défi : L'Erreur de la Liveness Probe

**Code Review** : Vous observez qu'en pic de charge, vos Pods se mettent à redémarrer en boucle de façon incontrôlable.

En inspectant la config :
```yaml
livenessProbe:
  httpGet:
    path: /api/v1/check-database-and-heavy-query # <── Requête SQL complexe en BDD !
```

Pourquoi cette configuration est-elle une bombe à retardement en production ?

(Réponse : Si la base de données ralentit ou sature, la liveness probe échoue en timeout. Kubernetes croit à tort que le Pod web est mort et le tue, provoquant une cascade de redémarrages catastrophique (thundering herd). La Liveness Probe doit être **locale et ultra-légère** !).

