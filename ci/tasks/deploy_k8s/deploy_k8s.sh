#!/bin/bash -ex

# GET CREDS
pushd bosh_state
    tar -xvf ${BOSH_STATE_FILENAME}
popd

# SETUP BOSH
export BOSH_IP=$(cat bosh_state/bosh_ip)
export BOSH_CA_CERT="$(bosh int bosh_state/creds.yml --path /director_ssl/ca)"
export BOSH_ENVIRONMENT=${BOSH_IP}
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int bosh_state/creds.yml --path /admin_password)"

# DEPLOY K8s
bosh -n -d cfcr deploy k8s_deployment/kubo-deployment/manifests/cfcr.yml