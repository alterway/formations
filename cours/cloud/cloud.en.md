# Cloud, overview

## Formal definition

### Specifications

Provide one or more service(s)...

- Self service
- Through the network
- Sharing resources
- Fast elasticity
- Metering

Inspired by the NIST definition <https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-145.pdf>

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
- *Tenant* or *project*: logical isolation of resources
- Resources are available in large quantities (considered unlimited) but resources usage is not visible
- Accurate location of resources is not visible

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

![IaaS - PaaS - SaaS (source: Wikipedia)](images/cloud.png)

### Public or private cloud?

Who is it for?

- Public: everyone, available on internet
- Private: to an organization, available on its network

### Hybrid cloud

- Usage of multiple public and/or private clouds
- Attractive concept but implementation is hard *a priori*
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
-   Resources are represented in the HTTP responses' body

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

- Consider IT resources as service provider resources
- Shift the "investment" budget (Capex) to the "operation" budget (Opex)
- Cut costs by sharing resources, and maybe with economies of scale
- Reduce delivery times
- Match costs to the real usage of resources

### Why cloud? technical point of view

- Abstract from the lower layers (server, network, OS, storage)
- Get rid of the technical administration of resources and services (DB, firewalls, load-balancing, etc.)
- Design infrastructures which can scale on the fly
- Act on resources through lines of code and manage infrastructures "as code"

## Market

### Amazon Web Services (AWS), leader

![AWS logo](images/aws.png){height=50px}

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

![OpenStack logo](images/openstack.png){height="100px"}

- Was born in 2010
- OpenStack Foundation since 2012
- Written in Python and distributed under Apache 2.0 license
- Large support from the industry and various contributions

### Public PaaS examples

-   Amazon Elastic Beanstalk (<https://aws.amazon.com/fr/elasticbeanstalk>)
-   Google App Engine (<https://cloud.google.com/appengine>)
-   Heroku (<https://www.heroku.com>)

### Private PaaS solutions

-   Cloud Foundry, Foundation (<https://www.cloudfoundry.org>)
-   OpenShift, Red Hat (<https://www.openshift.org>)
-   Solum, OpenStack (<https://wiki.openstack.org/wiki/Solum>)

## Infrastructure as a Service concepts

### Basics

- Infrastructure:
    - Compute
    - Storage
    - Network

### *Compute* resources

- Instance
- Image
- Flavor
- Keypair (SSH)

### Instance

- Dedicated to compute
- Short typical lifetime, to be considered ephemeral
- Should not store persistent data
- Non persistent root disk
- Based on an image

### Cloud image

- Disk image containing an already installed OS
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
-   This public key is used to give SSH access to the instances

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

### Shared storage?

- Block storage is **not** a shared storage solution like NFS
- NFS is at a higher layer: file system
- A volume is *a priori* connected to a single host

### "Boot from volume"

Starting an instance with its root disk on a **volume**

- Root disk data persistence
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
- There are also orchestration *tools* (rather than *services*)

## Usage best practices

### Why best practices?

Two differents possible views:

- Don't change anything
  - Risk not meeting expectations
  - Limit usage to *test & dev* use case
- Adapt to new cloud compliant practices to take advantage of it

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

Cf. <https://12factor.net/>

## Behind cloud

### How to implement a Compute service

- Virtualization
- (system) Containers
- Bare metal

### Storage implementation: (Software Defined Storage) SDS

- **Warning**: not to be confused with the block vs object topic

- Use of commodity hardware
- No hardware RAID
- Software is responsible for the data
- Hardware failures are taken into account and managed
- The **Ceph** project and the **OpenStack Swift** component implement SDS
- See also **Scality**

### SDS - CAP theorem

![Consistency - Availability - Partition tolerance](images/cap.jpg)

