## Internals

### Architecture

![Detailed view of the services](images/architecture-simple.jpg)

### Implementation

-   Everything is written in Python (Django for the web part)
-   Each project is split in multiple services (example: API, scheduler, etc.)
-   Re-use of existing components and existing libraries
-   Usage of `oslo.*` libraries (developed by and for OpenStack): logs, config, etc.
-   Usage of `rootwrap` to call underlying programs as root

### Implementation - dependencies

-   Database: relational SQL (MySQL/MariaDB)
-   Communication between services: AMQP (RabbitMQ)
-   Caching: Memcached
-   Distributed storage of configuration (to come): etcd

## Development model

### Stats (2017)

-   2344 developers
-   65823 changes (commits)

<https://www.openstack.org/assets/reports/OpenStack-AnnualReport2017.pdf>

### Development: in details

-   Open to all (individuals and companies)
-   6 months release cycle
-   Each cycle starts with a Project Team Gathering (PTG)
-   During each cycle, an OpenStack Summit takes place

### Tools and communication

-   Code: Git (GitHub is used as a mirror)
-   Peer review for code: Gerrit
-   Continous Integration (CI): Zuul
-   Blueprints/specifications and bugs:
    -    Launchpad
    -    StoryBoard
-   Communication: IRC and mailing-lists
-   Translation: Zanata

### Development: in details

![Change workflow in OpenStack](images/openstack-dev-workflow-diagram.png)

### Release cyle: 6 months

-   The schedule is published, example: <https://releases.openstack.org/stein/schedule.html>
-   Milestone releases
-   Freezes: Feature, Requirements, String
-   RC releases
-   Stable releases
-   Special case for some projects: <https://releases.openstack.org/reference/release_models.html>

### Projects

-   *Project Teams*: <https://governance.openstack.org/reference/projects/index.html>
-   Each deliverable has its own versioning - *Semantic versioning*
-   <https://releases.openstack.org/>

### Who contributes?

-   *Active Technical Contributor* (ATC)
    -   Person with at least one recent contribution in a recognized OpenStack project
    -   Voting rights (TC and PTL)
-   *Core reviewer*: ATC with permissions to approve patches in a project
-   *Project Team Lead* (PTL): elected by the ATC of each project
-   Stackalytics provides stats on contributions <http://stackalytics.com/>

### Where to find informations about the OpenStack development

-   How to contribute
    -   <https://docs.openstack.org/project-team-guide/>
    -   <https://docs.openstack.org/infra/manual/>
-   Various informations, on the wiki
    -   <https://wiki.openstack.org/>
-   Blueprints and bugs on Launchpad/StoryBoard
    -   <https://launchpad.net/openstack/>
    -   <https://storyboard.openstack.org/>
    -   <https://specs.openstack.org/>

### Where to find informations about the OpenStack development

-   Proposed patches and their reviews on Gerrit
    -   <https://review.openstack.org/>
-   CI state (among others)
    -   <http://status.openstack.org/>
-   Code (Git) and tarballs are available
    -   <https://git.openstack.org/>
    -   <https://tarballs.openstack.org/>
-   IRC
    - Freenode network
    - Logs and meetings informations: <http://eavesdrop.openstack.org/>
-   Mailing-lists
    - <http://lists.openstack.org/>

### Upstream Training

-   2 days training
-   Learn how to become an OpenStack contributor
-   Tools
-   Processes
-   Work and collaborate in an open way

### OpenStack Infra

-   Team in charge of the OpenStack development infrastructure
-   Works like the OpenStack developement teams and uses the same tools
-   Result: Infrastructure as code **open source** <https://opensourceinfra.org/>
-   Uses (hybrid) cloud
-   Develops some tools:
    - Zuul
    - yaml2ical

### OpenStack Summit

-   Every 6 months at the middle of the development cycle
-   In the USA until 2013, now between North America and Asia/Europe
-   A few dozens at the beginning to thousands attendees today
-   At the same time: conference (users, decision makers)and Forum (developers/operators, replaces part of the previous Design Summit)
-   Defines the name of the next release: place/city near the Summit

### Example of the April 2013 Summit in Portland

![Photo: Adrien Cunin](images/photo-summit.jpg)

### Example of the October 2015 Summit in Tokyo

![Photo: Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit1.jpg)

### Example of the October 2015 Summit in Tokyo

![Photo: Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit2.jpg)

### Example of the October 2015 Summit in Tokyo

![Photo: Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit3.jpg)

### Example of the October 2015 Summit in Tokyo

![Photo: Elizabeth K. Joseph, CC BY 2.0, Flickr/pleia2](images/photo-summit4.jpg)

### Project Team Gathering (PTG)

-   Since 2017
-   At the beginning of each cycle
-   Replaces part of the previous Design Summit
-   Dedicated to developers

### Translation

-   Official *i18n* team
-   Only some parts are translated, like Horizon
-   The French translation is one of the most complete today
-   Use of a web platform based on Zanata: <https://translate.openstack.org/>

## DevStack: quickly run OpenStack

### DevStack use cases

-   Quickly deploy OpenStack
-   Used by developers to test their changes
-   Used for demos
-   Used to the the APIs without bothering about a deployment
-   Must NOT be used for production

### DevStack internals

-   Support for Ubuntu 16.04/17.04, Fedora 24/25, CentOS/RHEL 7, Debian, OpenSUSE
-   A shell script is responsible for everything: stack.sh
-   A config file: local.conf
-   Installs all the required dependencies (packages)
-   Clones all the git repositories (master branch by défaut)
-   Launches all the components

### Configuration: local.conf

Example

    [[local|localrc]]
    ADMIN_PASSWORD=secrete
    DATABASE_PASSWORD=$ADMIN_PASSWORD
    RABBIT_PASSWORD=$ADMIN_PASSWORD
    SERVICE_PASSWORD=$ADMIN_PASSWORD
    SERVICE_TOKEN=a682f596-76f3-11e3-b3b2-e716f9080d50
    #FIXED_RANGE=172.31.1.0/24
    #FLOATING_RANGE=192.168.20.0/25
    #HOST_IP=10.3.4.5

### Usage tips

-   DevStack installs a lot on the machine
-   It is recommended to work inside a VM
-   To test all the OpenStack components in good conditions, multiple Go of RAM are necessary
-   Use of Vagrant is recommended

