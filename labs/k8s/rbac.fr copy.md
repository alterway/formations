# Pour l'exercice pour un le rbac / kubeconfig utilisateur /

# Modifier avec votre tri-gramme 
TRIG="hel"


# A propos des certificats - meilleur méthode

openssl req -new -newkey rsa:4096 -nodes -keyout ${TRIG}-kubernetes.key -out ${TRIG}-kubernetes.csr -subj "/CN=${TRIG}/O=devops"

base64 ${TRIG}-kubernetes.csr | tr -d '\n' > ${TRIG}.csr


REQUEST=$(cat ${TRIG}.csr)

cat << EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${TRIG}-kubernetes-csr
spec:
  groups:
  - system:authenticated
  request: $REQUEST
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl get csr
kubectl certificate approve ${TRIG}-kubernetes-csr
kubectl get csr
# Certificat Utilisateur
kubectl get csr ${TRIG}-kubernetes-csr -o jsonpath='{.status.certificate}' | base64 --decode > ${TRIG}-kubernetes-csr.crt
# CA du serveur k8s
kubectl config view -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' --raw | base64 --decode - > kubernetes-ca.crt
# Création du kubeconfig
kubectl config set-cluster $(kubectl config view -o jsonpath='{.clusters[0].name}') --server=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}') --certificate-authority=kubernetes-ca.crt --kubeconfig=${TRIG}-kubernetes-config --embed-certs
# Context
kubectl config set-credentials ${TRIG} --client-certificate=${TRIG}-kubernetes-csr.crt --client-key=${TRIG}-kubernetes.key --embed-certs --kubeconfig=${TRIG}-kubernetes-config
# Stick to NS
#(Optionnel)
kubectl config set-context ${TRIG} --cluster=$(kubectl config view -o jsonpath='{.clusters[0].name}') --namespace=lab --user=${TRIG} --kubeconfig=${TRIG}-kubernetes-config