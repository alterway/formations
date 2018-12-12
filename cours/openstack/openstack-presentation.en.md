# OpenStack: the project

## Overview

### High level

![Simple version](images/openstack-software-diagram.png)

### History

-   Started in 2010
-   Goal: the Free Open Source Cloud Operating System
-   Merge of two projects from Rackspace (Storage) and NASA (Compute)
-   Free software distributed under Apache 2.0 license
-   Birth of the Foundation in 2012

### Mission statement

```To produce a ubiquitous Open Source Cloud Computing platform that is
easy to use, simple to implement, interoperable between deployments,
works well at all scales, and meets the needs of users and operators of
both public and private clouds.```

### Releases

-   Austin (2010.1)
-   Bexar (2011.1), Cactus (2011.2), Diablo (2011.3)
-   Essex (2012.1), Folsom (2012.2)
-   Grizzly (2013.1), Havana (2013.2)
-   Icehouse (2014.1), Juno (2014.2)
-   Kilo (2015.1), Liberty (2015.2)
-   Mitaka (2016.1), Newton (2016.2)
-   Ocata (2017.1), Pike (2017.2)
-   Queens (2018.1), **Rocky** (2018.2)
-   Early 2019: Stein

### Some of the supporters/contributors ...

- Editors: Red Hat, Suse, Canonical, Vmware, ...
- Hardware makers: IBM, HP, Dell, ...
- Hardware makers/network: Juniper, Cisco, ...
- Hardware makers/storage: NetApp, Hitachi, ...
- Also: NASA, Rackspace, Yahoo, OVH, Citrix, SAP, ...
-  **Google**! (since July 2015)

<https://www.openstack.org/foundation/companies/>

### ... and users

-   All the previously mentioned contributors
-   In France: **Cloudwatt** and **Numergy**
-   Wikimedia
-   CERN
-   Paypal
-   Comcast
-   BMW
-   Etc. Not counting confidential deployments

<https://www.openstack.org/user-stories/>

### The different sub-projects

<https://www.openstack.org/software/project-navigator/>

-   OpenStack Compute - Nova
-   OpenStack (Object) Storage - Swift
-   OpenStack Block Storage - Cinder
-   OpenStack Networking - Neutron
-   OpenStack Image Service - Glance
-   OpenStack Identity Service - Keystone
-   OpenStack Dashboard - Horizon
-   OpenStack Telemetry - Ceilometer
-   OpenStack Orchestration - Heat

### The different sub-projects (2)

-   But also:
    -   Bare metal (Ironic)
    -   Queue service (Zaqar)
    -   Database service (Trove)
    -   Data processing (Sahara)
    -   DNS service (Designate)
    -   Shared File Systems (Manila)
    -   Key management (Barbican)
    -   Container (Magnum)
-   Others
    -   Client CLI and libraries
    -   OpenStack deployment tools
    -   Libraries used by OpenStack
    -   Tools used to develop OpenStack

### APIs

-   Each project supports *its* OpenStack API
-   Some projects support the corresponding AWS API (Nova/EC2, Swift/S3)

### The 4 Opens

-   Open Source
-   Open Design
-   Open Development
-   Open Community

<https://governance.openstack.org/tc/reference/opens.html>

<https://www.openstack.org/four-opens/>

### The OpenStack Foundation

-   Main governance entity and legal representation of the project
-   Board members are part of the sponsoring companies and elected by individual members
-   Everyone can (freely) become an individual member
-   Human resources: marketing, event managemement, release management, a few developers (mainly on infrastructure)
-   600 organizations across the world
-   80000 individual members in 170 countries

### The OpenStack Foundation

![Main entities of the Foundation](images/foundation.png)

### Open Infrastructure

-   Lately, the OpenStack Foundation expands to **Open Infrastructure**
-   Beyond OpenStack, new projects:
    -   Kata Containers
    -   Zuul
    -   Airship
    -   StarlingX

### Resources

-   Announcements (new versions, security advisories): <openstack-announce@lists.openstack.org>
-   Documentation portal: <https://docs.openstack.org/>
-   API/SDK: <https://developer.openstack.org/>
-   Project governance: <https://governance.openstack.org/>
-   Releases: <https://releases.openstack.org/>
-   Support:
    -   <https://ask.openstack.org/>
    -   openstack-discuss@lists.openstack.org
    -   \#openstack@Freenode

### Resources

-   News:
    -   Official blog: <https://www.openstack.org/blog/>
    -   Planet: <http://planet.openstack.org/>
    -   Superuser: <http://superuser.openstack.org/>
-   Commercial resources: <https://www.openstack.org/marketplace/> among others
-   Job board: <https://www.openstack.org/community/jobs/>

### User Survey

-   Regular survey done by the Foundation (every 6 months)
-   Targets deployers and users
-   Usable data: <https://www.openstack.org/analytics>

### Certified OpenStack Administrator (COA)

-   The only certification:
    - Approved by the OpenStack Foundation
    - Not linked to a specific company
-   Content:
    -   Mainly OpenStack cloud *user* oriented
    -   <https://www.openstack.org/coa/requirements/>
-   Practical aspects:
    -   Practical exam, remote, duration: 2.5 hours
    -   Cost: $300 (one re-take possible)
-   Ressources
    - <https://www.openstack.org/coa/>
    - Tips: <https://www.openstack.org/coa/tips/>
    - Handbook: <http://www.openstack.org/coa/handbook>
    - (unofficial) Exercises: <https://github.com/AJNOURI/COA>

### Resources - French community and association

![Logo OpenStack-fr](images/openstackfr.png){height=50px}

-   <https://openstack.fr/> - <https://asso.openstack.fr/>
-   Meetups: Paris, Lyon, Toulouse, Montréal, etc.
-   OpenStack Days France (Paris): <https://openstackdayfrance.fr>
-   Attending events such as *Paris Open Source Summit*
-   Communication channels:
    -   openstack-fr@lists.openstack.org
    -   \#openstack-fr@Freenode

