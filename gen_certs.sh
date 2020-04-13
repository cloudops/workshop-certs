#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# CREATE THE PRIVATE KEY FOR OUR CUSTOM CA
sudo sed -i 's/.*RANDFILE/#&/' /etc/ssl/openssl.cnf
openssl genrsa -out certs/ca.key 2048

# GENERATE A CA CERT WITH THE PRIVATE KEY
openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -config certs/ca_config.txt

# CREATE THE PRIVATE KEY FOR OUR WEBHOOK YAML
openssl genrsa -out certs/ca-key.pem 2048

# CREATE A CSR FROM THE CONFIGURATION FILE AND OUR PRIVATE KEY
openssl req -new -key certs/ca-key.pem -subj "/CN=auto-tracing-mutating-webhook.default.svc.cluster.local" -out ca.csr 

# CREATE THE CERT SIGNING THE CSR WITH THE CA CREATED BEFORE
openssl x509 -req -in ca.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/ca-crt.pem

# INJECT CA IN THE WEBHOOK CONFIGURATION
export CA_BUNDLE=$(cat certs/ca.crt | base64 | tr -d '\n')