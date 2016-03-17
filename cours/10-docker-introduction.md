# Le Cloud : vue d’ensemble

### Le cloud, c’est large !

- Stockage/calcul distant (on oublie, cf. externalisation)

- Virtualisation++

- Abstraction du matériel (voire plus)

- Accès normalisé par des APIs

- Service et facturation à la demande

- Flexibilité, élasticité

### WaaS : Whatever as a Service

- IaaS : Infrastructure as a Service

- PaaS : Platform as a Service

- SaaS : Software as a Service

### Le cloud en un schéma

![](images/cloud.png){height="400px"}

### Pourquoi du cloud ? Côté technique

- Abstraction des couches basses

- On peut tout programmer à son gré (API)

- Permet la mise en place d’architectures scalables

### Virtualisation dans le cloud

- Le cloud IaaS repose souvent sur la virtualisation

- Ressources compute -> virtualisation

- Virtualisation complète : KVM, Xen

- Virtualisation conteneurs : OpenVZ, LXC, Docker, RKT

### Notions et vocabulaire IaaS

- L’instance est par définition éphémère

- Elle doit être utilisée comme ressource de calcul

- Séparer les données des instances

### Orchestration des ressources ?

- Groupement fonctionnel de ressources : micro services

- Infrastructure as Code : Définir toute une infrastructure dans un seul fichier texte de manière déclarative

- Scalabilité : passer à l'échelle son infrastructure en fonction de différentes métriques.

### Positionnement des conteneurs dans l'écosystème Cloud ?

- Facilitent la mise en place de PaaS

- Fonctionnent sur du IaaS ou sur du bare-metal

- Simplifient la décomposition d'applications en micro services

