#!/bin/bash -ex

function usage {
    echo "usage: configure.sh <WORKSPACE_DIR>"
    exit 1
}

WORKSPACE_DIR="$1"

if [[ -z "${WORKSPACE_DIR}" ]]; then
    usage
fi

# kubectl cli
command -v kubectl || {
    pushd "${WORKSPACE_DIR}"
        wget -o /dev/null -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin
    popd
}

# user login actions
if [[ -z "$(grep kubectl_config ~/.bashrc)" ]]; then
  echo '. $HOME/.kubectl_config' >> ~/.bashrc
fi

. $HOME/.bosh_envs
export BOSH_ENVIRONMENT=bosh
export BOSH_DEPLOYMENT=cfcr

# setup credhub
credhub_login

K8S_ADMIN_PASSWORD=$(bosh int <(credhub get -n "${BOSH_ENVIRONMENT}/${BOSH_DEPLOYMENT}/kubo-admin-password" --output-json) --path=/value)
K8S_ADMIN_USERNAME="cfcr:${BOSH_ENVIRONMENT}:${BOSH_DEPLOYMENT}-admin"
K8S_MASTER_HOST=$(bosh int <(bosh instances --json) --path /Tables/0/Rows/1/ips)
K8S_CLUSTER_NAME="cfcr:${BOSH_ENVIRONMENT}:${BOSH_DEPLOYMENT}"
K8S_CONTEXT_NAME="cfcr:${BOSH_ENVIRONMENT}:${BOSH_DEPLOYMENT}"

# create kubectl_config file
echo "
kubectl config set-cluster "${K8S_CLUSTER_NAME}" \
  --server="https://${K8S_MASTER_HOST}:8443" \
  --insecure-skip-tls-verify=true
kubectl config set-credentials "${K8S_ADMIN_USERNAME}" --token="${K8S_ADMIN_PASSWORD}"
kubectl config set-context "${K8S_CONTEXT_NAME}" --cluster="${K8S_CONTEXT_NAME}" --user="${K8S_ADMIN_USERNAME}"
kubectl config use-context "${K8S_CONTEXT_NAME}"
" > ~/.kubectl_config