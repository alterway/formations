## Étape 6 : Séquencement et cycle de vie (Sync Waves & Hooks)

Dans un déploiement complexe, l'ordre de création des ressources est crucial. Par exemple, tu dois t'assurer que le namespace et les secrets existent avant la base de données, et que le script de migration de la base s'exécute avec succès *avant* de mettre à jour le backend.

Argo CD gère cela grâce à deux concepts puissants : les **Sync Waves** (Vagues de synchronisation) et les **Resource Hooks** (Crochets d'exécution).

---

### 1. Les Sync Waves (Séquencement par vagues)

Argo CD déploie les ressources par "vagues". Par défaut, toutes les ressources sont dans la vague `0`.
Les vagues sont triées par ordre croissant : les valeurs négatives s'exécutent en premier (`-2`, `-1`, `0`, `1`, `2`...).
Argo CD attend que toutes les ressources d'une vague soient `Healthy` avant de lancer la vague suivante.

L'ordre se définit via une simple annotation dans tes manifestes :

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"

```

### 2. Les Resource Hooks (Cycle de vie)

Les Hooks permettent d'exécuter des actions (généralement des `Jobs` Kubernetes) à des moments précis du cycle de synchronisation :

* **`PreSync`** : S'exécute *avant* l'application des manifestes (ex: backup de BDD, script de migration de schéma).
* **`Sync`** : S'exécute *pendant* l'application (orchestration complexe).
* **`PostSync`** : S'exécute *après* que tout soit `Healthy` (ex: tests d'intégration, notification Slack/Teams, nettoyage de cache).
* **`SyncFail`** : S'exécute en cas d'échec de la synchronisation (ex: envoi d'alerte, rollback manuel).

---

### 3. TP Pratique : Job de migration de base de données

Imaginons que l'on doive exécuter un Job de migration avant le déploiement d'une nouvelle version de notre application `guestbook`.

Crée un fichier `db-migration-job.yaml` :

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: guestbook-db-migration
  namespace: guestbook-dev
  annotations:
    # 1. Définit que ce Job s'exécute AVANT de synchroniser les autres ressources
    argocd.argoproj.io/hook: PreSync
    
    # 2. Argo CD supprimera automatiquement le Job s'il réussit, 
    # pour ne pas polluer le cluster lors des prochaines synchros.
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
    
    # 3. Optionnel ici, mais utile s'il y a plusieurs PreSync Hooks
    argocd.argoproj.io/sync-wave: "-1"
spec:
  template:
    spec:
      containers:
        - name: db-migration
          image: alpine:latest
          command: ["sh", "-c", "echo 'Exécution des migrations SQL...'; sleep 5; echo 'Migration OK !'"]
      restartPolicy: Never
  backoffLimit: 1

```

### 4. Déploiement et observation

Si tu ajoutes ce fichier dans le dépôt Git surveillé par ton `Application` Argo CD (ou si tu l'appliques directement pour tester la mécanique) et que tu lances une synchronisation :

1. L'interface (UI) d'Argo CD va montrer un petit icône "ancre" (⚓) à côté de la ressource Job, indiquant qu'il s'agit d'un Hook.
2. Argo CD va d'abord lancer ce Job. L'application restera en statut `Syncing`.
3. Une fois le script terminé avec succès (`sleep 5`), le pod de migration est détruit automatiquement (grâce au `HookSucceeded`).
4. Argo CD passe à la suite et synchronise le reste des manifestes (`Deployment`, `Service`, etc.).
5. L'application passe au statut `Synced` / `Healthy`.

---

### Conclusion du Fil Rouge GitOps

Félicitations ! À travers ce programme, tu as mis en place un socle Kubernetes GitOps avancé :

1. **Socle** : Installation Helm, Ingress, mots de passe déclaratifs.
2. **App** : Auto-réconciliation et gestion de la dérive (anti-drift).
3. **Scale** : Pattern ApplicationSet pour la gestion multi-environnements.
4. **Sécurité** : Isolation via AppProject, accès RBAC et terminal distant.
5. **Déploiement progressif** : Argo Rollouts (Canary) et gestion du trafic.
6. **Orchestration fine** : Sync Waves et Hooks pour les opérations complexes.
