# DOCKER : Environnement de Formation & Méthodologie {-}

### Pédagogie & Déroulement de la Formation

```{.center}
┌─────────────────────────────────────────────────────────────┐
│                    APPRENDRE PAR LA PRATIQUE                │
│                                                             │
│   ┌───────────────────┐               ┌─────────────────┐   │
│   │  Cours & Concepts │ ────────────► │   Laboratoires  │   │
│   │   Architecturaux  │               │   & Challenges  │   │
│   └───────────────────┘               └─────────────────┘   │
│             ▲                                   │           │
│             └────────── Questions / Réponses ───┘           │
└─────────────────────────────────────────────────────────────┘
```

- **Principe fondamental** : 70% de pratique en conditions réelles, 30% d'apports méthodologiques et architecturaux.
- **Rythme** : Alternance continue entre présentations conceptuelles, démonstrations du formateur et ateliers autonomes.
- **Esprit d'équipe** : Échange permanent, entraide et résolution collective des cas d'erreur.

### Logistique de Session

- **Durée** : 2 à 3 jours intensifs selon les parcours.
- **Pauses régulières** : Toutes les 1h30 à 2h pour favoriser l'assimilation.
- **Supports et ressources** :
  - Slides et cours versionnés sur Git.
  - Plateforme de laboratoires interactive : `https://bit.ly/docker-labs` (ou environnement cloud dédié).

### Prérequis Techniques

- **Connaissances attendues** :
  - Maîtrise de base du terminal Linux (navigation, gestion des fichiers, droits, variables d'environnement).
  - Notions fondamentales de réseau (adresses IP, ports TCP/UDP, DNS, protocole HTTP).
  - Notions de développement ou d'administration système.

### Votre Poste de Travail & Outils Recommandés

Pour tirer le meilleur parti de cette formation :

```{.center}
┌──────────────────────────────────────────────────────────────────┐
│                     LA BOÎTE À OUTILS DU CONTENEUR               │
├───────────────────────────────┬──────────────────────────────────┤
│ Docker Engine (v25+)          │ Moteur d'exécution & daemon      │
│ Docker CLI & Plugins          │ buildx, compose v2, scout        │
│ Éditeur de code (VS Code/etc) │ Extensions Docker & Dev Containers│
│ Shell moderne (Bash / Zsh)    │ Autocomplétion & alias rapides   │
└───────────────────────────────┴──────────────────────────────────┘
```

### Installation Rapide & Autocomplétion

```bash
# Script d'installation automatisée officiel pour environnements Linux
curl -fsSL https://get.docker.com | sh

# Ajout de l'utilisateur courant au groupe docker (éviter sudo systématique)
sudo usermod -aG docker $USER
newgrp docker

# Activation de l'autocomplétion Zsh / Bash
source <(docker completion zsh)  # ou: source <(docker completion bash)
```

### Vérification de l'Environnement

Exécutez la commande suivante pour valider votre installation :

```bash
docker version
```

```
Client: Docker Engine - Community
 Version:           29.7.2
 API version:       1.48
 Go version:        go1.23.6
 Git commit:        9b3c45a
 Built:             Wed Jan 28 10:00:00 2026
 OS/Arch:           linux/amd64

Server: Docker Engine - Community
 Engine:
  Version:          29.7.2
  API version:      1.48 (minimum version 1.24)
  Go version:       go1.23.6
  Git commit:       8a2bc41
  Built:            Wed Jan 28 10:00:00 2026
  OS/Arch:          linux/amd64
```
