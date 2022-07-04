#  Backup and restaure ETCD

1. Sauvegarde de la base de données ETCD:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=<trusted-ca-file> --cert=<cert-file> --key=<key-file> \
  snapshot save <backup-file-location>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

où trust-ca-file, cert-file et key-file peuvent être obtenus à partir de la description du Pod etcd en mettant sur le master la commande:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo cat /etc/kubernetes/manifests/etcd.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save etcd-bkp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Le snapshot a créé un fichier nommé: etcd-bkp. Vérifier le status du snapshot:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
ETCDCTL_API=3 \
etcdctl --write-out=table snapshot status etcd-bkp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

2. Créez un pod nommé after-backup avec l'image nginx

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl run after-backup --image=nginx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

3. Restaurer maintenant la base de données ETCD: 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
ETCDCTL_API=3 etcdctl --endpoints 10.2.0.9:2379 snapshot restore etcd-bkp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Remarquez que l'opération de restauration a généré un repertoire default.etcd

4. Utiliser la base de données restaurée 

Avant de remplacer l'ETCD par la nouvelle restauration:

- Arrêtons les composants du control plane en déplaçant les fichiers manifest

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo mv /etc/kubernetes/manifests/*.yaml /tmp/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- sécurisons l'état actuel de l'ETCD

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo mv /var/lib/etcd/member /var/lib/etcd/member.bak
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Remplaçons les données de l'ETCD par les fichiers de backup:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo mv default.etcd/member /var/lib/etcd/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Redémarrons les composants du control plane:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
sudo mv /tmp/*.yaml /etc/kubernetes/manifests/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

5. Vérifier que la base de données a été restaurée à l'état désiré 

Le pod créé après la sauvegarde ne doit plus exister après la restauration 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.zsh .numberLines}
kubectl get pods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



<hr>
