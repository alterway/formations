# Cloud, overview

## Formal definition

### Specifications

Provide one or more service(s)...

- Self service
- Through the network
- Sharing resources
- Fast elasticity
- Metering

Inspired by the NIST definition <http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-145.pdf>

### Self service

- User goes *directly* to the service
- No humain intermediary
- Immediate responses
- Services catalog for their discovery

### Through the network

- User uses the service through the network
- The service *provider* is remote to the *consumer*
- Network = internet or not
- Usage of standard network protocols (typically: HTTP)

### Sharing ressources

- A cloud provided services to multiple users/organizations → *Multi-tenant*
- Resources are available in large quantities
- Accurate location and resources usage rate are not visible

### Fast elasticity

- Provisionning and deletion of resources almost instantaneous
- Ability to automate *scaling* actions
- Virtually no limit to this elasticity

### Metering

- Usage of cloud resources is monitored by the provider
- The provider can do *capacity planning* from these informations
- User is billed depending on accurate usage of resources

### Models

- service models: IaaS, PaaS, SaaS
- deployment models: public, private, hybrid

### IaaS

- *Infrastructure as a Service*
- Infrastructure:
    - Compute
    - Storage
    - Network
- Target users: administrators (system, storage, network)

### PaaS

- *Platform as a Service*
- Development/deployment environment of an application
- Language/framework specific (example: Python/Django)
- Higher level resources than infrastructure, example: DBMS
- Target users: application developers

### SaaS

- *Software as a Service*
- Target users: end users

### Something as a Service?

- Load balancing as a Service (Infra)
- Database as a Service (Platform)
- MyApplication as a Service (Software)
- etc.

### Service models in one diagram

![IaaS - PaaS - SaaS](images/cloud.png)

### Public or private cloud?

Who is it for?

- Public: everyone, available on internet
- Private: to an organization, available on its network

### Hybrid cloud

- Usage of multiple public and/or private clouds
- Attractive concept
- Implement is hard *a priori*
- Some use cases fit perfectly
    - Continuous integration (CI)
    - *Cloud bursting*

### Virtualization instant

Let's make it clear.

- Virtualization is a technology that can implement the *compute* function
- A cloud providing compute resources *can* use virtualization
- But it can also use:
    - Bare-metal
    - Containers

### APIs are key

- Reminder: API stands for *Application Programming Interface*
    -   In the software sense: Interface for a program to use a library
    -   In the cloud sense: Interface for a program to use a service (XaaS)
- Programming interface (through the network, often HTTP)
- Explicit boundary between the provider and the user
- Defines how the user interacts with the cloud to manage their resources
- Manages: CRUD (Create, Read, Update, Delete)
- REST

### REST

-   One ressource == one URI (*Uniform Resource Identifier*)
-   Usage of HTTP verbs to define operations (CRUD)
    - GET
    - POST
    - PUT
    - DELETE
-   Usage of HTTP return codes
-   Resources are reprensented in the HTTP responses' body

### REST - Examples

    GET http://endpoint/volumes/
    GET http://endpoint/volumes/?size=10
    POST http://endpoint/volumes/
    DELETE http://endpoint/volumes/xyz

### Real example

    GET /v2.0/networks/d32019d3-bc6e-4319-9c1d-6722fc136a22
    {
       "network":{
          "status":"ACTIVE",
          "subnets":[ "54d6f61d-db07-451c-9ab3-b9609b6b6f0b" ],
          "name":"private-network",
          "provider:physical_network":null,
          "admin_state_up":true,
          "tenant_id":"4fd44f30292945e481c7b8a0c8908869",
          "provider:network_type":"local",
          "router:external":true,
          "shared":true,
          "id":"d32019d3-bc6e-4319-9c1d-6722fc136a22",
          "provider:segmentation_id":null
       }
    }

### Why cloud? economical point of view

- Appréhender les ressources IT comme des services “fournisseur”
- Faire glisser le budget “investissement” (Capex) vers le budget
“fonctionnement” (Opex)
- Réduire les coûts en mutualisant les ressources, et éventuellement avec des économies d'échelle
- Réduire les délais
- Aligner les coûts sur la consommation réelle des ressources

### Why cloud? technical point of view

- Abstraire les couches basses (serveur, réseau, OS, stockage)
- S’affranchir de l’administration technique des ressources et services (BDD, pare-feux, load-balancing, etc.)
- Concevoir des infrastructures scalables à la volée
- Agir sur les ressources via des lignes de code et gérer les infrastructures “comme du code”

## Market

### Amazon Web Services (AWS), leader

![](images/aws.png){height=50px}

- Started in 2006
- At first: "e-commerce" web services for developers
- Then: other services for developers
- And finally: infrastructure resources
- Recently, SaaS

### Public IaaS alternatives to AWS

- **Google Cloud Platform**
- **Microsoft Azure**
- Rackspace
- DreamHost
- DigitalOcean
- In France:
    - Cloudwatt (Orange Business Services)
    - Numergy (SFR)
    - OVH
    - Ikoula
    - Scaleway
    - Outscale

### Private IaaS

- **OpenStack**
- CloudStack
- Eucalyptus
- OpenNebula

### OpenStack in a few words

![](images/docker/openstack.png){height="100px"}

- Was born in 2010
- OpenStack Foundation since 2012
- Written in Python and distributed under Apache 2.0 license
- Large support from the industry and various contributions

### Public PaaS examples

-   Amazon Elastic Beanstalk (<https://aws.amazon.com/fr/elasticbeanstalk>)
-   Google App Engine (<https://cloud.google.com/appengine>)
-   Heroku (<https://www.heroku.com>)

### Private PaaS solutions

-   Cloud Foundry (<https://www.cloudfoundry.org>)
-   OpenShift (<http://www.openshift.org>)
-   Solum (<https://wiki.openstack.org/wiki/Solum>)

## Infrastructure as a Service concepts

### Basics

- Infrastructure:
    - Compute
    - Storage
    - Network

### *compute* resources

- Instance
- Image
- Flavor
- Keypair (SSH)

### Instance

- Ephemeral, short typical lifetime
- Dedicated to compute
- Should not store persistent data
- Non persistent root disk

### Cloud image

- Disk image containing and already installed OS
- Infinitely instanciable
- Can talk to the metadata API

### Metadata API

- `http://169.254.169.254`
- Available from the instance
- Provides informations about the instance
- `cloud-init` helps take advantage of this API

### Flavor

-   *Instance type* in AWS
-   Defines an instance model regarding CPU, RAM, disk (root), ephemeral disk
-   The ephemeral disk has, like the root disk, the advantage of often being local and thus fast

### Keypair

-   SSH public key + private key
-   Cloud manages and stores the public key
-   This public key is used to give SSH acceéss to the instances

### Network resources 1/2

- L2 network
    - Network port
- L3 network
    - Router
    - Floating IP
    - Security group

### Network resources 2/2

- Load Balancing as a Service
- VPN as a Service
- Firewall as a Service

### Storage resources

Cloud provides two kinds of storage

- Block
- Object

### Block storage

- **Volumes** that can be attached to an instance
- Access to raw devices such as */dev/vdb*
- Ability to use any kind of file system
- Ability to use LVM, encryption, etc.
- Compatible with all existing applications

### "Boot from volume"

Starting an instance with its root disk on a **volume**

- Root disk data peristence
- Gets similar to classical server

### Object storage

- Push and retrieve objects in/from a container/bucket
- No data hierachy, no file system
- API access
- Application must be designed to take advantage of object storage

### Orchestration

- Orchestrate creation and management of resources in the cloud
- Architecture definition in a *template*
- Resources created from a *template* make a *stack*

## Usage best practices

### High availability (HA)

- Cloud control plane (APIs) is HA
- Managed resources might not be

### Pets vs Cattle

How to consider instances?

- Pet
- Cattle

### Infrastructure as Code

With code

- Provision infrastructure resources
- Configure said resources, instances in particular

The job is changing: Infrastructure Developer

### Scaling

- Scale out rather than Scale up
    - Scale out: horizontal scaling
    - Scale up: vertical scaling
- Auto-scaling
    - Managed by the cloud
    - Managed by an external component

### Cloud ready applications

- Store their data in an appropriate place
- Are architected to be fault tolerant
- Etc.

Cf. <http://12factor.net/>

## Derrière le cloud

### Comment implémenter un service de Compute

- Virtualisation
- Containers
- Bare metal

### Implémentation du stockage : (Software Defined Storage) SDS

- **Attention** : ne pas confondre avec le sujet block vs objet

- Utilisation de commodity hardware
- Pas de RAID matériel
- Le logiciel est responsable de garantir les données
- Les pannes matérielles sont prises en compte et gérées
- Le projet **Ceph** et le composant **OpenStack Swift** implémentent du SDS
- Voir aussi **Scality**

### SDS - CAP theorem

![Consistency - Availability - Partition tolerance](images/cap.jpg)

