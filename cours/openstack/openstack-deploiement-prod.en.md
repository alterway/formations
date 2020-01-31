# OpenStack in production and operations

## Best practices for a production deployment

### Which components shoud I install?

-   Keystone is mandatory
-   Use of Nova goes with Glance and Neutron
-   Cinder and Swift usefulness depends on storage needs
-   Swift can be used separately from other components
-   Heat doesn't cost much
-   Higher level services need to be evaluated case by case

<https://docs.openstack.org/arch-design/>

### Think about fundamental choices at the beginning

-   Distribution and deployment method
-   Update and upgrade policy
-   Drivers/backends: hypervisor, block storage, etc.
-   Network: what architecture and what drivers

### Different installation methods

-   Forget about DevStack for production
-   Manual deployment as seen previously is not recommended by unmaintainable
-   Packaged and ready to use OpenStack distributions
-   Classical distributions and configuration management
-   Continuous deployment

### Major upgrades

-   OpenStack supports N $\rightarrow$ N+1 upgrades
-   Swift: very good *rolling upgrade* support
-   Other components: test with you data first
-   Read release notes
-   Cf. CERN blog posts <https://techblog.web.cern.ch/techblog/>

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

HA guide: <https://docs.openstack.org/ha-guide/>

Talks by Florian Haas, Hastexo: <https://www.openstack.org/community/speakers/profile/398/florian-haas>

### High availability of the Neutron L3 agent

-   *Distributed Virtual Router* (DVR)
-   L3 agent HA (VRRP)

### APIs concerns

-   Uniform URLs for all the APIs:
    - Use a reverse proxy
    - Don't forget to update the service catalog
- Apache/mod\_wsgi to serve APIs when possible (Keystone, etc.)

Operations guide: <https://docs.openstack.org/openstack-ops/content/>

### Networks

-   Management network: administrative network
-   Data/instances network: network for inter instances traffic
-   External network: external network, in the existing network infrastructure
-   Storage network: network for Cinder/Swift storage
-   API network: network containing API endpoints

### Security related concerns

-   Must-have: HTTPS for external API access
-   Securing MySQL/MariaDB and RabbitMQ traffic
-   One MySQL/MariaDB access per database and per service
-   One Keystone user per service
-   Limit read permissions to configuration files (passwords, token)
-   Security vulnerabilities: OSSA (*OpenStack Security Advisory*), OSSN (*... Notes*)

Security guide: <https://docs.openstack.org/security-guide/>

### Segment a cloud

-   Host aggregates: physical hosts with similar features
-   Availability zones: hosts depending on the same electrical supply, same switch, same DC, etc.
-   Regions: each region has its own API
-   Cells: gather multiple clouds within a unique API

<https://docs.openstack.org/openstack-ops/content/scaling.html#segregate_cloud>

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
-   Canonical provides the Ubuntu Cloud Archive, which includes the latest OpenStack version for the latest Ubuntu LTS

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

### TripleO

-   OpenStack On OpenStack
-   Goal: ability to deploy an OpenStack cloud (*overcloud*) from an OpenStack cloud (*undercloud*)
-   Autoscaling of the cloud itself: deployment of new compute nodes when necessary
-   Works jointly with Ironic for bare metal deployment

### Bare metal deployment

-   OpenStack bare metal hosts deployment can be managed with the help of dedicated tools
-   MaaS (Metal as a Service), by Ubuntu/Canonical: works with Juju
-   Crowbar / OpenCrowbar (initially Dell): uses Chef
-   eDeploy (eNovance): image based deployment
-   Ironic through TripleO

### Tempest

-   Test suite of an OpenStack cloud
-   Makes API calls and checks the result
-   Used a lot by developers through continuous integration
-   Deployers can use Tempest to check their cloud's compliance
-   See also Rally

### Configuration management

-   Puppet, Chef, CFEngine, Saltstack, Ansible, etc.
-   These tools can help deploying an OpenStack cloud
-   ... but also to manage instances (next section)

### Modules Puppet, Playbooks Ansible

-   *Puppet OpenStack* and *OpenStack Ansible*: Puppet modules and Ansible playbooks
-   Developed as part of the OpenStack project
-   <https://wiki.openstack.org/wiki/Puppet>
-   <https://docs.openstack.org/developer/openstack-ansible/install-guide/>

### Continuous deployment

-   OpenStack maintains an always stable master (trunk)
-   Possible to deploy `master` on a daily basis (CD: *Continous Delivery*)
-   Requires setting up an important infrastructure
-   Eases upgrades between major versions

## Facing issues

### Tips in case of error or faulty behavior

-   Are we working on the appropriate project?
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

### Logs management

-   Centralize logs
-   API logs
-   Other OpenStack components logs
-   DB, AMQP, etc. logs

### Backup

-   Databases
-   Deployment mechanism, rather than configuration files

### Monitoring

-   API response
-   Checking OpenStack services and dependencies

### Quotas usage

-   Limit the number of allocable resources
-   Per user or per tenant
-   Support in Nova
-   Support in Cinder
-   Support in Neutron

