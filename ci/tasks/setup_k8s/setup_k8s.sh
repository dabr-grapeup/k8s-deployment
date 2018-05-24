#!/bin/bash -ex

# GET CREDS
pushd bosh_state
    tar -xvf ${BOSH_STATE_FILENAME}
popd

# SETUP CREDHUB
export CREDHUB_BOSH_URL=https://$(cat bosh_state/bosh_ip):8844
export CREDHUB_BOSH_USERNAME=director_to_credhub
export CREDHUB_BOSH_PASSWORD=$(bosh int bosh_state/creds.yml --path /uaa_clients_director_to_credhub)

credhub login --server ${CREDHUB_BOSH_URL} --client-name ${CREDHUB_BOSH_USERNAME} --client-secret ${CREDHUB_BOSH_PASSWORD} --skip-tls-validation

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int bosh_state/creds.yml --path /admin_password)"
export BOSH_IP=$(cat bosh_state/bosh_ip)
export BOSH_CA_CERT="$(bosh int bosh_state/creds.yml --path /director_ssl/ca)"
export BOSH_ENVIRONMENT=bosh
export BOSH_DEPLOYMENT=cfcr
bosh alias-env ${BOSH_ENVIRONMENT} -e ${BOSH_IP}

credhub get -n "${BOSH_ENVIRONMENT}/${BOSH_DEPLOYMENT}/kubo-admin-password"

K8S_ADMIN_PASSWORD=$(bosh int <(credhub get -n "${BOSH_ENVIRONMENT}/${BOSH_DEPLOYMENT}/kubo-admin-password" --output-json) --path=/value)
K8S_ADMIN_USERNAME="cfcr:${BOSH_ENVIRONMENT}:${BOSH_DEPLOYMENT}-admin"
K8S_MASTER_HOST=$(bosh int <(bosh instances --json) --path /Tables/0/Rows/1/ips)
K8S_CLUSTER_NAME="cfcr:${BOSH_ENVIRONMENT}:${BOSH_DEPLOYMENT}"
K8S_CONTEXT_NAME="cfcr:${BOSH_ENVIRONMENT}:${BOSH_DEPLOYMENT}"

credhub login --server ${CREDHUB_URL} --client-name ${CREDHUB_USERNAME} --client-secret ${CREDHUB_PASSWORD} --skip-tls-validation

credhub set -n "/automation/${CREDHUB_TEAM}/k8s_admin_password" -t value -v ${K8S_ADMIN_PASSWORD}
credhub set -n "/automation/${CREDHUB_TEAM}/k8s_admin_username" -t value -v ${K8S_ADMIN_USERNAME}
credhub set -n "/automation/${CREDHUB_TEAM}/k8s_master_host" -t value -v ${K8S_MASTER_HOST}
credhub set -n "/automation/${CREDHUB_TEAM}/k8s_cluster_name" -t value -v ${K8S_CLUSTER_NAME}
credhub set -n "/automation/${CREDHUB_TEAM}/k8s_context_name" -t value -v ${K8S_CONTEXT_NAME}