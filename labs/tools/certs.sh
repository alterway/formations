#!/usr/bin/env bash

# Create self-signed certificates and keys for a CA and a server
# Primarily for using with SSL/TLS to secure communications
# between local servers and clients NOT ON THE INTERNET!
#
# Inspired by: https://github.com/Daplie/nodejs-self-signed-certificate-example/blob/master/make-root-ca-and-certificates.sh
#
# Use as: bash make-certs.sh 'localhost.daplie.com'
#
# Author: Julian Knight, Totally Information, 2016-11-05
# Updates:
#   v1.1 2017-12-08: JK change to add SAN as now required by Chrome
# License: MIT, may be freely reused.

function create_ca {
  # ------------------- CA -------------------- #
  # You can reuse CA certs, no need to recreate #
  # unless they are compromised                 #
  # ------------------------------------------- #

  # Create/update the ca/ca.cnf file
  create_ca_cnf

  # We need the ca.cnf file in order to create the CA cert
  if [ ! -f ca/ca.cnf ]; then
    echo " "
    echo "ERROR in create_ca() - STOPPING"
    echo "  The ca/ca.cnf file does not exist."
    echo "  Please ensure the cnf setup function has been run."
    echo " "
    exit 1
  fi

  echo " "
  echo "Creating Root Certificate Authority private key"
  openssl genrsa \
    -out ca/my-private-root-ca.privkey.pem \
    2048

  echo " "
  echo "Creating the Self-signed Root Certificate Authority certificate"
  # Since this is private, the details can be as bogus as you like
  openssl req \
    -x509 \
    -new \
    -nodes \
    -days 9999 \
    -outform PEM \
    -key  ca/my-private-root-ca.privkey.pem \
    -out  ca/my-private-root-ca.cert.pem \
    -config ca/ca.cnf

  # Create CRT format copy for Windows use if needed
  openssl x509 -in ca/my-private-root-ca.cert.pem -out ca/my-private-root-ca.cert.crt

  echo " "
  echo "Import ca/my-private-root-ca.cert.crt to Windows Trusted Root store if required"
  echo "  or use load-trusted-root.ps1"
}

function create_srv {
  # ------------- Server ------------- #
  # Need one of these for each server  #
  # where you want different certs     #
  # ---------------------------------- #

  # Create/update the ./ssl.cnf file
  create_ssl_cnf

  # We need the ./ssl.cnf file in order to create the CA cert
  if [ ! -f ./ssl.cnf ]; then
    echo " "
    echo "ERROR in create_srv() - STOPPING"
    echo "  The ./ssl.cnf file does not exist."
    echo "  Please ensure the create_cnf function has been run."
    echo " "
    exit 1
  fi

  # We need the ca/ca.cnf file in order to sign the server cert request
  if [ ! -f ca/ca.cnf ]; then
    echo " "
    echo "ERROR in create_srv() - STOPPING"
    echo "  The ca/ca.cnf file does not exist."
    echo "  Please ensure the create_cnf function has been run."
    echo " "
    exit 1
  fi

  # We need the CA private key and certificate files in order to create a server certificate
  if [ ! \( -f ca/my-private-root-ca.cert.pem -a -f ca/my-private-root-ca.privkey.pem \) ]; then
    echo " "
    echo "ERROR in create_srv() - STOPPING"
    echo "  The CA private key and/or certificate files are missing."
    echo "  Please ensure the create_ca function has been run."
    echo " "
    exit 1
  fi

  echo " "
  echo "Creating a Server Private Key - KEEP THIS SECURE ON THE SERVER!"
  echo "  It is required for the server to use SSL or TLS."
  openssl genrsa \
    -out server/privkey.pem \
    2048

  echo " "
  echo "Creating a temp request (CSR) from your Server, which your Root CA will sign"
  # 1 for each domain such as 192.168.1.167, example.com, *.example.com, awesome.example.com
  # NOTE: You MUST match CN to the domain name or ip address you want to use
  # Multi-domain certs require the use of a configuration file and SubjectAltName
  openssl req -new -sha256 \
    -key  server/privkey.pem \
    -out  tmp/csr.pem \
    -config ./ssl.cnf

  echo " "
  echo "Signing the server request with your Root CA, creates the actual server cert"
  openssl x509 \
    -CAcreateserial -req \
    -extfile v3ext.cnf \
    -in    tmp/csr.pem \
    -CA    ca/my-private-root-ca.cert.pem \
    -CAkey ca/my-private-root-ca.privkey.pem \
    -out   server/cert.pem \
    -outform PEM \
    -days  9999
  #openssl ca -config ./ssl.cnf \
  #    -extensions server_cert -days 9999 -notext -md sha256 \
  #    -in tmp/csr.pem \
  #    -out server/cert.pem
  # NOTE use of -extfile here, it appears to be the only successful
  #      way to pass in the x509 extension parameters without using
  #      the ca function instead of the x509 one.

  echo " "
  echo "Creating a combined pfx file for convenience"
  openssl pkcs12 -export \
    -certfile ca/my-private-root-ca.cert.pem \
    -inkey server/privkey.pem \
    -in server/cert.pem \
    -out server/cert.pfx \
    -name "Self-Signed Server Certificate"

  #echo " "
  #echo "Copying root ca cert to server as chain.pem"
  #echo "  This is only required if NOT using the fullchain certificate."
  #rsync -a ca/my-private-root-ca.cert.pem server/chain.pem

  echo " "
  echo "Creating a server full chain cert for SSL/TLS use"
  echo "  Using fullchain removes the need to include the ca parameter in server settings."
  cat server/cert.pem ca/my-private-root-ca.cert.pem > server/fullchain.pem

  echo " "
  echo "Use in Node.JS as: sslOpts = { key: 'server/privkey.pem', cert: 'server/fullchain.pem' }"
  echo "  as this is self-signed, use of ca opt isn't required as it is included in the chain"

}

function create_client {
  # -------------- Client -------------- #
  # Need one of these for each client    #
  # you want to authenticate to a server #
  # ------------------------------------ #

  # We need the ./ssl.cnf file in order to create the CA cert
  if [ ! -f ./ssl.cnf ]; then
    echo " "
    echo "ERROR - STOPPING"
    echo "  The ./ssl.cnf file does not exist."
    echo "  Please ensure the create_cnf function has been run."
    echo " "
    exit 1
  fi

  # We need the CA certificate
  if [ ! -f ca/my-private-root-ca.cert.pem ]; then
    echo " "
    echo "ERROR - STOPPING"
    echo "  The CA certificate file is missing."
    echo "  Please ensure the create_ca function has been run."
    echo " "
    exit 1
  fi

  # We need the SERVER private key
  if [ ! -f server/privkey.pem ]; then
    echo " "
    echo "ERROR - STOPPING"
    echo "  A SERVER private key is needed."
    echo "  Please ensure the create_srv function has been run."
    echo " "
    exit 1
  fi

  #echo " "
  #echo "Copying root ca cert to client folder as chain.pem"
  #echo "  This is only required if NOT using the fullchain certificate."
  #rsync -a ca/my-private-root-ca.cert.pem client/chain.pem

  echo " "
  echo "Create a public key to match an existing server."
  echo "  In case you want a client to be able to encrypt messages to this server."
  echo "  Not required for simply accessing SSL/TLS web pages"
  openssl rsa -pubout \
    -in  server/privkey.pem \
    -out client/server-pubkey.pem

  echo " "
  echo "Create DER format crt file for iOS Mobile Safari, etc"
  openssl x509 \
    -outform der \
    -in  ca/my-private-root-ca.cert.pem \
    -out client/my-private-root-ca.crt
}

function create_ca_cnf {
  # This is the configuration file for creatin a CA root certificate

  echo " "
  echo "Creating CA OpenSSL configuration file for certificate creation"

  # Required as this is the only way to add SubjectAltName fields which are now required
  # by Chrome.
  cat >ca/ca.cnf <<EOL
  [ req ]
  prompt = no
  default_bits = 2048
  default_md = sha384  # SHA-1 is deprecated, so use SHA-2 (sha256) or SHA-3 (sha384) instead.
  default_days = 9999
  x509_extensions = root_ca_extensions
  distinguished_name = root_ca_distinguished_name
  copy_extensions = copy   # Copy extensions specified in the certificate request

  [ root_ca_extensions ]
  # Extensions for a typical CA (man x509v3_config).
  subjectKeyIdentifier = hash
  authorityKeyIdentifier = keyid:always,issuer
  basicConstraints = critical, CA:true
  keyUsage = critical, digitalSignature, cRLSign, keyCertSign

  [ root_ca_distinguished_name ]
  commonName = $ORGANIZATION Root Certificate Authority
  stateOrProvinceName = $STATE
  countryName = $COUNTRY
  emailAddress = $EMAIL
  organizationName = $ORGANIZATION
  organizationalUnitName = $ORGANIZATION_UNIT
  L = $CITY

EOL
}

function create_ssl_cnf {
  # Now that Chrome requires SubjectAltNames to be defined in all certificates
  # we cannot define the certs just using command line parameters.
  # Instead we have to use a configuration file and to specify x509 v3 parameters.

  echo " "
  echo "Creating non-ca OpenSSL configuration file for certificate creation"
  echo "  with Subject Alt Names to satisfy modern browsers"

  # Required as this is the only way to add SubjectAltName fields which are now required
  # by Chrome.
  cat >./ssl.cnf <<EOL
  [ req ]
  prompt = no
  default_bits = 2048
  default_md = sha256  # SHA-1 is deprecated, so use SHA-2 (sha256) or SHA-3 (sha384) instead.
  default_days = 9999
  req_extensions = v3_req
  distinguished_name = req_distinguished_name

  [ v3_req ]
  # Extensions for server certificates (`man x509v3_config`).
  basicConstraints = CA:FALSE
  subjectKeyIdentifier = hash
  authorityKeyIdentifier = keyid,issuer:always
  keyUsage = critical, digitalSignature, keyEncipherment, dataEncipherment
  extendedKeyUsage = serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCTLSign, msEFS
  subjectAltName = @alt_names

  [ req_distinguished_name ]
  commonName = $FQDN                            # CN
  stateOrProvinceName = $STATE                  # ST
  countryName = $COUNTRY                        # C
  emailAddress = $EMAIL
  organizationName = $ORGANIZATION              # O
  organizationalUnitName = $ORGANIZATION_UNIT   # OU
  L = $CITY

  [alt_names]
  DNS.1 = $FQDN
  IP.1 = $FQDN
  # Comment out the localhost/127 addresses if not required
  DNS.2 = localhost
  DNS.3 = 127.0.0.1
  IP.2 = 127.0.0.1
  # If using for email sign/encrypt
  #email.1 = copy
  #email.2 = me@$HOSTNAME.$DOT
EOL
# NOTE: This is a subset of the above config file but it seems that
#       it is the only way to successfully manually pass this data
#       into the server/client certificate creation command.
cat >./v3ext.cnf <<EOL
  # Extensions for server certificates (`man x509v3_config`).
  basicConstraints = CA:FALSE
  subjectKeyIdentifier = hash
  authorityKeyIdentifier = keyid,issuer:always
  keyUsage = critical, digitalSignature, keyEncipherment, dataEncipherment
  extendedKeyUsage = serverAuth, clientAuth, codeSigning, emailProtection, timeStamping, msCodeInd, msCTLSign, msEFS
  subjectAltName = @alt_names

  [alt_names]
  DNS.1 = $FQDN
  IP.1 = $FQDN
  # Comment out the localhost/127 addresses if not required
  DNS.2 = localhost
  DNS.3 = 127.0.0.1
  IP.2 = 127.0.0.1
  # If using for email sign/encrypt
  #email.1 = copy
  #email.2 = me@$HOSTNAME.$DOT
EOL
}

function verify_cert {
  echo " "
  echo "Dumping server certificate details to console ..."
  echo " "
  openssl x509 -text -noout -in server/fullchain.pem
  echo " "
}

function verify_hashes {
  openssl x509 -noout -modulus -in server/fullchain.pem | openssl md5
  openssl rsa -noout -modulus -in server/privkey.pem | openssl md5
}

function verify_csr {
  openssl req -text -noout -verify -in tmp/csr.pem
}

echo "**********************************************************************************"
echo "* Create a Certificate Authority certificate and keys along with a server and    *"
echo "* a client certificate based on the CA.                                          *"
echo "*                                                                                *"
echo "* Use the resulting server certificate for running servers (e.g. Apache, NGINX,  *"
echo "* Node.JS, ExpressJS, etc.) with SSL/TLS encrypted connections.                  *"
echo "*                                                                                *"
echo "* Use the CA's PUBLIC certificate on every client that may access the server by  *"
echo "* importing the CA public certificate into the client's trusted root certificate *"
echo "* store. This stops clients (e.g. browsers) from complaining that the server's   *"
echo "* certificate is 'untrusted'.                                                    *"
echo "*                                                                                *"
echo "* This saves you from having to purchase an expensive certificate from a         *"
echo "* publically trusted certificate authority. It also saves the problems           *"
echo "* with trying to get Let's Encrypt free certificates working on private          *"
echo "* networks.                                                                      *"
echo "*                                                                                *"
echo "* This script creates the following folders under the current location:          *"
echo "*    ./server   :: Server certificates                                           *"
echo "*    ./client   :: Client certificates and CA public certificate                 *"
echo "*    ./ca       :: CA Certificates - keep these safe, OFFLINE!                   *"
echo "*                  The CA certificates can (and should) be reused to create new  *"
echo "*                  server and client certificates.                               *"
echo "**********************************************************************************"
echo "* VERSION: 1.1 2017-11-08                                                        *"
echo "**********************************************************************************"
echo " "

if [[ ! ${1+x} ]]; then
	echo "No FQDN parameter given - assuming 192.168.1.1"
  FQDN="192.168.1.1"
else
	echo "FQDN is '$1'"
  FQDN=$1
fi

echo " "

# PLEASE UPDATE THE FOLLOWING VARIABLES FOR YOUR NEEDS.
HOSTNAME="alterway"
DOT="fr"
COUNTRY="FR"
STATE="virtual"
CITY="StCloud"
ORGANIZATION="alterway"
ORGANIZATION_UNIT="DT"
EMAIL="herve@$HOSTNAME.$DOT"
# ----------------------------------------------------

echo " "
echo "Creating working folders"
mkdir -p ./{server,client,ca,tmp}

# Create CA - THIS IS OPTIONAL
#   reuse CA files where possible so that you don't
#   have to keep adding more CA certificates to your client's
#   Trusted Root Certificate store.
create_ca

# Create a server certificate & key
create_srv

# Create a client certificate & key
#   This would enable a client to authenticate to any server
#   that uses the same CA signed TLS connections.
create_client

# Check the server certificate
verify_cert

echo " "
echo "Tidy tmp"
#rm -R tmp


echo " "
echo " "
echo "You can now import client/my-private-root-ca.crt"
echo "  to client devices to make them recognise the private CA"
echo "The CA cert is also available in the certificate the server sends to the client."
echo " "
echo "**********************************************************************************"
echo "* The CA cert must be imported to every client's trusted root certificate store. *"
echo "**********************************************************************************"
echo "* TAKE THE ./ca FOLDER OFFLINE WHEN NOT IN USE. IF IT IS COMPROMISED, ALL OF     *"
echo "* YOUR CERTIFICATES WILL HAVE TO BE RE-CREATED AND THE OLD CA CERTS REMOVED FROM *"
echo "* ALL CLIENTS                                                                    *"
echo "**********************************************************************************"
echo " "
echo " "

# ------------- TESTING ------------- #
# Test your HTTPS effortlessly
#npm -g install serve-https
#serve-https --servername example.com --cert server/fullchain.pem --key certs/server/privkey.pem

# You can debug the certificate chain with openssl:
#openssl s_client -showcerts -connect example.com:443 -servername example.com
#openssl s_client -showcerts -connect 127.0.0.1:1880 -servername 192.168.1.167

# ------------- How to use --------- #
# Use in Windows
# Simply import the CA Cert (./ca/my-private-root-ca.cert.pem) into the Trusted Root Cert Auth using the certificates snapin in mmc

# In Node-RED's settings.js, use the following:
#
# FIRSTLY: npm install ssl-root-cas --save
#
#
#    // See http://nodejs.org/api/https.html#https_https_createserver_options_requestlistener
#	 // http://qugstart.com/blog/node-js/install-comodo-positivessl-certificate-with-node-js/
#	 // http://www.benjiegillam.com/2012/06/node-dot-js-ssl-certificate-chain/
#    https: {
#        key: fs.readFileSync( path.join('.', '.data', 'certs', 'server', 'privkey.pem') ),
#        cert: fs.readFileSync( path.join('.', '.data', 'certs', 'server', 'cert.pem') ),
#		 ca: fs.readFileSync( path.join('.', '.data', 'certs', 'server', 'fullchain.pem') ),
#    },

# ------------- Useful References ------------- #
# https://stackoverflow.com/questions/43665243/chrome-invalid-self-signed-ssl-cert-subject-alternative-name-missing/43665244#43665244 - explains the -extfile part, see the comments
# https://geekflare.com/openssl-commands-certificates/
# https://spin.atomicobject.com/2014/05/12/openssl-commands/

# NOTE: In Chrome, for localhost only, you can ignore cert errors chrome://flags/#allow-insecure-localhost

### EOF ###