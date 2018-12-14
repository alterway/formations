# Cloud-ready architectures

## Design an application for the cloud

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

