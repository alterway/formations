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
