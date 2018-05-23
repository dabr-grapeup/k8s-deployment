#!/bin/bash -ex

function usage {
    echo "usage: configure.sh <WORKSPACE_DIR>"
    exit 1
}

WORKSPACE_DIR="$1"

if [[ -z "${WORKSPACE_DIR}" ]]; then
    usage
fi

# cf cli
command -v kubectl || {
    pushd "${WORKSPACE_DIR}"
        wget -o /dev/null -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v1.10.3/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin
    popd
}