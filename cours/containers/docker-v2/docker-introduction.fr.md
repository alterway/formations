# DOCKER : De la Virtualisation aux Conteneurs {-}

### La Friction dans la Chaîne d'Approvisionnement Logiciel

Avant les conteneurs, le déploiement d'applications était une source constante de frictions :

```{.center}
   DÉVELOPPEMENT                        PRODUCTION
┌──────────────────┐               ┌──────────────────┐
│  "Ça marche sur  │               │ "C'est planté en │
│  ma machine !"   │ ────────────► │   production !"  │
│ (Node 20, macOS) │   LIVRAISON   │ (Node 16, RHEL 7)│
└──────────────────┘               └──────────────────┘
```

- Différences d'OS, de bibliothèques système, de versions de runtimes.
- Dépendances implicites non documentées dans les procédures manuelles.
- Délais de mise en production mesurés en semaines, voire en mois.

### Le Cauchemar du Déploiement : La "Matrix from Hell"

Sans standard d'empaquetage, chaque application doit être adaptée à chaque environnement :

```{.center}
┌─────────────────┬─────────────┬───────────┬────────────┬─────────────┐
│  APPLICATIONS   │ Machine Dev │ VM de Test│ Cloud AWS  │ Bare-Metal  │
├─────────────────┼─────────────┼───────────┼────────────┼─────────────┤
│ Static Web (PHP)│      ?      │     ?     │     ?      │      ?      │
│ Node.js / React │      ?      │     ?     │     ?      │      ?      │
│ Python / AI     │      ?      │     ?     │     ?      │      ?      │
│ Base PostgreSQL │      ?      │     ?     │     ?      │      ?      │
│ Redis / RabbitMQ│      ?      │     ?     │     ?      │      ?      │
└─────────────────┴─────────────┴───────────┴────────────┴─────────────┘
  NxM Combinaisons = NxM Problèmes de configuration et de dépendances
```

### L'Analogie Révolutionnaire : Le Conteneur Intermodal

En 1956, Malcolm McLean invente le conteneur maritime standardisé (ISO) :

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                LE STANDARD DU TRANSPORT PHYSIQUE            │
│  Peu importe la cargaison (voitures, café, électronique),    │
│  elle rentre dans un conteneur standardisé manipulable      │
│  par tous les bateaux, trains, camions et grues du monde.   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 LE STANDARD DU LOGICIEL (DOCKER)            │
│  Peu importe le langage (Java, Go, Python, Rust, PHP),      │
│  le code et ses dépendances sont emballés dans un conteneur │
│  exécutable à l'identique sur n'importe quel serveur.       │
└─────────────────────────────────────────────────────────────┘
```

### L'Évolution de l'Encapsulation Informatique

```{.center}
1. SERVEUR PHYSIQUE             2. MACHINE VIRTUELLE             3. CONTENEURS
┌──────────────────┐           ┌──────────────────┐           ┌──────────────────┐
│   Application    │           │ App 1  │  App 2  │           │ App 1  │  App 2  │
├──────────────────┤           ├────────┼─────────┤           ├────────┼─────────┤
│  OS Monolithique │           │Guest OS│Guest OS │           │ Bins / Libs isolés│
├──────────────────┤           ├────────┴─────────┤           ├──────────────────┤
│ Matériel Dédié   │           │   Hyperviseur    │           │  Docker Engine   │
│ (1 App / Serveur)│           ├──────────────────┤           ├──────────────────┤
│                  │           │   Host OS / KVM  │           │   Linux Kernel   │
│                  │           ├──────────────────┤           ├──────────────────┤
│                  │           │     Matériel     │           │     Matériel     │
└──────────────────┘           └──────────────────┘           └──────────────────┘
  Gaspillage 90% CPU             Isolation lourde              Léger, rapide, dense
```

### Comparatif Technique : Machine Virtuelle vs Conteneur

| Critère | Machine Virtuelle (VM) | Conteneur Docker |
| :--- | :--- | :--- |
| **Niveau d'abstraction** | Matériel complet (Hardware) | Noyau du système (OS Kernel) |
| **Poids de l'image** | Plusieurs Go (Guest OS complet) | Quelques Mo à quelques centaines de Mo |
| **Temps de démarrage** | Plusieurs minutes | Quelques millisecondes à secondes |
| **Overhead CPU / RAM** | Consommation fixe allouée par VM | Négligeable (processus natif sur l'hôte) |
| **Densité par serveur** | 10 à 50 VMs par serveur | Plusieurs centaines de conteneurs |
| **Isolation** | Étanche (ring 0 / hyperviseur) | Logique (Namespaces + Cgroups Linux) |

### La Règle d'Or : "Any App, Anywhere"

```{.center}
┌──────────────────────────────────────────────────────────────────┐
│           CONSTRUIRE           PARTAGER            EXÉCUTER      │
│            (Build)              (Ship)              (Run)        │
│                                                                  │
│         ┌───────────┐        ┌──────────┐        ┌───────────┐   │
│         │ Dockerfile│ ─────► │ Registry │ ─────► │ Production│   │
│         │   Source  │        │ (Hub/ACR)│        │ Kubernetes│   │
│         └───────────┘        └──────────┘        └───────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

- **Développeur** : Ne s'occupe que de son application et de ses dépendances.
- **Administrateur / Ops** : Ne s'occupe que de fournir une plateforme Docker/Kubernetes stable.
- **Séparation nette des responsabilités** (*Separation of Concerns*).

### Bref Historique & Standardisation OCI

- **2010** : Création de **dotCloud** (PaaS) par Solomon Hykes et Sébastien Pahl.
- **2013** : Open source de **Docker** en Go $\rightarrow$ explosion mondiale de l'écosystème.
- **2015** : Création de l'**OCI** (*Open Container Initiative*) sous l'égide de la Linux Foundation :
  - `image-spec` : Spécification universelle du format d'image.
  - `runtime-spec` : Spécification universelle d'exécution de conteneur (`runc`).
- **Aujourd'hui** : Docker utilise **BuildKit**, **containerd**, et s'intègre nativement à **Kubernetes**.

### Quizz : Fondamentaux des Conteneurs

**1. Quelle est la différence majeure entre une VM et un conteneur ?**

[( )] Les conteneurs ont leur propre noyau d'exploitation indépendant
[(X)] Les conteneurs partagent le noyau Linux de la machine hôte
[( )] Les VMs démarrent plus vite que les conteneurs
[( )] Un conteneur virtualise la carte mère et le BIOS

**2. Que garantit le standard OCI (Open Container Initiative) ?**

[(X)] Qu'une image construite avec Docker puisse tourner avec containerd, Podman ou CRI-O
[( )] Que Docker soit obligatoirement payant en entreprise
[( )] Que les conteneurs fonctionnent sans noyau Linux
