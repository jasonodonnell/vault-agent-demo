#!/bin/bash

kubectl delete deployment $(kubectl get deployments | grep "demo-" | awk '{print $1}') -n app
kubectl delete serviceaccount app -n app
kubectl delete service demo -n app

rm -rf ./.waypoint
rm -rf ./.build
