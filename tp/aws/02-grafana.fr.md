# TP 02

## But

Monitorer Grafana et le cluster RDS.

## Exercice

### IAM

Créer un role IAM pour instance EC2 avec la policy managée
`CloudWatchReadOnly` avec comme nom `awcc-tp-webserver`.

### EC2

Créer une nouvelle version du launch template webserver en attachant le role
IAM précédemment créé.

Mettre à jour l'ASG poru utiliser la nouvell eversion du launch template et
faire un rolling update des instances.

### Grafana

Vérifier que la datasource CloudWatch (Use Credential file) fonctionne (bien
préciser la région où est déployée l'infra).

Créer un dashboard avec des graphs pour monitorer l'application Grafana (voir
les métriques à monitorer dans la documentation de chaque service).

## Résultat

Un dashboard Grafana complet monitorant les erreurs côté ALB/target group, le
CPU moyen des instancesde l'ASG, les métriques RDS et en bonus un healthcheck
sur l'endpoint de votre application afin de vérifier sa disponibilité depuis
internet (Route 53 healthcheck et graph Grafana).


## Bonus

Ajouter un Alert Channel Slack et créer des seuils d'alerte lançant des alertes
sur Slack.
