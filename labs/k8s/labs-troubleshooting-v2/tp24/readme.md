### Exercice 24/30 : Namespace bloqué indéfiniment à l'état `Terminating` (Niveau : Avancé / Expert)

* **Objectif :** Diagnostiquer et débloquer un Namespace dont la suppression est figée en raison d'un finaliseur (*Finalizer*) non traité sur une ressource orpheline.
* **Contexte :** Une procédure de nettoyage automatique a tenté de supprimer le Namespace `staging-app`. Cependant, le Namespace reste bloqué au statut `Terminating` depuis plusieurs heures et refuse d'être purgé.

```yaml
# --- MANIFESTE À INJECTER (bad-namespace.yaml) ---
# Problème : La ConfigMap "app-state" contient un finaliseur personnalisé ("custom.domain.com/hold-cleanup").
# Le contrôleur censé traiter ce finaliseur n'existe plus. Kubernetes refuse de supprimer l'objet et bloque la destruction du Namespace parent.
apiVersion: v1
kind: Namespace
metadata:
  name: staging-app
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-state
  namespace: staging-app
  # ERREUR : Ce finaliseur bloque la suppression de l'objet et du Namespace
  finalizers:
    - custom.domain.com/hold-cleanup
data:
  status: "archived"

```

```yaml
# --- MANIFESTE/COMMANDE DE CORRECTION (fixed-resolution.yaml) ---
# Correction : Il faut retirer manuellement le finaliseur de la ressource ou la Patcher via la CLI pour que le Garbage Collector de Kubernetes puisse finaliser la suppression du Namespace.

# Commande à exécuter par l'apprenant pour supprimer le finaliseur sur la ressource :
# kubectl patch configmap app-state -n staging-app -p '{"metadata":{"finalizers":null}}' --type=merge

# Variante si la ressource est déjà masquée et que seul le patch JSON direct sur la ressource fonctionne :
# kubectl get configmap app-state -n staging-app -o json | jq '.metadata.finalizers = []' | kubectl replace -f -

```

**Préparation pour le professeur (Procédure d'injection) :**

```bash
# 1. Déployer les ressources
kubectl apply -f bad-namespace.yaml

# 2. Lancer la suppression du Namespace pour provoquer le blocage "Terminating"
kubectl delete ns staging-app --wait=false

```

**Démarche de résolution pour l'apprenant :**

1. Constater le blocage du Namespace : `kubectl get ns staging-app` (statut `Terminating`).
2. Examiner les raisons du blocage de finalisation du Namespace :
`kubectl get ns staging-app -o json` et lire la section `status.conditions`.
3. Analyser le message d'erreur : `Some resources are remaining: configmaps.v1 has 1 resource instances`.
4. Inspecter les ressources restantes dans le Namespace en cours de suppression :
`kubectl get all,configmap,secret -n staging-app`.
5. Identifier que la ConfigMap `app-state` a une date de suppression (`deletionTimestamp`) mais ne disparaît pas.
6. Vérifier les finaliseurs appliqués sur la ressource : `kubectl get configmap app-state -n staging-app -o yaml`.
7. Supprimer le finaliseur bloquant via un patch JSON (`kubectl patch configmap app-state -n staging-app -p '{"metadata":{"finalizers":null}}' --type=merge`). Le Namespace est immédiatement libéré et supprimé par le cluster.

---
