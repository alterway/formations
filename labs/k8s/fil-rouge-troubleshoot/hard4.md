Absolument. Vous avez raison, une bonne mise en forme est essentielle pour la clarté. Voici le scénario "Le Cauchemar du Finalizer Orphelin", présenté avec une structure Markdown claire et des blocs de code correctement formatés.

### Scénario de l'Atelier : "Le Cauchemar du Finalizer Orphelin"

**Objectif pour les élèves :** Diagnostiquer et résoudre le blocage d'un namespace en état `Terminating` en identifiant et en supprimant manuellement un finalizer sur une ressource personnalisée (Custom Resource).

**Description du problème :**

Le piège est un **finalizer orphelin**. Un finalizer est un mécanisme de blocage qui empêche la suppression d'une ressource Kubernetes tant qu'un contrôleur spécifique n'a pas terminé ses tâches de nettoyage.

Nous allons créer une ressource personnalisée (CR) qui possède un finalizer, mais nous n'allons **jamais déployer le contrôleur** qui est censé gérer et retirer ce finalizer. Lorsque l'on tentera de supprimer le namespace, Kubernetes essaiera de supprimer notre ressource. Il la marquera pour suppression, mais attendra indéfiniment que le contrôleur manquant retire le finalizer. La ressource ne sera jamais supprimée, et par conséquent, le namespace restera bloqué pour toujours dans l'état `Terminating`.

---

### Les Fichiers Manifestes à Fournir aux Élèves

#### 1. `01-namespace.yaml`
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: stuck-ns
```

#### 2. `02-crd.yaml` (Définition de notre ressource personnalisée)
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: externalresources.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                databaseName:
                  type: string
  scope: Namespaced
  names:
    plural: externalresources
    singular: externalresource
    kind: ExternalResource
    shortNames:
    - extres
```

#### 3. `03-blocking-resource.yaml` (La ressource piégée)
```yaml
apiVersion: "stable.example.com/v1"
kind: ExternalResource
metadata:
  name: my-database-claim
  namespace: stuck-ns
  # ERREUR CRUCIALE : Ce finalizer empêche la suppression de l'objet
  # tant qu'un contrôleur ne l'a pas retiré.
  # Or, ce contrôleur n'existe pas.
  finalizers:
    - "external-resource.example.com/cleanup"
spec:
  databaseName: "production-db-1234"
```

---

### Le Déroulement de l'Exercice

1.  **Phase 1 : Déploiement**
    Demandez aux élèves d'appliquer tous les manifestes.
    ```sh
    kubectl apply -f .
    ```
    Toutes les ressources seront créées sans la moindre erreur.

2.  **Phase 2 : La Tâche de Suppression**
    L'objectif est simple : "Nettoyez l'environnement en supprimant le namespace `stuck-ns`."
    Les élèves exécutent la commande :
    ```sh
    kubectl delete namespace stuck-ns
    ```

---

### Guide de Diagnostic et Solution

#### Symptômes Observés

*   La commande `kubectl delete namespace stuck-ns` reste bloquée ou se termine, mais le namespace persiste.
*   Une vérification avec `kubectl get namespaces` montre le namespace `stuck-ns` avec le statut **`Terminating`**.

    ```sh
    kubectl get namespaces
    ```
    **Sortie attendue :**
    ```
    NAME       STATUS        AGE
    stuck-ns   Terminating   5m
    ...
    ```
*   Toute tentative de recréer le namespace échouera car il est "en cours de suppression".

#### Le Cheminement du Diagnostic

1.  **Hypothèse de départ :** Un namespace est bloqué car une ressource à l'intérieur ne peut pas être supprimée.

2.  **Lister les ressources restantes :** Il faut trouver ce qui reste dans ce namespace fantôme.
    ```sh
    kubectl api-resources --verbs=list --namespaced=true -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n stuck-ns
    ```
    Cette commande puissante liste tout ce qui pourrait exister dans le namespace. La sortie montrera notre `ExternalResource`.
    **Sortie attendue :**
    ```
    NAME                                     AGE
    externalresource.stable.example.com/my-database-claim   10m
    ```

3.  **Inspecter l'objet bloquant :** Pourquoi cet objet ne se supprime-t-il pas ? L'expert doit regarder l'état brut de l'objet en YAML.
    ```sh
    kubectl get externalresource my-database-claim -n stuck-ns -o yaml
    ```

4.  **La Découverte :** La sortie YAML est la clé de tout le mystère.
    ```yaml
    apiVersion: stable.example.com/v1
    kind: ExternalResource
    metadata:
      # ... autres métadonnées ...
      # Kubernetes a bien marqué l'objet pour suppression !
      deletionTimestamp: "2025-09-22T14:30:00Z"
      # Le coupable qui bloque la suppression effective.
      finalizers:
      - external-resource.example.com/cleanup
      name: my-database-claim
      namespace: stuck-ns
    spec:
      databaseName: production-db-1234
    ```
    La présence simultanée d'un `deletionTimestamp` et d'un tableau `finalizers` non vide est la preuve irréfutable du blocage.

#### La Solution

Puisque le contrôleur qui devrait retirer le finalizer n'existe pas, la seule solution est de le faire manuellement en "patchant" l'objet pour lui retirer le finalizer.

```sh
kubectl patch externalresource my-database-claim -n stuck-ns \
  -p '{"metadata":{"finalizers":[]}}' \
  --type=merge
```

**Résultat :**

Dès que cette commande est exécutée, le finalizer disparaît. L'API Kubernetes, voyant que l'objet est marqué pour suppression et n'a plus de finalizers, le supprime immédiatement. Le namespace `stuck-ns` devient alors vide et sa propre suppression se termine quasi-instantanément.