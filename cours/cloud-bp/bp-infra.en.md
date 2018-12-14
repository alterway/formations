## Design an infrastructure for the cloud

### Automation

-   Automate infrastructure management: mandatory
-   Resources creation
-   Resources configuration

### Infrastructure as Code

-   Work like a developer
-   Describe your infrastructure as code (Heat/Terraform, Ansible)
-   Track changes in a VCS (git)
-   Set up code review
-   Use testing mechanisms
-   Take advantage of continuous integration and deployment systems

### Orchestration need

-   Manage all kind of resources through a unique entrypoint
-   Infrastructure description in a file (*template*)
-   Heat (included in OpenStack), Terraform

### Tests and continuous integration

-   Code style
-   Syntax validation
-   Unit tests
-   Integration tests
-   Full deployment tests

### Fault tolerance

-   Take advantage of application abilities
-   Don't try to make the compute infrastructure HA

### Autoscaling group

-   Group of similar instances
-   Variable number of instances
-   Automated scaling depending on metrics
-   Enables *horizontal* scaling

### Monitoring

-   Take into account instances' lifecycle: DOWN != ALERT
-   Monitor the service rather than the server

### Backup

-   Be able to recreate your instances (and the rest of the infrastructure)
-   Data (application, logs): block, object

### How to manage images?

-   Use of generic images and personalization at launch
-   Creation of intermediary and/or completely personalized images:
    -   Cold modification: libguestfs, virt-builder, virt-sysprep
    -   Modification through an instance: automation possible with Packer
    -   Build *from scratch*: diskimage-builder (TripleO)
    -   Build *from scratch* with distribution-specific tools (`openstack-debian-images` for Debian)

