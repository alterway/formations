# Using OpenStack

### Principle

- All the features are available through the API
- Clients (including Horizon) go through the API
- Credentials are required, with the OpenStack API:
  - user
  - password
  - project (tenant)
  - domain

### OpenStack APIs

- One API per OpenStack service
  - Versioned, backwards compatiblity is guaranteed
  - Body of requests and responses is formatted with JSON
  - REST architecture
- Managed resources are specific to a project

<https://developer.openstack.org/#api>

### API access

- Direct, using HTTP, with tools like curl
- With a library
  - Official implementations in Python
  - OpenStackSDK
  - Other implementations, including for other languages (example: jclouds)
  - Shade (Python library which includes business logic)
- With official command line tools
- With Horizon
- Through higher-level third-party tools (example: Terraform)

### Official clients

- OpenStack provides official clients
  - Historically: `python-PROJECTclient` (Python library and CLI)
  - Today: `openstackclient` (CLI)
- CLI tools
  - Authentication is done by passing credentials as parameters, environment variables or configuration file
  - The `--debug` parameter shows the HTTP connection

### OpenStack Client

- Unified CLI client
- *openstack \<resource \>\<action \>* commands (interactive shell available)
- Aims at replacing specific CLI clients
- Provides a more homogeneous user experience
- `clouds.yaml` configuration file

<https://docs.openstack.org/python-openstackclient/latest/configuration/index.html#clouds-yaml>

## Keystone: Authentication, authorization and service catalog

### Principles

Keystone is responsible for authentication and authorization and service catalog.

- Standard user authenticates against Keystone
- Admin user often interacts with Keystone

### API

- API v3: port 5000
- Manages:
  - **Users**, **groups**
  - **Projects** (tenants)
  - **Roles** (link between user and project)
  - **Domains**
  - **Services** and **endpoints** (service catalog)
- Provides:
  - **Tokens** (authentication tokens)

### Service catalog

- For each service, multiple endpoints are possible depending on:
  - region
  - interface type (public, internal, admin)

### Typical usage scenario

![Interactions with Keystone](images/keystone-scenario.png)

## Nova: Compute

### Principles

- Mainly manages **instances**
- Instances are created from images provided by Glance
- Instances' network interfaces are associated with Neutron ports
- Block storage can be provided to instances by Cinder

### Instance properties

- Ephemeral, a priori not HA
- Defined by a flavor
- Built from an image
- Optional: volume attachments
- Optional: boot from volume
- Optional: public SSH key
- Optional: network ports

### API

Managed resources:

- **Instances**
- **Flavors** (instance types)
- **Keypairs**: resources dedicated to each user (not part of a project)

### Actions on instances

- Reboot / shutdown
- Snapshot
- Logs
- VNC access
- Resize
- Migration (admin)

## Glance: Image registry

### Principles

- Image (and snapshot) registry
- Image properties

### API

- API v2: current version, manages images and snapshots
- API artifacts: future version, more common

### Image types

Glance supports a wide range of image types, limited by Nova's underlying technology support

- raw
- qcow2
- ami
- vmdk
- iso

### Image properties in Glance

The user can define a number of properties among which some will be used at instance creation

- Image type
- Architecture
- Distribution
- Distribution version
- Minimum disk space
- Minimum RAM

### Image sharing

- Public image: available to all projects
  - By default, only the admin can make an image public
- Shared image: available to one or multiple other project(s)

### Downloading images

Most OS provide regularly updated images:

- Ubuntu : <https://cloud-images.ubuntu.com/>
- Debian : <https://cdimage.debian.org/cdimage/openstack/>
- CentOS : <https://cloud.centos.org/centos/>

## Neutron: Network

### API

The API exposes these main resources:

- Network: layer 2
- Subnet: layer 3
- Port: can be attached to an instance interface, a load-balancer, etc.
- Router
- Floating IP, security group

### Floating IPs

- In addition to *fixed IPs* which are set on instances
- *Allocation* (reservation for the project) of an IP from a *pool*
- *Association* of an allocated IP to a port (of an instance, for example)
- Not directly set on instances

### Security groups

- Similar to a firewall in front of each instane
- An instance can be associated to one or multiple security groups
- Ingress and egress access rules
- Rules per protocol (TCP/UDP/ICMP) and port
- Targets an IP address, a network or another security group

### Additional features

Beyond the basic L2 and L3 networking features, Neutron may provide other services:

- Load Balancing
- Firewall: different from security groups
- VPN: to reach a private network without floating IPs
- QoS

## Cinder: Block storage

### Principles

- Provides volumes (block storage) that can be attached to instances
- Manages different volume types
- Manages volume snapshots and volume backups

### Usage

- Additional volume (and persistent storage) on an instance
- Boot from volume: OS is on the volume
- Backup to object store (Swift ou Ceph) feature

## Heat: Orchestration

### Principles

- Heat is the native OpenStack solution, orchestration *service*
- Heat provides an API to manage **stacks** from **templates**
- A Heat template follows the HOT (*Heat Orchestration Template*) format, based on YAML

### A Heat Orchestration Template (HOT) template

*parameters* - *resources* - *outputs*

```yaml
heat_template_version: 2013-05-23
description: Simple template to deploy a single compute instance
resources:
my_instance:
  type: OS::Nova::Server
  properties:
  key_name: my_key
  image: F18-x86_64-cfntools
  flavor: m1.small
```

### Build a template from existing resources

Multiple projects are being developed

- Flame (Cloudwatt)
- HOT builder
- Merlin

## Horizon : web dashboard

### Principles

- Provides a web interface
- Uses existing APIs to provide a user interface
- Ability to log in without specifiying a project: Horizon determines the list of available projects

### Usage

- One interface per project (ability to switch)
- Availability of the service catalog
- Download of a `clouds.yaml` config file
- Restricted “admin” area

