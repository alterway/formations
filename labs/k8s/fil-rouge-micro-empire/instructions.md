
---

# Lab Fil Rouge : Micro-Empires K8s — Consignes Élève (100% Pratique)

Bienvenue dans l'arène ! Vous êtes le maire d'un quartier numérique hébergé sur votre vCluster Kubernetes dédié.

**Votre objectif :** Écrire et déployer l'intégralité des manifestes Kubernetes (YAML) permettant de faire tourner votre application vitrine, sa base de données, sa résilience, son autoscaling et sa sécurité réseau.

Sur l'écran géant de la salle, le **Dashboard Central** vérifie l'état de votre quartier en temps réel. Si votre application répond correctement, votre tuile passe au vert !

💡 **Convention de nommage :** Dans l'ensemble du lab, remplacez `[VOTRE_NOM]` par votre identifiant attribué (ex: `hleclerc`).

---

## Module 1 : Exposition & TLS (Service & Ingress)

Rendez votre future application accessible depuis l'extérieur en HTTPS sur le domaine d'entreprise.

**Cahier des charges :**

* **Service K8s :**
* Type d'objet : `Service`
* Nom : `podinfo-svc`
* Type : `ClusterIP`
* Port exposé et port cible : `9898`
* Sélecteur de pod : `app: podinfo`


* **Routage & Certificat HTTPS :**
* Type d'objet : `Ingress`
* Nom : `podinfo-ingress`
* Nom d'hôte (Host) : `quartier-[VOTRE_NOM].apps.caas.fr`
* Règle de routage : Rediriger toutes les requêtes du chemin `/` (`pathType: Prefix`) vers le service `podinfo-svc` sur le port `9898`.
* Annotations obligatoires :
* `cert-manager.io/cluster-issuer: "letsencrypt-prod"`
* `nginx.ingress.kubernetes.io/ssl-redirect: "true"`


* Section TLS : Configurer la terminaison TLS sur l'hôte `quartier-[VOTRE_NOM].apps.caas.fr` et enregistrer le certificat généré dans un Secret nommé `[VOTRE_NOM]-tls-secret`.



**Validation :** Appliquez vos fichiers YAML avec `kubectl apply -f`. Vérifiez la prise en compte avec `kubectl get svc,ingress`.

---

## Module 2 : Persistance & État (Service Headless & StatefulSet)

Déployez le serveur de cache Redis nécessaire au stockage des données de votre quartier.

**Cahier des charges :**

* **Service d'annuaire (Headless) :**
* Type d'objet : `Service`
* Nom : `redis-svc`
* Configuration réseau : `clusterIP: None` (Service Headless obligatoire pour les StatefulSets)
* Port : `6379`
* Sélecteur de pod : `app: redis`


* **Base de données Redis :**
* Type d'objet : `StatefulSet`
* Nom : `redis`
* Nombre de répliques : `1`
* Service rattaché (`serviceName`) : `redis-svc`
* Label des pods : `app: redis`
* Conteneur : Image `redis:alpine` exposant le port `6379`
* Stockage : Monter un volume nommé `redis-data` sur le répertoire `/data` du conteneur.
* Modèle de PVC (`volumeClaimTemplates`) :
* Nom du claim : `redis-data`
* Mode d'accès : `ReadWriteOnce`
* Taille de stockage demandée : `1Gi`





**Validation :** Vérifiez l'allocation dynamique du volume et l'état du pod avec `kubectl get statefulset,pvc,pod`.

---

## Module 3 & 4 : Application, Résilience & Autoscaling (Deployment, PDB, HPA)

Déployez l'application principale `podinfo`, configurez ses sondes de santé, prémunissez-la contre la suppression de pods et préparez-la à l'autoscaling CPU.

**Cahier des charges :**

* **Application principale :**
* Type d'objet : `Deployment`
* Nom : `podinfo`
* Nombre de répliques : `2`
* Label des pods : `app: podinfo`
* Conteneur : Image `stefanprodan/podinfo:latest` exposant le port `9898`
* Variable d'environnement : `PODINFO_CACHE_SERVER` définie avec l'URL FQDN `tcp://redis-svc.default.svc.cluster.local:6379`
* Sondes de santé (Probes) :
* `livenessProbe` : Test HTTP GET sur `/healthz` (port `9898`, `initialDelaySeconds: 5`, `periodSeconds: 10`)
* `readinessProbe` : Test HTTP GET sur `/readyz` (port `9898`, `initialDelaySeconds: 5`, `periodSeconds: 10`)


* Gestion des ressources CPU/RAM (exigée pour l'HPA) :
* Requests : CPU `10m`, Mémoire `32Mi`
* Limits : CPU `250m`, Mémoire `128Mi`




* **Haute Disponibilité & Anti-Chaos :**
* Type d'objet : `PodDisruptionBudget`
* Nom : `podinfo-pdb`
* Règle : `minAvailable: 1`
* Sélecteur de pod : `app: podinfo`


* **Autoscaling Dynamique :**
* Type d'objet : `HorizontalPodAutoscaler` (API `autoscaling/v2`)
* Nom : `podinfo-hpa`
* Cible (`scaleTargetRef`) : Déploiement `podinfo`
* Nombre de pods : Minimum `2`, Maximum `10`
* Métrique de déclenchement : Seuil moyen de CPU (`Resource` / `cpu`) fixé à `20%` d'utilisation (`Utilization`).



**Validation :** Regardez le Dashboard central. Votre tuile quartier doit passer au **VERT**. Suivez l'autoscaling en direct pendant le tir de charge avec `kubectl get hpa -w`.

---

## Module 5 : Sécurité & Cloisonnement (NetworkPolicies)

Bunkerisez votre quartier en appliquant une politique d'isolation réseau Zero-Trust.

**Cahier des charges :**

* **Règle 1 — Blocage des entrées par défaut :**
* Type d'objet : `NetworkPolicy`
* Nom : `default-deny-ingress`
* Cible : Tous les pods du namespace (`podSelector: {}`)
* Type de politique : `Ingress` uniquement


* **Règle 2 — Autorisation des flux sortants (DNS / Egress) :**
* Type d'objet : `NetworkPolicy`
* Nom : `allow-all-egress`
* Cible : Tous les pods du namespace
* Type de politique : `Egress` (avec un bloc `egress: - {}` autorisant toutes les sorties pour préserver la résolution DNS)


* **Règle 3 — Ouverture du trafic Web externe :**
* Type d'objet : `NetworkPolicy`
* Nom : `allow-web-to-podinfo`
* Cible : Pods `app: podinfo`
* Règle : Autoriser le trafic entrant (Ingress) sur le port TCP `9898` depuis n'importe quelle source


* **Règle 4 — Flux sécurisé Application vers Base de données :**
* Type d'objet : `NetworkPolicy`
* Nom : `allow-podinfo-to-redis`
* Cible : Pods `app: redis`
* Règle : Autoriser le trafic entrant (Ingress) sur le port TCP `6379` **uniquement** si la requête provient de pods possédant le label `app: podinfo`



**Validation finale :** Testez la réponse de votre application avec `curl -sk https://quartier-[VOTRE_NOM].apps.caas.fr/api/info`. La commande doit retourner le JSON complet de Podinfo sans timeout ni erreur 504.