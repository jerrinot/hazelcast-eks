#!/bin/sh
kubectl create configmap hazelcast-configuration --from-file hazelcast-config.yaml -o yaml --dry-run=client|kubectl replace -f -
kubectl rollout restart statefulset hazelcast
