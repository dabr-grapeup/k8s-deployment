#!/bin/bash -ex

JUMPBOX_IP=$(terraform output -state=terraform_state/${TERRAFORM_STATE_FILENAME} jumpbox_private_ip)

echo "${JUMPBOX_PRIVATE_KEY}" > jumpbox.pem
chmod 400 *.pem

JUMPBOX_WORKDIR="/home/ubuntu/configure_jumpbox_k8s_workspace"

# PREPARE ENV
ssh -o StrictHostKeyChecking=no -i jumpbox.pem "ubuntu@${JUMPBOX_IP}" "rm -Rf ${JUMPBOX_WORKDIR}; mkdir -p ${JUMPBOX_WORKDIR}"

# UPLOAD REQUIRED FILES
scp -o StrictHostKeyChecking=no -i jumpbox.pem cf_deployment/ci/tasks/configure_jumpbox/scripts/* "ubuntu@${JUMPBOX_IP}:${JUMPBOX_WORKDIR}"

# RUN UPDATE SCRIPT
ssh -o StrictHostKeyChecking=no -i jumpbox.pem "ubuntu@${JUMPBOX_IP}" "chmod +x ${JUMPBOX_WORKDIR}/configure.sh; ${JUMPBOX_WORKDIR}/configure.sh ${JUMPBOX_WORKDIR}"

# SMOKE TESTS
ssh -o StrictHostKeyChecking=no -i jumpbox.pem "ubuntu@${JUMPBOX_IP}" "chmod +x ${JUMPBOX_WORKDIR}/test.sh; ${JUMPBOX_WORKDIR}/test.sh"
