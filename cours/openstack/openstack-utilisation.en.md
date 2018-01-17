# Using OpenStack

### Principle

-   All the features are available through the API
-   Clients (including Horizon) go through the API
-   Credentials are required
    -   API OpenStack: user + password + project (tenant) + domain
    -   API AWS: access key ID + secret access key

### OpenStack APIs

-   One API per OpenStack service
-   Each API is versioned, backwards compatiblity is guaranteed
-   Body of requests and responses is formatted with JSON (XML used to be supported as well)
-   REST architecture
-   <https://developer.openstack.org/#api>
-   Some services are also available through a different API, compatible with AWS

### API access

-   Direct, using HTTP, with tools like curl
-   With a library
    -   Official implementations in Python
    -   OpenStackSDK
    -   Other implementations, including for other languages (example: jclouds)
    -   Shade (Python library which includes business logic)
-   With official command line tools
-   With Horizon

### Official clients

-   The project provides official clients: python-PROJECTclient
-   Python libraries
-   CLI tools
    -   Authentication is done by passing credentials as parameters or environment variables
    -   The `--debug` parameter shows the HTTP connection

### OpenStack Client

-   Unified CLI client
-   *openstack \<resource \>\<action \>* commands
-   Or interactive shell
-   Aims at replacing specific clients eventually
-   Provides a more homogeneous user experience
-   `clouds.yaml` configuration file

<https://docs.openstack.org/python-openstackclient/pike/configuration/index.html#clouds-yaml>

## Keystone: Authentication, authorization and service catalog

### Principles

-   Users and groups directory
-   Manages domains
-   Lists projects (tenants)
-   Service catalog
-   Manages authentication and authorization
-   Provides a token to the user

### Authentication and service catalog

-   Once authenticated, retrieval of a *token*
-   Retrieval of the service catalog
-   For each service, an HTTP endpoint (API)

### API

-   API v2 (deprecated): admin port 35357, user port 5000
-   API v3: port 5000
-   Manages *users*, *groups*, *domains*
-   Users have *roles* on *projects* (tenants)
-   *Services* from the catalog are associated to *endpoints*

### Typical usage scenario

![Interactions with Keystone](images/keystone-scenario.png)

## Nova: Compute

### Principles

-   Manages instances
-   Instances are created from images provided by Glance
-   Instances' network interfaces are associated with Neutron ports
-   Block storage can be provided to instances by Cinder

### Interactions with other components

![Instance, image and volume](images/compute-node.png)

### Instance properties

-   Ephemeral, a priori not HA
-   Defined by a flavor
-   Built from an image
-   Optional: volume attachments
-   Optional: boot from volume
-   Optional: public SSH key
-   Optional: network ports

### API

Manages:

-   Instances
-   Flavors
-   Keypairs
-   Indirectly: images, security groups, floating IPs

Instances can be resized and migrated from a physical host to another.

## Glance: Image registry

### Principles

-   Image (and snapshot) registry
-   Image properties
-   Is used by Nova to start instances

### API

-   API v2: current
-   API artifacts: future

### Image types

Glance supports a wide range of image types, limited by Nova's underlying hypervisor support

-   raw
-   qcow2
-   ami
-   vmdk
-   iso

### Image properties in Glance

The user can define a number of properties among which some will be used at instance creation

-   Image type
-   Architecture
-   Distribution
-   Distribution version
-   Minimum disk space
-   Minimum RAM
-   Public or not

## Neutron: Network

### API

The API exposes these main resources:

-   Network: layer 2
-   Subnet: layer 3
-   Port: can be attached to an instance interface, a load-balancer, etc.
-   Router
-   Floating IP, security group

### Floating IPs

-   IP is *allocated* from a *pool*
-   Allocated IP is *associated* to a port

### Security groups

-   Similar to a firewall in front of each instane
-   An instance can be associated to one or multiple security groups
-   Ingress and egress access rules
-   Rules per protocol (TCP/UDP/ICMP) and port
-   Targets an IP address, a network or another security group

### Additional features

Beyond the basic L2 and L3 networking features, Neutron may provide other services:

-   Load Balancing
-   Firewall: different from security groups
-   VPN: to reach a private network without floating IPs
-   QoS

## Cinder: Block storage

### Principles

-   Provides volumes (block storage) that can be attached to instances
-   Manages different volume types
-   Manages volume snapshots and volume backups

### Usage

-   Additional volume (and persistent storage) on an instance
-   Boot from volume: OS is on the volume
-   Backup to object store (Swift ou Ceph) feature

### Shared storage?

-   Cinder is **not** a shared storage solution like NFS
-   The Manila OpenStack project aims at being *NFS as a Service*
-   AWS introduced such a feature only recently

## Heat: Orchestration

### OpenStack native and alternatives

- Heat is the native OpenStack solution
- Heat provides an API to manage *stacks* from *templates*
- Alternatives external to OpenStack exist, like **Terraform**

### A Heat Orchestration Template (HOT) template

*parameters* - *resources* - *outputs*

    heat_template_version: 2013-05-23
    description: Simple template to deploy a single compute instance
    resources:
      my_instance:
        type: OS::Nova::Server
        properties:
          key_name: my_key
          image: F18-x86_64-cfntools
          flavor: m1.small

### Build a template from existing resources

Multiple projects are being developed

-   Flame (Cloudwatt)
-   HOT builder
-   Merlin

