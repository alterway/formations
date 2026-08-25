# KUBERNETES : Se Préparer aux Certifications CNCF {-}

### Le Panorama des Certifications Officielles

```
      KCNA (Fondamentaux)          CKAD (Développeur)           CKA (Administrateur)          CKS (Sécurité)
   QCM Théorique Cloud Native    100% Pratique Hands-on       100% Pratique Hands-on      100% Pratique Hands-on
   Architecture & CNCF           Pods, Deploy, Services,      Control Plane, Upgrades,    PSA, Falco, Trivy,
                                 Jobs, ConfigMaps             ETCD Backup, CNI, Troubleshoot  RBAC, NetworkPolicy
```

- **Format des examens CKA / CKAD / CKS** :
  - **Durée** : 2 heures en conditions réelles sur terminal Linux.
  - **Accès autorisé** : Documentation officielle (<https://kubernetes.io/docs/>).
  - **Note minimale** : 66% pour réussir.

### Les 5 Astuces en Or pour Réussir (Speedrun Mode)

1. **Maîtriser la génération impérative** :
   `kubectl run ... --dry-run=client -o yaml` (interdiction d'écrire du YAML de zéro !).

2. **Configurer son environnement dès la 1ère minute** :
   ```
   alias k=kubectl
   export do="--dry-run=client -o yaml"
   export now="--force --grace-period=0"
   ```

3. **Optimiser sa configuration `.vimrc`** :
   ```vim
   set tabstop=2 shiftwidth=2 expandtab autoindent number
   ```

4. **Utiliser les signets et la recherche doc** :
   Aller directement sur les pages d'exemples de la documentation officielle.
5. **S'entraîner sur Killer.sh** :
   Deux sessions de simulation d'examen gratuites sont incluses avec l'inscription à l'examen.

