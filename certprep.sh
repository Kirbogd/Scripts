#!/bin/bash
#Script for base64 encoded self-signed pfx generation

# create a CA key

openssl genpkey -out CA.key -algorithm RSA -pkeyopt rsa_keygen_bits:2048

# Create a config file for CSR

RANDOM_PASSWORD=$(openssl rand -hex 10)

cat <<EOF >cacsr.conf
[ req ]
default_bits           = 2048
default_keyfile        = CA.key
distinguished_name     = req_distinguished_name
prompt                 = no


dirstring_type = nobmp

[ req_distinguished_name ]
 C                      = EU
 ST                     = SOMELOCATION
 L                      = SOMELOCATION
 O                      = ORGANIZATION
 OU                     = TestUnit
 CN                     = ca.test
 emailAddress           = test@email.address

EOF

# Create a CSR for the CA certificate

openssl req -new -passout pass:$RANDOM_PASSWORD -config cacsr.conf -out CA.csr

# Self-sign CA certificate

openssl x509 -req -days 365 -in CA.csr -signkey CA.key -out CA.crt -passin pass:$RANDOM_PASSWORD

# Create a key for the service certificate

openssl genpkey -out service.key -algorithm RSA -pkeyopt rsa_keygen_bits:2048

# Create a config file for service CSR

cat <<EOF >servicecsr.conf
[ req ]
default_bits           = 2048
default_keyfile        = service.key
distinguished_name     = req_distinguished_name
prompt                 = no

dirstring_type = nobmp

[ req_distinguished_name ]
 C                      = EU
 ST                     = SOMELOCATION
 L                      = SOMELOCATION
 O                      = ORGANIZATION
 OU                     = TestUnit
 CN                     = service.test
 emailAddress           = test@email.address
EOF

# Create a CSR for the service certificate

openssl req -new -passout pass:$RANDOM_PASSWORD -config servicecsr.conf -out service.csr

# Self-sign service certificate

openssl x509 -req -days 365 -in service.csr -CA CA.crt -CAkey CA.key -CAcreateserial -out service.crt -passin pass:$RANDOM_PASSWORD

# Convert certificate to pfx

openssl pkcs12 -export -out TestCert.pfx -inkey service.key -in service.crt -certfile CA.crt -passin pass:$RANDOM_PASSWORD -passout pass:$RANDOM_PASSWORD

# Encode certificate

BASE64_CERTDATA=$(base64 TestCert.pfx)

echo $BASE64_CERTDATA
