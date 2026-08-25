# KUBERNETES : Écosystème & Gouvernance Cloud Native {-}

### De Borg à la CNCF : L'Histoire de Kubernetes

![](images/kubernetes/kubernetes.png){height="90px"}

- **Origines (2003-2014)** : Conçu chez Google d'après les retours d'expérience des orchestrateurs internes **Borg** puis **Omega**.
- **Juillet 2015** : Sortie de Kubernetes 1.0 et don du projet à la toute nouvelle **CNCF** (Cloud Native Computing Foundation).
- **Aujourd'hui** : L'OS universel du Cloud et le standard incontournable d'orchestration distribuée.

![](images/kubernetes/story-of-kubernetes.png){height="300px"}

### La CNCF : La Fondation du Cloud Native

![](images/kubernetes/cncf.png){height="100px"}

- Branche de la **Linux Foundation** dédiée à l'écosystème Cloud Native.
- **Rôle clé** : Garantir la neutralité vis-à-vis des fournisseurs cloud (anti-vendor lock-in) et pérenniser les projets open source majeurs.
- *Quelques diplômés célèbres* : Kubernetes, Prometheus, Envoy, Helm, Fluentd, containerd, Argo, Cilium.

### Les Niveaux de Maturité CNCF

```{.center}
    [ Sandbox ] ──► [ Incubating ] ──► [ Graduated ]
(Expérimentation)    (Adoption active)  (Production Ready &
                                         Gouvernance éprouvée)
```

1. **Sandbox** : Projets émergents, innovants, testés par la communauté.
2. **Incubating** : Utilisés en pré-production / production, stables, avec gouvernance claire.
3. **Graduated** : Le plus haut niveau d'exigence (sécurité auditée, gouvernance mature, adoption massive à l'échelle mondiale).

### Comment Évolue Kubernetes ? Les SIGs

Le projet est piloté par des **Special Interest Groups (SIGs)** autonomes :

- **SIG Architecture** : Cohérence globale du système et principes directeurs.
- **SIG API Machinery** : Cœur de l'APIServer, etcd, sérialisation et Custom Resource Definitions (CRD).
- **SIG Node** : Kubelet, interaction avec le runtime conteneur (CRI).
- **SIG Network** : Services, Ingress, Gateway API, CNI.
- **SIG Storage** : CSI, PersistentVolumes, gestion des disques.
- **SIG Security** : Modèle de sécurité, RBAC, CVEs.

### Le Cycle de Vie des Versions

- **3 versions mineures par an** (tous les 4 mois : ex. 1.29, 1.30, 1.31, 1.32).
- **Support officiel** : Les 3 dernières versions mineures bénéficient de correctifs de sécurité (support d'environ 1 an par version).
- **Processus d'évolution des fonctionnalités** :
  - **Alpha** : Désactivé par défaut, expérimental, breaking changes possibles.
  - **Beta** : Activé par défaut, stable, recommandé pour tests poussés.
  - **GA (General Availability) / Stable** : Prêt pour la production, rétro-compatibilité garantie.

### Mini-Défi : Décodez le Paysage CNCF

**Question flash** : Dans quel statut CNCF se situent ces projets incontournables ?

1. **Kubernetes** ?
2. **ArgoCD** ?
3. **Cilium** ?
4. **OpenTelemetry** ?


### Mini-Défi : Décodez le Paysage CNCF (Réponses)

**Question flash** : Dans quel statut CNCF se situent ces projets incontournables ?

1. **Kubernetes** ?
2. **ArgoCD** ?
3. **Cilium** ?
4. **OpenTelemetry** ?

**Réponse** : Kubernetes, ArgoCD et Cilium sont **Graduated** ! OpenTelemetry est **Incubating** en voie rapide vers la graduation.

