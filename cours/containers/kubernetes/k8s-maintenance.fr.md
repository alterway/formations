# KUBERNETES : Maintenance du Cluster

### Upgrade du OS

- Le retrait d'un noeud du cluster peut survenir suite à une panne ou pour des fins de maintenance comme des opérations de mise à jour, ou d'application de correctifs de sécurité.
- La commande `kubectl drain` permet de vider un noeud des pods qu'il héberge vers un autre noeud, puis de marquer le noeud "not schedulable". Ainsi au cours de l'opération de maintenance, aucun pod ne peut lui être affecté.


### Upgrade du OS

- Avec `kubectl uncordon`, le noeud est remis dans le cluster et peut à nouveau héberger des pods.
- La commande `kubectl cordon` marque uniquement le noeud "not schedulable" tout en conservant les pods qu'il héberge. Il s'assure simplement que de nouveaux pods ne lui soient pas affectés.


### Upgrade du OS

- Il est important de mettre à jour la version de kubernetes afin de bénéficier de nouvelles fonctinnalités. 
- Ce process s'effectue par la mise à jour des composants du control plane
- Les composants du control plane peuvent avoir des versions différentes mais celle de l'API server doit toujours être suppérieure à celle des autre composants
- Le passage de version s'effectue de façon incrémentielle. On ne peut par exemple que passer de la version v1.19.x à la version v1.20.x
- Un upgrade de Kubeadm met à jour les composants du control plane sauf le kubelet. Il est nécessaire de le mettre à jour séparément pour un passage à niveau complet.


### Upgrade du OS

- Voici les étapes à suivre pour une mise à niveau d'un cluster avec Kubeadm: 
- La commande `kubeadm upgrade plan` fournit les informations sur la version actuelle de kubeadm installée, la version du cluster et la dernière version stable de Kubernetes disponible 
 
 ```console
 kubectl drain node1
 apt-get upgrade -y kubeadm=1.21.0-00
 apt-get upgrade -y kubelet=1.21.0-00
 apt-get upgrade node config --kubelet-version v1.21.0
 systemctl restart kubelet
 kubectl uncordon node1
 ```

### ETCD sauvegarde et restauration

- Il est recommandé de faire des sauvegardes régulières de la base de données ETCD. Une restauration peut être nécessaire après un désastre ou une maintenance.
- `etcdctl` est un client en ligne de commande du service ETCD
- Avec une installation par défaut de Kubeadm, la base de données clé-valeur ETCD est déployée en tant que pod statique sur le Master node.
- Les commandes `etcdctl snapshot save -h` et `etcdctl snapshot restore -h` permettent respectivement de sauvegarder et de restaurer la base de données.

