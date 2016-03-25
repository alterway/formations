# Docker en production

### Infrastructure as a Code

- Version Control System

- Intégration Continue

### Où déployer ?

- ECS

- Rancher

- Mesos

- Kubernetes

- Fleet

### Discovery Service

- La nature ephémère des conteneurs empêche toute configuration manuelle

- Un discovery service permet de connaître de façon automatique l'état de ses
  conteneurs à tout instant

### etcd

- Distributed key-Value store (KV store)

- Résilient de par sa construction, l'information est repliquée et une
  défaillance du master n'impact pas les données

- [](https://github.com/coreos/etcd)

### etcd

Exemple :
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

- [](https://github.com/hashicorp/consul)

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

- L'enregistement des nouveaux conteneurs peut être automatisé

- Registrator est un process écoutant le daemon Docker et enregistrant les évènements

- [ Schéma avec registrator ]

### Rancher
