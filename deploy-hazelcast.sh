#!/bin/sh

kubectl create configmap hazelcast-configuration --from-file=hazelcast-config.yaml
kubectl apply -f hazelcast-statefulset.yaml
