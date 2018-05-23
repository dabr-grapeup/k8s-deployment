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

# SETUP AWS
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}

# UPLOAD RELEASE (todo it should be probably compiled first, using precompiled for now)

aws s3 cp "${KUBO_RELEASE}" kubo.tgz --region ${AWS_REGION}

bosh upload-release kubo.tgz

# DEPLOY K8s
bosh -n -d cfcr deploy k8s_deployment/kubo-deployment/manifests/cfcr.yml \
    -o vm-types.yml \
    -v addons_vm_type=general_nano \
    -v worker_vm_type=memory_small \
    -v master_vm_type=general_small