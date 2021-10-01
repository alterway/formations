# KUBERNETES : Troubleshouting

### Pods troubleshooting

- Vérifier l'état des pods 

    $ kubectl get pods
    NAME                           READY   STATUS           RESTARTS   AGE
    nginx-deploy-8fd84bbd6-b8d48   1/1     Running             0          45d
    nginx-deploy-8fd84bbd6-fqmgk   1/1     Running             0          45d
    nginx-deploy-8fd84bbd6-nvq5b   1/1     Running             0          45d
    mysql-database                 0/1     CrashLoopBackOff    1          18s
    mysql-database1                0/1     ImagePullBackOff    0          6s
    web-deploy-654fb8bb79-24nvd    0/1     Pending             0          2s

    si l'état de votre pod n'est pas "Running", vous devrez suivre quelques étapes de débogage


### Pods troubleshooting
  
- L'état de votre pod est en "CrashLoopBackOff"   

    Faites une description sur le pod et regardez la section "Events". Vous remarquerez peut-être un warning "Back-off restarting failed"

    $ kubectl describe pods mysql-database 
    Events:
    Type     Reason     Age                  From                                                 Message
    ----     ------     ----                 ----                                                 -------
    Normal   Scheduled  2m18s                default-scheduler                                    Successfully assigned default/mysql-database to gke-certif-test-default-pool-27dfc050-9bww
    Normal   Pulled     76s (x4 over 2m7s)   kubelet, gke-certif-test-default-pool-27dfc050-9bww  Successfully pulled image "mysql"
    Normal   Created    76s (x4 over 2m3s)   kubelet, gke-certif-test-default-pool-27dfc050-9bww  Created container mysql
    Normal   Started    75s (x4 over 2m2s)   kubelet, gke-certif-test-default-pool-27dfc050-9bww  Started container mysql
    Warning  BackOff    46s (x8 over 2m1s)   kubelet, gke-certif-test-default-pool-27dfc050-9bww  Back-off restarting failed container
    Normal   Pulling    32s (x5 over 2m17s)  kubelet, gke-certif-test-default-pool-27dfc050-9bww  Pulling image "mysql"


### Pods troubleshooting

    Vous pouvez connaître la raison de l'échec en vérifiant les logs des conteneurs de votre pod

    $ kubectl logs mysql-database --container=mysql
    2020-03-06 10:07:26+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.19-1debian10 started.
    2020-03-06 10:07:26+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
    2020-03-06 10:07:26+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.19-1debian10 started.
    2020-03-06 10:07:26+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
        You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD


### Pods troubleshooting

- L'état de votre pod est en "ImagePullBackOff" 

    Faites une description sur le pod et regardez la section "Events". Vous pouvez remarquer l'erreur "ErrImagePull". Cela signifie que vous avez mis une mauvaise image de docker ou que vous avez une mauvaise autorisation d'accès au registre

    $ kubectl describe pods mysql-database1 
        Events:
    Type     Reason          Age                 From                                                 Message
    ----     ------          ----                ----                                                 -------
    Normal   Scheduled       105s                default-scheduler                                    Successfully assigned default/mysql-database1 to gke-certif-test-default-pool-27dfc050-9bww
    Normal   SandboxChanged  103s                kubelet, gke-certif-test-default-pool-27dfc050-9bww  Pod sandbox changed, it will be killed and re-created.
    Normal   BackOff         31s (x6 over 103s)  kubelet, gke-certif-test-default-pool-27dfc050-9bww  Back-off pulling image "mysql:dert12"
    Warning  Failed          31s (x6 over 103s)  kubelet, gke-certif-test-default-pool-27dfc050-9bww  Error: ImagePullBackOff
    Normal   Pulling         16s (x4 over 104s)  kubelet, gke-certif-test-default-pool-27dfc050-9bww  Pulling image "mysql:dert12"
    Warning  Failed          15s (x4 over 104s)  kubelet, gke-certif-test-default-pool-27dfc050-9bww  Failed to pull image "mysql:dert12": rpc error: code = Unknown desc = Error response from daemon: manifest for mysql:dert12 not found: manifest unknown: manifest unknown
    Warning  Failed          15s (x4 over 104s)  kubelet, gke-certif-test-default-pool-27dfc050-9bww  Error: ErrImagePull


### Pods troubleshooting

- L'état de votre pod est en "Pending" 

    Faites une description sur le pod et regardez la section "Events". Notez que le scheduler n'a pas de nœud dans lequel placer votre pod en raison d'une ressource insuffisante. Vous pouvez augmenter votre CPU ou votre mémoire (selon le message d'avertissement), cela peut se produire en ajoutant de nouveaux nœuds ou en diminuant le nombre de réplicas du déploiement    

    $ kubectl describe pods web-deploy-654fb8bb79-24nvd
        Events:
    Type     Reason             Age                From                Message
    ----     ------             ----               ----                -------
    Warning  FailedScheduling   90s (x2 over 95s)  default-scheduler   0/2 nodes are available: 2 Insufficient cpu.
    Normal   NotTriggerScaleUp  65s                cluster-autoscaler  pod didn't trigger scale-up (it wouldn't fit if a new node is added): 1 max node group size reached
    Warning  FailedScheduling   20s                default-scheduler   0/6 nodes are available: 6 Insufficient cpu.


### Pods troubleshooting

- L'état de votre pod est en "waiting" 

    Si un pod est bloqué dans l'état "waiting", il a été planifié sur un nœud de travail, mais il ne peut pas s'exécuter sur cette machine. Encore une fois, les informations de kubectl describe... devraient être informatives. La cause la plus courante des pods en "waiting" est l'échec de l'extraction de l'image. Il y a trois choses à vérifier :

         - Assurez-vous que le nom de l'image est correct.
         - Avez-vous poussé l'image vers le repository ?
         - Exécutez un docker pull <image> manuel sur votre machine pour voir si l'image peut être extraite.


### Pods troubleshooting

- Commandes utiles
    
    $ kubectl get pods
    $ kubectl describe pods pod-name
    $ kubectl logs pod-name --container=pods-containers-name
    $ kubectl logs --previous pod-name --container=pods-containers-name
    $ kubectl exec -it pod-name -- bash


### Service troubleshooting

   $ kubectl get services 
    NAME          TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    kubernetes    ClusterIP      10.16.0.1     <none>        443/TCP        46d
    web-service   LoadBalancer   10.16.7.129   34.68.167.93  80:30250/TCP   9m54s

   Il existe plusieurs problèmes courants qui peuvent empêcher les services de fonctionner correctement. Tout d'abord, vérifiez qu'il existe des endpoints pour le service. Pour chaque objet Service, l'API server met à disposition une ressource endpoint.
    
   $ kubectl get endpoints web-service
    NAME          ENDPOINTS                                  AGE
    web-service   10.12.0.27:80,10.12.0.28:80,10.12.0.4:80   11m
 
   Assurez-vous que les endpoints correspondent au nombre de conteneurs que vous pensez être membres de votre service. Dans ce scénario, le service Web sert un déploiement Web avec 3 réplicas de pods.

   $ kubectl get deployments
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    web-deployment   3/3     3            3           4h43m 


### Service troubleshooting

    au cas où les endpoints du service sont manquants, vérifiez le sélecteur du service

    ...
    spec:
      - selector:
          run: web-deployment
    
    Ce sélecteur doit correspondre aux labels des pods sinon le service ne pourra pas exposer les pods

    $ kubectl get pods --show-labels
    NAME                              READY   STATUS    RESTARTS   AGE     LABELS
    web-deployment-654fb8bb79-6n9q2   1/1     Running   0          4h53m   run=web-deployment
    web-deployment-654fb8bb79-ljnhw   1/1     Running   0          15m     run=web-deployment
    web-deployment-654fb8bb79-vpcwb   1/1     Running   0          15m     run=web-deployment

    Si la liste des pods correspond aux attentes, mais que les endpoints sont toujours vides, il est possible que les bons ports ne soient pas exposés. Si le service a un containerPort spécifié, mais que les pods sélectionnés n'ont pas ce port répertorié, ils ne seront pas ajoutés à la liste des endpoints.

    Vérifiez que le containerPort du pod correspond au targetPort du service


### Control Plane troubleshooting

- Vérifier l'état des composants du Controlplane  

    $ kubectl get componentstatus
    NAME                 STATUS    MESSAGE   ERROR
    controller-manager   Healthy   ok        
    scheduler            Healthy   ok 
    
- Vérifier l'état des nœuds  

    $ kubectl get nodes 
    NAME       STATUS   ROLES   AGE   VERSION
    worker-1   Ready    worker   8d   v1.21.0
    worker-2   Ready    worker   8d   v1.21.0
    master-1   Ready    master   8d   v1.21.0


### Control Plane troubleshooting

- Vérifier les pods du Controlplane 

    $ kubectl get pods -n kube-systems 
    NAME                           READY    STATUS   RESTARTS   AGE
    coredns-78fcdf6894-5dntv       1/1      Running  0          1h
    coredns-78fcdf6894-knpzl       1/1      Running  0          1h
    etcd-master                    1/1      Running  0          1h
    kube-apiserver-master          1/1      Running  0          1h
    kube-controller-manager-master 1/1      Running  0          1h
    kube-proxy-fvbpj               1/1      Running  0          1h
    kube-proxy-v5r2t               1/1      Running  0          1h
    kube-scheduler-master          1/1      Running  0          1h
    weave-net-7kd52                2/2      Running  1          1h
    weave-net-jtl5m                2/2      Running  1          1h


### Control Plane troubleshooting

- Vérifier les services du Controlplane

    $ service kube-apiserver status
    ● kube-apiserver.service - Kubernetes API Server
    Loaded: loaded (/etc/systemd/system/kube-apiserver.service; enabled; vendor preset: enabled)
    Active: active (running) since Wed 2019-03-20 07:57:25 UTC; 1 weeks 1 days ago
    Docs: https://github.com/kubernetes/kubernetes
    Main PID: 15767 (kube-apiserver)
    Tasks: 13 (limit: 2362)

    répétez le même process pour les autres services tels que:  kube-controller-manager, kube-scheduler, kubelet,  kube-proxy 


### Control Plane troubleshooting

- Vérifier les logs de service

    $ kubectl logs kube-apiserver-master -n kube-system
    I0401 13:45:38.190735 1 server.go:703] external host was not specified, using 172.17.0.117
    I0401 13:45:38.194290 1 server.go:145] Version: v1.11.3
    I0401 13:45:38.819705 1 plugins.go:158] Loaded 8 mutating admission controller(s) successfully in the following order:
    NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,Priority,DefaultTolerationSeconds,DefaultStorageClass,MutatingAdmissionWebhook.
    I0401 13:45:38.819741 1 plugins.go:161] Loaded 6 validating admission controller(s) successfully in the following order:
    LimitRanger,ServiceAccount,Priority,PersistentVolumeClaimResize,ValidatingAdmissionWebhook,ResourceQuota.
    I0401 13:45:38.821372 1 plugins.go:158] Loaded 8 mutating admission controller(s) successfully in the following order:
    NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,Priority,DefaultTolerationSeconds,DefaultStorageClass,MutatingAdmissionWebhook.
    I0401 13:45:38.821410 1 plugins.go:161] Loaded 6 validating admission controller(s) successfully in the following order:
    LimitRanger,ServiceAccount,Priority,PersistentVolumeClaimResize,ValidatingAdmissionWebhook,ResourceQuota.
    I0401 13:45:38.985453 1 master.go:234] Using reconciler: lease
    W0401 13:45:40.900380 1 genericapiserver.go:319] Skipping API batch/v2alpha1 because it has no resources.
    W0401 13:45:41.370677 1 genericapiserver.go:319] Skipping API rbac.authorization.k8s.io/v1alpha1 because it has no resources.
    W0401 13:45:41.381736 1 genericapiserver.go:319] Skipping API scheduling.k8s.io/v1alpha1 because it has no resources.


### Node troubleshooting

- Vérifier l'état du nœud

    $ kubectl get nodes
    NAME       STATUS   ROLES   AGE   VERSION
    worker-1   Ready    <none>   8d   v1.21.0
    worker-2   NotReady <none>   8d   v1.21.0

    $ kubectl describe node worker-1
    ...
    Conditions:
        Type           Status   LastHeartbeatTime              Reason                       Message
        ----           ------   -----------------              ------                       -------
        OutOfDisk      False    Mon, 01 Apr 2019 14:30:33 +0000 KubeletHasSufficientDisk    kubelet has sufficient disk space available
        MemoryPressure False    Mon, 01 Apr 2019 14:30:33 +0000 KubeletHasSufficientMemory  kubelet has sufficient memory available
        DiskPressure   False    Mon, 01 Apr 2019 14:30:33 +0000 KubeletHasNoDiskPressure    kubelet has no disk pressure
        PIDPressure    False    Mon, 01 Apr 2019 14:30:33 +0000 KubeletHasSufficientPID     kubelet has sufficient PID available
        Ready          True     Mon, 01 Apr 2019 14:30:33 +0000 KubeletReady                kubelet is posting ready status. AppArmor enabled


### Node troubleshooting

    $ kubectl describe node worker-2
    Conditions:
        Type           Status    LastHeartbeatTime               Reason                   Message
        ----           ------    -----------------               ------                   -------
        OutOfDisk      Unknown   Mon, 01 Apr 2019 14:20:20 +0000 NodeStatusUnknown        Kubelet stopped posting node status.
        MemoryPressure Unknown   Mon, 01 Apr 2019 14:20:20 +0000 NodeStatusUnknown        Kubelet stopped posting node status.
        DiskPressure   Unknown   Mon, 01 Apr 2019 14:20:20 +0000 NodeStatusUnknown        Kubelet stopped posting node status.
        PIDPressure    False     Mon, 01 Apr 2019 14:20:20 +0000 KubeletHasSufficientPID  kubelet has sufficient PID available
        Ready          Unknown   Mon, 01 Apr 2019 14:20:20 +0000 NodeStatusUnknown        Kubelet stopped posting node status.  


### Node troubleshooting

- Vérifier les certificats

    $ openssl x509 -in /var/lib/kubelet/worker-1.crt -text
    Certificate:
        Data:
            Version: 3 (0x2)
            Serial Number:
                ff:e0:23:9d:fc:78:03:35
        Signature Algorithm: sha256WithRSAEncryption
            Issuer: <CN = KUBERNETES-CA>
            Validity
                Not Before: Mar 20 08:09:29 2019 GMT
                <Not After : Apr 19 08:09:29 2019 GMT>
        Subject: CN = system:node:worker-1, O = system:nodes
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                00:b4:28:0c:60:71:41:06:14:46:d9:97:58:2d:fe:
                a9:c7:6d:51:cd:1c:98:b9:5e:e6:e4:02:d3:e3:71:
                ...