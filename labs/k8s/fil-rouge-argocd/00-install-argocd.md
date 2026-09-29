C'est une excellente pratique ! L'installation via Helm est le standard en entreprise, et c'est le premier vrai pas vers une gestion "Infrastructure as Code" avant de passer en GitOps complet.

Voici l'**Étape 1 révisée** pour une installation via Helm avec Ingress, Cert-Manager et mot de passe déclaratif.

---

## Étape 1  : Architecture et installation via Helm

### 1. Prérequis : Générer le mot de passe Admin

Argo CD n'accepte pas les mots de passe en clair dans son fichier de configuration. Il faut générer un hash `bcrypt`.
Tu peux le faire depuis ton terminal (avec `htpasswd` ou via Docker si tu ne l'as pas installé) :

```bash
# Exemple pour le mot de passe "P@ssword123!"
htpasswd -nbB admin "P@ssword123!" | cut -d ":" -f 2

```

*Garde le hash généré (qui commence par `$2y$` ou `$2a$`) pour le fichier `values.yaml`.*

### 2. Création du fichier `values.yaml`

Crée un fichier `argocd-values.yaml` avec le contenu suivant.
*(Note : Nous ajoutons l'argument `--insecure` au serveur Argo CD pour désactiver son TLS interne. C'est nécessaire car c'est ton Ingress Controller qui va faire la terminaison TLS grâce à ton certificat Let's Encrypt).*

```yaml
global:
  domain: argocd-hleclerc.apps.caas.fr

configs:
  secret:
    # Colle ici le hash bcrypt généré à l'étape précédente
    argocdServerAdminPassword: "$2y$05$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

server:
  # Désactive le HTTPS interne d'ArgoCD (la terminaison TLS est gérée par l'Ingress)
  extraArgs:
    - --insecure

  ingress:
    enabled: true
    ingressClassName: nginx 
    annotations:
      cert-manager.io/cluster-issuer: "le"

    # Pense à remplacer "nom-etudiant" par ton vrai nom/identifiant
    hostname: argocd-nom-etudiant.apps.caas.fr
    tls: true

```

### 3. Déploiement via Helm

Ajoute le dépôt officiel d'Argo CD et déploie l'application dans ton cluster :

```bash
# Ajout du repository Helm d'Argo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Installation du chart avec ton fichier values
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  -f argocd-values.yaml

```

### 4. Validation

Une fois les pods démarrés et le certificat Let's Encrypt généré, tu devrais pouvoir accéder à ton interface web via **`[https://argocd-nom-etudiant.apps.caas.fr](https://argocd-nom-etudiant.apps.caas.fr)`**.
Tu pourras t'y connecter avec l'utilisateur `admin` et le mot de passe en clair ("P@ssword123!" dans notre exemple).

