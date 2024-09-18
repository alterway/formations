Bien sûr, je vais vous guider à travers un laboratoire complet sur l'utilisation d'Argo CD. Ce laboratoire couvrira les étapes suivantes :

1. **Préparation de l'environnement**
2. **Installation d'Argo CD**
3. **Création d'un repository Git avec une application Kubernetes**
4. **Configuration d'Argo CD pour suivre le repository**
5. **Déploiement et synchronisation de l'application**
6. **Mise à jour de l'application**
7. **Gestion des accès et sécurité**
8. **Surveillance et dépannage**

### Étape 1: Préparation de l'environnement

1. **Prérequis**:
   - Un cluster Kubernetes fonctionnel. Vous pouvez utiliser Minikube, Kind, ou un cluster géré comme GKE, EKS, ou AKS.
   - `kubectl` installé et configuré pour accéder à votre cluster Kubernetes.
   - `argocd` CLI installé. Suivez les instructions ici : [Installation de la CLI Argo CD](https://argo-cd.readthedocs.io/en/stable/cli_installation/).

### Étape 2: Installation d'Argo CD

1. **Installer Argo CD dans le namespace `argocd`**:
   ```sh
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Exposez le serveur Argo CD (optionnel pour les environnements locaux)**:
   ```sh
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. **Obtenez le mot de passe initial pour l'utilisateur `admin`**:
   ```sh
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
   ```

### Étape 3: Création d'un repository Git avec une application Kubernetes

1. **Créer un repository Git**:
   - Créez un nouveau repository Git sur GitHub, GitLab, ou tout autre service de gestion de code source. Nommez-le `nginx-app`.

2. **Ajouter les fichiers de configuration Kubernetes**:
   - Clonez le repository localement et ajoutez les fichiers de configuration Kubernetes pour déployer une application Nginx.

   ```sh
   git clone https://github.com/votre-utilisateur/nginx-app.git
   cd nginx-app
   ```

   - Créez un fichier `deployment.yaml` avec le contenu suivant :

     ```yaml
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: nginx-deployment
       labels:
         app: nginx
     spec:
       replicas: 2
       selector:
         matchLabels:
           app: nginx
       template:
         metadata:
           labels:
             app: nginx
         spec:
           containers:
           - name: nginx
             image: nginx:1.14.2
             ports:
             - containerPort: 80
     ```

   - Créez un fichier `service.yaml` avec le contenu suivant :

     ```yaml
     apiVersion: v1
     kind: Service
     metadata:
       name: nginx-service
     spec:
       selector:
         app: nginx
       ports:
         - protocol: TCP
           port: 80
           targetPort: 80
       type: LoadBalancer
     ```

   - Ajoutez et poussez ces fichiers au repository Git.

     ```sh
     git add deployment.yaml service.yaml
     git commit -m "Add Nginx deployment and service"
     git push origin main
     ```

### Étape 4: Configuration d'Argo CD pour suivre le repository

1. **Accéder à l'interface utilisateur d'Argo CD**:
   - Ouvrez un navigateur web et accédez à `http://localhost:8080`.
   - Connectez-vous avec le nom d'utilisateur `admin` et le mot de passe récupéré.

2. **Ajouter le repository Git à Argo CD**:
   - Via l'interface utilisateur web :
     - Allez dans `Settings` > `Repositories` > `Connect Repo using HTTPS`.
     - Entrez l'URL du repository Git (par exemple, `https://github.com/votre-utilisateur/nginx-app.git`).
     - Si le repository est privé, fournissez les informations d'authentification nécessaires.

   - Via la CLI :
     ```sh
     argocd repo add https://github.com/votre-utilisateur/nginx-app.git --username <username> --password <password>
     ```

### Étape 5: Déploiement et synchronisation de l'application

1. **Créer une application Argo CD**:
