# Mise en place de l'autoscaling dans Kubernetes

### Introduction


**Qu'est-ce que l'autoscaling?**

L'autoscaling est une technique qui permet d'ajuster automatiquement les ressources informatiques en fonction de la demande. 

Dans le contexte de Kubernetes, l'autoscaling permet de :

- Ajouter ou supprimer des Pods (unité de déploiement de Kubernetes) en fonction de l'utilisation des ressources.

- Ajouter ou supprimer des nœuds (machines physiques ou virtuelles) dans le cluster pour répondre aux besoins de capacité.

**Pourquoi est-ce important dans Kubernetes?**

- Optimisation des coûts : Réduire les coûts en ajustant dynamiquement les ressources en fonction de la demande réelle.

- Haute disponibilité : Assurer que les applications restent disponibles et performantes en augmentant les ressources en cas de pics de charge.

- Gestion efficace des ressources : Éviter le sur-provisionnement ou le sous-provisionnement des ressources.
    

### Horizontal Pod Autoscaler (HPA)

Utilisé pour ajuster dynamiquement le nombre de pods en fonction de l'utilisation des ressources (CPU, mémoire, etc.).


```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: example-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: example-deployment
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50

```

En ligne de commande

```bash
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
```

### Cluster Autoscaler

- Ajuste le nombre de nœuds dans le cluster en fonction des besoins des pods.
  
- Nécessite une intégration avec le fournisseur de cloud (GCP, AWS, Azure, etc.).

Exemple:

Configuration pour GCP.

```yaml 

apiVersion: autoscaling.k8s.io/v1
kind: ClusterAutoscaler
metadata:
  name: cluster-autoscaler
spec:
  scaleDown:
    enabled: true
  scaleUp:
    enabled: true

```

### Vertical Pod Autoscaler (VPA)

VPA n'est pas natif à kubernetes il faut installer un contrôleur

<https://github.com/kubernetes/autoscaler.git>

Ajuste les ressources allouées à un pod en fonction de l'utilisation réelle.

Contrairement à l'Horizontal Pod Autoscaler (HPA), qui ajuste le nombre de pods, le VPA ajuste les ressources des pods existants.

Pourquoi utiliser le VPA ?

- Optimisation des ressources : Ajuste dynamiquement les ressources pour éviter le surprovisionnement et le - sous-provisionnement.
- Simplification de la gestion des ressources : Évite aux administrateurs de devoir ajuster manuellement les ressources allouées aux pods.
- Amélioration des performances : Assure que les pods ont suffisamment de ressources pour fonctionner efficacement, même avec des charges de travail variables.


```yaml 
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: example-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       example-deployment
  updatePolicy:
    updateMode: "Auto"
```


