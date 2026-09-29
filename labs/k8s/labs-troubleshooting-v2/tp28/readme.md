### Exercice 28/30 : Crash applicatif suite à une incohérence de paire de clés TLS dans un Secret (Niveau : Ultra compliqué / Expert)

* **Objectif :** Diagnostiquer et corriger un échec de démarrage d'un serveur web sécurisé causé par une incompatibilité entre le certificat public et la clé privée stockés dans un Secret Kubernetes (`key values mismatch`).
* **Contexte :** À la suite du renouvellement d'un certificat TLS pour l'application `secure-api`, le Secret Kubernetes a été mis à jour. Depuis cette intervention, le Pod plante en boucle au démarrage sans qu'aucun changement n'ait été apporté au code de l'application ou à la structure des manifests.

```yaml
# --- MANIFESTE BOGUÉ (bad-app.yaml) ---
# Problème : Le Secret "api-tls-secret" contient une clé privée "tls.key" qui ne correspond pas au certificat public "tls.crt".
# NGINX détecte le mismatch au chargement de la configuration SSL et interrompt brutalement son processus principal.
apiVersion: v1
kind: Secret
metadata:
  name: api-tls-secret
  namespace: default
type: kubernetes.io/tls
data:
  # ERREUR : Certificat généré à partir de la Paire A (Clé A) - Encodé en base64
  tls.crt: |
    LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJqVENDQVRTZ0F3SUJBZ0lVT3U4WkJtTDBi
    MUZ4NndjR05wL25KdW5HSm1vd0RRWUpLb1pJdmNOQVFFTQpCUVF3RmpFVU1CSUdBMTFVRUF3d0xZ
    WEE1TG5SbGNzT3JnQUJNMEYwWEpDTXdNREF4TkRFNU1qQXpPak01TmpVeQpOem93TURBeE5ERTVN
    akF6T2pNNU5qVXlOemF3RmpFVU1CSUdBMTFVRUF3d0xZWEE1TG5SbGNzT3JnQUJ3Z2dFaQpNQTBH
    Q1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS2BBT0NBUUVBME15TGdUY2s4RDRxU0h6Wnh2RGwK
    LS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
  # ERREUR : Clé privée issue de la Paire B (Clé B) - Incompatible avec tls.crt ci-dessus
  tls.key: |
    LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBMUxkOW1YRW9p
    V1JsaVBDNElyTW4vNW1OOGlhWWJ1bEptNmRpQU5SQUd4TG93S1JRCi0tLS0tRU5EIFJTQSBQUklW
    QVRFIEtFWS0tLS0tCg==
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-api
  template:
    metadata:
      labels:
        app: secure-api
    spec:
      containers:
      - name: nginx
        image: nginx:1.25-alpine
        ports:
        - containerPort: 443
        volumeMounts:
        - name: tls-certs
          mountPath: /etc/nginx/certs
          readOnly: true
        - name: config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: tls-certs
        secret:
          secretName: api-tls-secret
      - name: config
        configMap:
          name: nginx-ssl-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-ssl-config
  namespace: default
data:
  default.conf: |
    server {
        listen 443 ssl;
        ssl_certificate /etc/nginx/certs/tls.crt;
        ssl_certificate_key /etc/nginx/certs/tls.key;
        location / {
            return 200 'SSL Handshake OK';
        }
    }

```

```yaml
# --- MANIFESTE CORRIGÉ (fixed-app.yaml) ---
apiVersion: v1
kind: Secret
metadata:
  name: api-tls-secret
  namespace: default
type: kubernetes.io/tls
data:
  # CORRECTION : Le certificat et la clé privée proviennent de la MÊME paire RSA générée.
  # (Pour générer une paire de test valide : openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=app.local")
  tls.crt: <BASE64_CERTIFICAT_VALIDE>
  tls.key: <BASE64_CLE_PRIVEE_CORRESPONDANTE>
---
# [Le reste du Deployment et de la ConfigMap demeurent identiques]

```

**Démarche de résolution pour l'apprenant :**

1. Constater le crash récurrent du Pod : `kubectl get pods` (statut `CrashLoopBackOff`).
2. Consulter les logs du conteneur : `kubectl logs deployment/secure-api`.
3. Identifier le message d'erreur NGINX / OpenSSL :
`[emerg] 1#1: SSL_CTX_use_PrivateKey_file("/etc/nginx/certs/tls.key") failed (SSL: error:0B080074:x509 certificate routines:X509_check_private_key:key values mismatch)`.
4. Inspecter les clés contenues dans le Secret Kubernetes :
`kubectl get secret api-tls-secret -o jsonpath='{.data.tls\.crt}' | base64 -d > crt.pem`
`kubectl get secret api-tls-secret -o jsonpath='{.data.tls\.key}' | base64 -d > key.pem`
5. Vérifier l'incohérence des empreintes (*modulus*) via OpenSSL :
`openssl x509 -noout -modulus -in crt.pem | openssl md5`
`openssl rsa -noout -modulus -in key.pem | openssl md5`
Observer que les deux empreintes MD5 diffèrent.
6. Générer ou réinjecter une paire clé/certificat concordante dans le Secret `api-tls-secret` puis redémarrer le Pod.

---