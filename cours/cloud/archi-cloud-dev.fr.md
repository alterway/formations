# Architectures cloud-ready

## Concevoir une application pour le cloud

### 12-factor

“The Twelve-Factor App” <http://12factor.net/>

-   Écrit par Heroku
-   Suivre (tout) le code dans un VCS
-   Configuration

### Modulaire

-   Multiples composants de taille raisonnable
-   Philosophie Unix
-   Couplage faible et interface documentée

### Passage à l’échelle

-   Vertical vs Horizontal
-   Scale up vs Scale out
-   Plusieurs petites instances plutôt qu’une grosse instance

### Stateful vs stateless

-   Beaucoup de stateful dans les applications legacy
-   Nécessite de partager l’information d’état lorsque plusieurs workers
-   Le stateless élimine cette contrainte

### Tolérance aux pannes

-   L’infrastructure n’est pas hautement disponible
-   L’API d’infrastructure est hautement disponible
-   L’application doit anticiper et réagir aux pannes

### Stockage des données

-   Base de données relationnelles
-   Base de données NoSQL
-   Stockage bloc
-   Stockage objet
-   Stockage éphémère
-   Cache, temporaire

### Design Tenets d’OpenStack (exemple) 1/2

1.  Scalability and elasticity are our main goals
2.  Any feature that limits our main goals must be optional
3.  Everything should be asynchronous. If you can’t do something asynchronously, see \#2
4.  All required components must be horizontally scalable

### Design Tenets d’OpenStack (exemple) 2/2

5.  Always use shared nothing architecture (SN) or sharding. If you can’t Share nothing/shard, see \#2
6.  Distribute everything. Especially logic. Move logic to where state naturally exists.
7.  Accept eventual consistency and use it where it is appropriate.
8.  Test everything. We require tests with submitted code. (We will help you if you need it)

<https://wiki.openstack.org/wiki/BasicDesignTenets>

