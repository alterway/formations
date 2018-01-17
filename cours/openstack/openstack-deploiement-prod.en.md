# OpenStack in production and operations

## Best practices for a production deployment

### Which components shoud I install?

-   Keystone is mandatory
-   Use of Nova goes with Glance and Neutron
-   Cinder will often be useful
-   Ceilometer and Heat often go together
-   Swift is separate from other components
-   Neutron may be used separately (ex: with oVirt)

<http://docs.openstack.org/arch-design/>

### Think about fundamental choices at the beginning

-   Distribution and deployment method
-   Hypervisor
-   Network: what architecture and what drivers
-   Update and upgrade policy

### Different installation methods

-   Forget about DevStack for production
-   TripleO is very complex
-   Manual deployment as seen previously is not recommended by unmaintainable
-   Packaged and ready to use OpenStack distributions
-   Classical distributions and configuration management
-   Continuous deployment

### Major upgrades

-   OpenStack supports N $\rightarrow$ N+1 upgrades
-   Swift: very good *rolling upgrade* support
-   Other components: test with you data first
-   Read release notes
-   Cf. CERN blog posts <https://openstack-in-production.blogspot.fr/>

### Stable updates

-   Major bug and security fixes are provided
-   OpenStack includes these fixes as patches in the stable branch
-   *Point releases* are published and includes fixes from the stable branch
-   Stable version support timeframe is variable, depending on integrators' interest

### Assign roles to machines

Lots of documentations mention these roles:

-   Controller node: APIs, DB, AMQP
-   Network node: DHCP, router, floating IPs
-   Compute node: Hypervisor/instances management

This simplified model is not HA.

### High Availability

IaaS High Availability

-   MySQL/MariaDB, RabbitMQ: classical HA (Galera, Clustering)
-   API services Are stateless and HTTP: scale out and load balancers
-   Most other OpenStack services are able to scale out as well

HA guide: <http://docs.openstack.org/ha-guide/>

### High availability of the Neutron L3 agent

-   *Distributed Virtual Router* (DVR)
-   L3 agent HA (VRRP)

### Production environment concerns

-   Uniform URLs for all the APIs: use a reverse proxy
-   Apache/mod\_wsgi to service APIs when possible (Keystone)
-   Quotas usage
-   Plan for the appropriate capacities, in particular for Ceilometer data
-   Monitoring
-   Backup

Operations guide: <http://docs.openstack.org/openstack-ops/content/>

### Quotas usage

-   Limit the number of allocable resources
-   Per user or per tenant
-   Support in Nova
-   Support in Cinder
-   Support in Neutron

<http://docs.openstack.org/user-guide-admin/content/cli_set_quotas.html>

### Networks

-   Management network: administrative network
-   Data network: network for inter instances traffic
-   External network: external network, in the existing network infrastructure
-   API network: network containing API endpoints

### Security related concerns

-   Must-have: HTTPS for external API access
-   Securing MySQL/MariaDB and RabbitMQ traffic
-   One MySQL/MariaDB access per database and per service
-   One Keystone user per service
-   Limit read permissions to configuration files (passwords, token)
-   Security vulnerabilities: OSSA (*OpenStack Security Advisory*), OSSN (*... Notes*)

Security guide: <http://docs.openstack.org/security-guide/>

### Segment its cloud

-   Host aggregates: physical hosts with similar features
-   Availability zones: hosts depending on the same electrical supply, same switch, same DC, etc.
-   Regions: each region has its own API
-   Cells: gather multiple clouds within a unique API

<http://docs.openstack.org/openstack-ops/content/scaling.html#segregate_cloud>

### Host aggregates

-   Nova specific
-   Admin defines host aggregates through the API
-   Admin associates flavors and aggregates through common key/values
-   1 aggregate $\equiv$ 1 similarity, ex: GPU
-   User chooses an aggregate through their flavor choice when creating an instance

### Availability zones

-   Nova and Cinder specific
-   Hosts groups
-   Split in terms of availability: Rack, Datacenter, etc.
-   User chooses an availability zone when creating an instance
-   Use can request instances to be started in the same zone, or on the contrary in different zones

### Regions

-   Generic in OpenStack
-   AWS regions counterpart
-   A service can have different endpoints in different regions
-   Each region is autonomous
-   Use case: very large cloud (such as some public clouds)

### Cells

-   Nova specific
-   Only one nova-api in front of mutiple cells
-   Each cell has its own DB and message bus
-   Adds a scheduling layer (cell choice)

### OpenStack packaging - Ubuntu

-   Packaging is done in multiples distributions, RPM, DEB and others
-   Ubuntu historically is the reference platform for OpenStack developement
-   Packaging in Ubuntu closely follows OpenStack development, and automated tests are performed
-   Canonical provides the Ubuntu Cloud Archives, which includes the latest OpenStack version for the latest Ubuntu LTS

### Ubuntu Cloud Archive (UCA)

![OpenStack support in Ubuntu through UCA](images/ubuntu-cloud-archive.png)

### OpenStack packaging in other distributions

-   OpenStack is integrated in Debian's official repository
-   Red Hat provides RHOS/RDO (deployment based on TripleO)
-   Like Ubuntu, Fedora's release cycle is synchronized with OpenStack's

### OpenStack distributions

-   StackOps: history
-   Mirantis: Fuel
-   HP Helion: Ansible custom
-   etc.

### Bare metal deployment

-   OpenStack bare metal hosts deployment can be managed with the help of dedicated tools
-   MaaS (Metal as a Service), by Ubuntu/Canonical: works with Juju
-   Crowbar / OpenCrowbar (initially Dell): uses Chef
-   eDeploy (eNovance): image based deployment
-   Ironic through TripleO

### Configuration management

-   Puppet, Chef, CFEngine, Saltstack, Ansible, etc.
-   These tools can help deploying an OpenStack cloud
-   ... but also to manage instances (next section)

### Modules Puppet, Playbooks Ansible

-   *Puppet OpenStack* and *OpenStack Ansible*: Puppet modules and Ansible playbooks
-   Developed as part of the OpenStack project
-   <https://wiki.openstack.org/wiki/Puppet>
-   <http://docs.openstack.org/developer/openstack-ansible/install-guide/>

### Continuous deployment

-   OpenStack maintains an always stable master (trunk)
-   Possible to deploy `master` on a daily basis (CD: *Continous Delivery*)
-   Requires setting up an important infrastructure
-   Eases upgrades between major versions

## Facing issues

### Issues: FAILED/ERROR resources

-   Multiple possible causes
-   Ability to delete the ressource?
-   The *reset-state* API call can help

### Tips in case of error or faulty behavior

-   Are we working on the appropriate tenant?
-   Is the API responding with an error? (the dashboard may hide some informations)
-   If going further is required:
    -   Look into logs on thje cloud controller (/var/log/\<composant\>/\*.log)
    -   Look into logs on the compute node and the network node if the issue is network/instance specific
    -   May change logs verbosity in the configuration

### Is it a bug?

-   If the CLI client crashes, it's a bug
-   If the web dashboard or the API responds with an error 500, it might be a bug
-   If the logs show a Python stacktrace, it's a bug
-   Otherwise, you decide

## Operations

### Expand Neutron CIDR

### Nova compute maintenance mode

### Logs management

### Backup

### Monitoring

