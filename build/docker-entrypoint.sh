#!/bin/bash

JWT_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

function echo_err() {
    echo -e "$(date) ERROR: ${1?}"
}

function echo_info() {
    echo -e "$(date) INFO: ${1?}"
}

function echo_warn() {
    echo -e "$(date) WARN: ${1?}"
}

function trap_sigterm() {
    echo_warn "Clean shutdown of Vault Agent.."
    exit 0
}

trap 'trap_sigterm' SIGINT SIGTERM

while [[ ${TOKEN} == "" ]]
do
    sleep 5
    echo_info "Attempting to receive login token from Vault.."
    TOKEN=$(vault write auth/kubernetes/login -field=token role=demo jwt=${JWT_TOKEN?})

    if [[ ${TOKEN} == "" ]]
    then
        echo_warn "Could not receive token, trying again.."
    fi
done

echo_info "Received login token, logging in.."

vault login ${TOKEN?}
if [[ $? -ne 0 ]]
then
    echo_err "Could not login, exiting.."
    exit 1
fi

vault read secret/demo

sleep 10000 &

wait
