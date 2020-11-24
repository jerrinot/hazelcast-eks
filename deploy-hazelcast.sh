#!/bin/bash

hz_depl=$(kubectl get statefulsets.apps -o name|grep hazelcast)
if [ "$hz_depl" = "statefulset.apps/hazelcast" ]; then
   echo Hazelcast statefulset is already deployed. Undeploy first and then run this script again
   exit 1   
fi

hz_config=$(kubectl get configmaps -o name|grep hazelcast)
if [ "$hz_config" = "configmap/hazelcast-configuration" ]; then
  echo Hazelcast config map is already deployed. Undeplay first and then run this script again	
  exit 1
fi

nodes=$(kubectl get nodes -o name|wc -l)
echo Deploying Hazelcast to $nodes nodes
kubectl create configmap hazelcast-configuration --from-file=hazelcast-config.yaml
kubectl apply -f hazelcast-statefulset.yaml
echo Done
