## Internals

### Architecture

![Detailed view of the services](images/architecture-simple.jpg)

### Implementation

-   Each sub-project is split in multiple services
-   Communication between services: AMQP (RabbitMQ)
-   Database: relational SQL (MySQL/MariaDB)
-   Memcached
-   etcd (à l'avenir)
-   Generally: re-use of existing components
-   Everything is written in Python (Django for the web part)
-   Multi tenancy

### APIs

-   Each project has its *own* OpenStack API
-   Some projects support the corresponding AWS API (EC2, S3)

## Development model

### Stats

-   2581 contributors Newton
-   309 contributing organizations to Newton
-   20 millions lines of code written since the beginning of the project
-   Very fast development: 25000 commits in Liberty

### Development: in details

-   Open to all (individuals and companies)
-   6 months release cycle
-   Each cycle starts with a Project Team Gathering (PTG)
-   During each cycle, an OpenStack Summit takes place

### Tools and communication

-   Peer review for code: Gerrit
-   Continous Integration (CI): Zuul
-   Blueprints/spécifications and bugs:
    -    Launchpad
    -    Storyboard
-   Code: Git (GitHub is used as a miror)
-   Communication: IRC and mailing-lists

### Development: in details

![Change workflow in OpenStack](images/openstack-dev-workflow-diagram.png)

### Release cyle: 6 months

-   The schedule is published, example: <https://releases.openstack.org/pike/schedule.html>
-   Milestone releases
-   Freezes: FeatureProposal, Feature, String
-   RC releases
-   Stable releases
-   Special case for some projects: <https://releases.openstack.org/reference/release_models.html>

### Projects

-   Each project has its own versioning
-   *Semantic versioning*
-   <http://releases.openstack.org/>
-   *Project Teams* <http://governance.openstack.org/reference/projects/index.html>
-   Use of factual and impartial tags <https://www.openstack.org/software/project-navigator/>

### Who contributes?

-   *Active Technical Contributor*
-   ATCs are invited to summits and have the right to vote
-   *Core reviewer*: ATC with permissions to approve patches in a project
-   *Project Team Lead* (PTL): elected by the ATC of each project
-   Stackalytics provides stats on contributions

<http://stackalytics.com/>

### Where to find informations about the OpenStack development

-   How to contribute
    -   <https://docs.openstack.org/project-team-guide/>
    -   <https://docs.openstack.org/infra/manual/>
-   Various informations, on the wiki
    -   <https://wiki.openstack.org>
-   Blueprints and bugs on Launchpad/StoryBoard
    -   <https://launchpad.net/openstack>
    -   <https://storyboard.openstack.org>
    -   <http://specs.openstack.org/>

### Where to find informations about the OpenStack development

-   Proposed patches and their reviews on Gerrit
    -   <https://review.openstack.org>
-   CI state (among others)
    -   <http://status.openstack.org>
-   Code (Git) and tarballs are availabble
    -   <https://git.openstack.org>
    -   <http://tarballs.openstack.org/>
-   IRC
    - Freenode network
    - Logs and meetings informations: <http://eavesdrop.openstack.org/>
-   Mailing-lists
    - <http://lists.openstack.org/>

### OpenStack Infra

-   Team in charge of the OpenStack development infrastructure
-   Works like the OpenStack developement teams and uses the same tools
-   Result: and entirely open source infracture, developed as such

### OpenStack Summit

-   In the USA until 2013
-   Now: between North America and Asia/Europe
-   A few dozens at the beginning to 6000 attendees today
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

### Upstream Training

-   2 days training
-   Learn how to become an OpenStack contributor
-   Tools
-   Processes
-   Work and collaborate in an open way

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

-   A shell script is responsible for everthing: stack.sh
-   A config file: local.conf
-   Installs all the required dependencies (packages)
-   Clones all the git repositories (master branch by défaut)
-   Launches all the components

### Configuration: local.conf

Exemple

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

