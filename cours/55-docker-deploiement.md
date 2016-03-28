# Docker en production

### Où déployer ?

- Cloud public:
    - GCE
    - AWS

![](images/docker/aws.png){height="100px"} ![](images/docker/gce.png){height="100px"}

- Cloud privée: OpenStack

![](images/docker/openstack.png){height="100px"}

- Bare Metal

### Comment ?

- Utilisation de COE (Container Orchestration Engine)

- Utilisation d'infrastructure as code

- Utilisation d'un *Discovery Service*

### Container Orchestration Engine

- Gestion du cycle de vie des conteneurs/applications

- Abstraction des hôtes et des cloud providers (clustering)

- Scheduling en fonction des besoins de l'application

- Quelques exemples:
    - Etcd/Fleet (CoreOS)
    - Docker Swarm
    - Rancher
    - Mesos / Kubernetes (K8s)

### Infrastructure as a Code

- Version Control System

- Intégration / Déploiement Continue

- Outils de templating (Heat, Terraform, Cloudformation)

![](images/docker/terraform.png){height="100px"} ![](images/docker/cloudformation.jpg){height="100px"} ![](images/docker/heat.png){height="100px"}

### Discovery Service

- La nature éphémère des conteneurs empêche toute configuration manuelle

- Connaître de façon automatique l'état de ses conteneurs à tout instant

- Fournir un endpoint fixe a une application susceptible de bouger au sein d'un cluster

### Etcd/Fleet

- Etcd:
    - Distributed key-Value store (KV store)
    - Résilient de par sa construction, l'information est répliquée et une défaillance du master n'impact pas les données
    - [Github](https://github.com/coreos/etcd)
- Fleet:
    - Clustering minimaliste d'hôte supportant systemd
    - Positionnement intelligent des units en fonction des besoins

- [Github](https://github.com/coreos/etcd)

![](images/docker/etcd.png){height="100px"}

### Etcd/Fleet

- Exemple :

```
[Unit]
Description=Apache-sidekick
BindsTo=apache.service
After=apache.service

[Service]
ExecStart=/bin/sh -c "while true; do etcdctl set /services/website/apache '{\"host\": \"%H\", \"port\": 80}' --ttl 60; sleep 45;done"
ExecStop=/usr/bin/etcdctl rm /services/website/apache

[X-Fleet]
MachineOf=apache.service
```

### Consul

- Combinaison de plusieurs services : KV Store, DNS, HTTP

- Failure detection

- Datacenter aware

- [Github](https://github.com/hashicorp/consul)

![](images/docker/consul.png){height="100px"}

### Consul

Exemple :

```
$ curl -X PUT -d 'docker' http://localhost:8500/v1/kv/container/key1
true
$ curl http://localhost:8500/v1/kv/container/key1 | jq .
[
  {
    "CreateIndex": 5,
    "ModifyIndex": 5,
    "LockIndex": 0,
    "Key": "container/key1",
    "Flags": 0,
    "Value": "ZG9ja2Vy"
  }
]
$ echo ZG9ja2Vy | base64 -d
docker
```

### Consul

- L'enregistrement des nouveaux conteneurs peut être automatisé

- *Registrator* est un process écoutant le daemon Docker et enregistrant les évènements

- [ Schéma avec registrator ]

### Rancher

- Permet de provisionner et mutualiser des hôtes Docker sur différents Cloud Provider

- Fournit des fonctionnalité de COE :
    - Cattle : COE développé par Rancher
    - Kubernetes : COE développé par Google

- Bon compromis entre simplicité et fonctionnalités comparé à Mesos ou Kubernetes

- Encore jeune, adapté aux environnement de taille moyenne (problèmes de passage a l'échelle)
![](images/docker/rancher.png){height="100px"}

### Apache Mesos / Marathon

- Mesos : Gestion et orchestration de systèmes distribués

- A la base orienté Big Data (Hadoop, Elasticsearch...) et étendu au conteneurs via Marathon

- Marathon : Scheduler pour Apache Mesos orienté conteneur

- Multi Cloud/Datacenter

- Adapté aux gros environnements, éprouvé jusque 10000 nodes

![](images/docker/mesos.png){height="100px"}

### Kubernetes (K8s)

- COE développé par Google, devenu open source en 2014

- Utiliser par Google pour la gestion de leurs conteneurs

- Adapté à tout type d'environnements

- Devenu populaire en très peu de temps

![](images/docker/kubernetes.png){height="100px"}

### Quelques autres

- Hashicorp Nomad

- Amazon Container Engine

- Docker Cloud

- Docker UCP (Universal Control Plane)

