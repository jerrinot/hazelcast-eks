#!/bin/sh

kubectl delete statefulsets.apps hazelcast
kubectl delete configmaps hazelcast-configuration

hz_services=$(kubectl get services -o name|grep hazelcast)
IFS='
'
for item in $hz_services
do
  kubectl delete $item
done
