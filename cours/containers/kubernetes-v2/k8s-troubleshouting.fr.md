# KUBERNETES : Troubleshooting & Scènes de Crime (CSI) {-}

### La Méthodologie d'Investigation en 4 Étapes

```
   [ 1. ÉTAT GLOBAL ] ──► kubectl get pods -o wide (Identifier les coupables)
            │
            ▼
   [ 2. AUTOPSIE ]    ──► kubectl describe pod <nom> (Section Events & Last State)
            │
            ▼
   [ 3. DERNIERS MOTS ] ──► kubectl logs <nom> --previous (Pourquoi a-t-il crashé ?)
            │
            ▼
   [ 4. INFILTRATION ]  ──► kubectl debug -it <nom> --image=busybox (Debug éphémère)
```

### Le Guide des Statuts de Pods

| Statut Affiché | Signification Réelle | Cause Racine Typique |
| :--- | :--- | :--- |
| **`ImagePullBackOff`** | Impossible de télécharger l'image | Erreur de nom de tag, registre privé sans `imagePullSecrets` |
| **`CrashLoopBackOff`** | L'app démarre puis s'arrête en erreur | Variable d'environnement manquante, erreur de config, exit code $\neq 0$ |
| **`OOMKilled` (Exit 137)** | Tué par le noyau Linux | L'application a dépassé sa `resources.limits.memory` |
| **`Pending`** | Le scheduler ne trouve aucun nœud | Pas assez de CPU/RAM libre, Taints sans Tolerations, PVC non lié |
| **`CreateContainerConfigError`** | Configuration invalide | `ConfigMap` ou `Secret` référencé introuvable |
| **`Terminating` (Bloqué)** | Le pod refuse de mourir | **Finalizer** bloqué, ou I/O disque NFS gelé |

### Diagnostic Avancé : Les Conteneurs Éphémères (`kubectl debug`)

Comment déboguer une image de production moderne ultra-sécurisée (Distroless / Scratch) qui ne contient **ni `sh`, ni `curl`, ni `ps`** ?

```bash
# Injecter un conteneur de debug avec tous vos outils sans redémarrer le pod !
kubectl debug -it mon-pod-distroless --image=nicolaka/netshoot --target=mon-app
```

- Le conteneur de debug partage le même namespace réseau et les mêmes processus que l'application !

### Scène de Crime CSI N°1 : Le Crash Incompréhensible

**Constat** : Un conteneur Java SpringBoot redémarre toutes les 2 minutes sans aucun message d'erreur dans les logs applicatifs.

En tapant `kubectl describe pod java-app` :
```
Last State:     Terminated
  Reason:       OOMKilled
  Exit Code:    137
```

**Diagnostic** : La JVM a alloué son heap sans tenir compte de la limite cgroups K8s. Le noyau Linux a envoyé un `SIGKILL` (Code 137 = $128 + 9$).
**Correction** : Ajouter l'option JVM `-XX:MaxRAMPercentage=75.0` ou augmenter la limite mémoire dans le YAML.

### Scène de Crime CSI N°2 : Le Pod `Terminating` Éternel

**Constat** : Vous tapez `kubectl delete pod mon-pod --force`, mais le Pod reste bloqué indéfiniment en statut `Terminating`.

```bash
# 1. Inspecter les finalizers qui retiennent la destruction
kubectl get pod mon-pod -o jsonpath='{.metadata.finalizers}'

# 2. Débloquer la situation en supprimant le finalizer bloquant
kubectl patch pod mon-pod -p '{"metadata":{"finalizers":null}}'
```

### Mini-Défi : Le Pod Qui Se Termine Immédiatement

**Incident SRE** : Vous lancez un pod avec l'image `ubuntu:latest` sans argument particulier : `kubectl run test --image=ubuntu`.
Le pod passe immédiatement en `Completed` puis en `CrashLoopBackOff`.

Pourquoi ce conteneur refuse-t-il de rester en vie ?


**Incident SRE** : Vous lancez un pod avec l'image `ubuntu:latest` sans argument particulier : `kubectl run test --image=ubuntu`.
Le pod passe immédiatement en `Completed` puis en `CrashLoopBackOff`.

Pourquoi ce conteneur refuse-t-il de rester en vie ?

(Réponse : Le processus principal par défaut d'une image Ubuntu est `/bin/bash`. Sans terminal interactif (`-it`) ni commande longue (`sleep infinity`), le shell termine son exécution immédiatement (PID 1 s'arrête avec code 0), ce qui éteint le Pod).