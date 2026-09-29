### Exercice 27/30 : Panne DNS globale suite à une boucle de redirection CoreDNS (`Loop plugin detected`) (Niveau : Ultra compliqué / Expert)

* **Objectif :** Diagnostiquer et corriger un arrêt complet du service de nommage du cluster causé par une boucle de résolution (*DNS Loopback*) injectée dans la configuration de CoreDNS.
* **Contexte :** Après la modification du fichier de configuration de CoreDNS (`Corefile`) pour personnaliser les redirecteurs DNS (*forwarders*), plus aucune résolution de noms ne fonctionne dans le vcluster. Les Pods CoreDNS redémarrent en boucle.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : La directive "forward" du Corefile pointe vers 127.0.0.1 (l'interface locale du Pod CoreDNS lui-même).
# Le plugin "loop" intercepte la boucle infinie de résolution et stoppe CoreDNS avec un arrêt fatal.
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        # ERREUR : Renvoyer les requêtes vers 127.0.0.1 crée une boucle d'auto-interrogation
        forward . 127.0.0.1
        cache 30
        loop
        reload
        loadbalance
    }

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        # CORRECTION : Utilisation de /etc/resolv.conf (qui hérite des DNS du nœud/hôte) ou d'un résolveur externe valide (ex. 1.1.1.1)
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }

```

**Démarche de résolution pour l'apprenant :**

1. Constater la panne générale du DNS lors du déploiement ou du test de requêtes réseau inter-services.
2. Analyser le statut des Pods d'infrastructure dans le namespace système : `kubectl get pods -n kube-system -l k8s-app=kube-dns` (statut `CrashLoopBackOff`).
3. Consulter les journaux d'erreurs du composant DNS : `kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50`.
4. Identifier le message d'erreur fatale émis par CoreDNS :
`[FATAL] plugin/loop: Loop (127.0.0.1:53 -> :53) detected for zone "."`.
5. Inspecter le contenu du ConfigMap de CoreDNS : `kubectl get configmap coredns -n kube-system -o yaml`.
6. Repérer la directive `forward . 127.0.0.1` et la remplacer par `/etc/resolv.conf` (ou l'adresse IP du serveur DNS d'entreprise / public).
7. Réappliquer le ConfigMap et forcer le redémarrage des Pods DNS si nécessaire : `kubectl rollout restart deployment/coredns -n kube-system`.

---
