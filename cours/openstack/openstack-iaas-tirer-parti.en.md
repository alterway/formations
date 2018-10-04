# Take advantage of IaaS

### Two views

Once a IaaS cloud is in place, two possible views:

-   Keep the same practices while making use of the solution's self service and agility for test/dev needs
-   Move on to new practices, both on the application side that on the system side  “Pets vs Cattle”

### Otherwise?

Running *legacy* applications in the cloud is a bad idea:

-   Outages
-   Data loss
-   Lack of understanding "cloud doesn't work"

## Application side

### Adapt or think “cloud ready” applications 1/3

See OpenStack project design tenets and Twelve-Factor <https://12factor.net/>

-   Distributed rather than monolithic architecture
    -   Eases scaling
    -   Limits *failure* domain
-   Loose coupling between components

### Adapt or think “cloud ready” applications 2/3

-   Message bus for inter-component communication
-   Stateless: allows multiple access routes to the application
-   Dynamic: application must adapt to its environnement and reconfigure itself when necessary
-   Allow deployment and operation using automation tools

### Adapt or think “cloud ready” applications 3/3

-   Limit as much as possible hardware or software specific dependencies that may not work in a cloud
-   Integrated fault tolerance
-   Do not store data locally, but rather:
    -   Database
    -   Object storage
-   Use standard logging tools

## System side

### Adopt a DevOps philosophy

-   Infrastructure as Code
-   Scale out rather than scale up (horizontally rather than vertically)
-   HA at the application level rather than infrastructure
-   Automation, automation, automation
-   Tests

### Monitoring

-   Take into account instances' lifecycle
-   Monitor the service rather than the server

### Backup

-   Be able to recreate your instances (and the rest of the infrastructure)
-   Data (application, logs): block, object

### Use cloud images

A cloud image is:

-   Disk image containing an already installed OS
-   Image that can be instantiated as n servers without error
-   An OS that talks to the cloud metadata API (cloud-init)
-   Details: <https://docs.openstack.org/image-guide/openstack-images.html>
-   Most of the distributions provide cloud images

### Cirros

-   Cirros is a typical cloud image
-   Minimalist OS
-   Contains cloud-init

<https://launchpad.net/cirros>

### Cloud-init

-   Cloud-init is a way of taking advantage of the metadata API, especially user data
-   The tool is included by default in most cloud images
-   From user data, cloud-init performs instance personalization operations
-   cloud-config is a possible format for user data

### cloud-config example

    #cloud-config
    mounts:
     - [ xvdc, /var/www ]
    packages:
     - apache2
     - htop

### How to manage images?

-   Use of generic images and personalization at launch
-   Creation of intermediary and/or completely personalized images:
    *Golden images*
    -   libguestfs, virt-builder, virt-sysprep
    -   diskimage-builder (TripleO)
    -   Packer
    -   “home-made” solution

### Configure and orchestrate instances

-   Configuration management tools (the same ones that can deploy OpenStack)
-   Juju

