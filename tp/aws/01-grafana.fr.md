# TP 01

## But

Rendre l'application Grafana déployée dans le précédent TP hautement disponible
et scalable horizontalement.

## Exercice

### EC2

Faire une image (AMI) de l'instance EC2 avec Grafana fonctionnel (TP
précédent).

Créer un __Launch Template__ en utilisant l'AMI créée avec les mêmes
caractéristiques que l'instances EC2 Grafana que le TP 00.

Créer un autoscaling group (ASG) avec comme Laucnh Template celui précédemment
créé et ajouter cet ASG dans le target group `awcc-tp-webapp`.

Stopper l'instance EC2 lancée dans le TP précédent et ne laisser tourner que
les instances EC2 lancées par l'ASG.

### Schéma d'architecture

![](../../images/aws-tp-01.png)

## Résultat

Grafana doit être accessible sur le endpoint Route 53, redirigé de HTTP vers
HTTPS automatiquement.
Si vous terminez toutes les instances EC2 Grafana, l'application doit se
remonter toute seule grace à l'ASG.
