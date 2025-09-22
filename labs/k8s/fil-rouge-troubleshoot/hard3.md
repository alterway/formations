
**Instructions pour la première partie (la mise en place) :**

Demandez aux élèves d'appliquer ces deux fichiers. Ensuite, guidez-les pour créer la configuration manuelle :

1.  **Obtenir les IPs des pods :**
    ```sh
    kubectl get pods -n decoupled-ns -o wide
    # Noter les adresses IP, par ex: 10.1.1.2 et 10.1.1.3
    ```

2.  **Créer le Service et les Endpoints manuels :**
    Donnez-leur ce troisième fichier, **en leur demandant de remplacer les IPs par celles qu'ils viennent d'obtenir**.

**3. `03-service-manual.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: user-api-service
  namespace: decoupled-ns
spec:
  # ERREUR CRUCIALE 1 : Absence totale de "selector".
  # Cela désactive la gestion automatique des Endpoints.
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: v1
kind: Endpoints
metadata:
  # Le nom doit être identique à celui du Service
  name: user-api-service
  namespace: decoupled-ns
# ERREUR CRUCIALE 2 : Cette section est gérée manuellement.
subsets:
  - addresses:
      # REMPLACER CES IPs PAR LES IPs RÉELLES DES PODS
      - ip: "10.1.1.2"
      - ip: "10.1.1.3"
    ports:
      - port: 80```

À ce stade, si un test est effectué depuis un pod de débogage, `curl http://user-api-service.decoupled-ns`, **tout fonctionne**.

---

### Le Piège : Simuler une mise à jour de l'application

Demandez maintenant aux élèves de simuler une mise à jour qui recycle les pods :
```sh
# Cette commande supprime les anciens pods et le déploiement en crée de nouveaux
kubectl rollout restart deployment user-api -n decoupled-ns