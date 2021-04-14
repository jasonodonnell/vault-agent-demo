#!/bin/bash

kubectl delete deployment app -n app
kubectl delete serviceaccount app -n app
kubectl delete secretproviderclass vault-db-creds -n app
