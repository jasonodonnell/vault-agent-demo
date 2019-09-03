#!/bin/bash

set -e

function trap_sigterm() {
    echo_warn "Clean shutdown of Vault Agent.."
    exit 0
}

trap 'trap_sigterm' SIGINT SIGTERM

sleep 10000 &

wait
