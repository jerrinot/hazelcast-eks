#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

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
kubectl create configmap hazelcast-configuration --from-file="$DIR/hazelcast-config.yaml"
kubectl apply -f "$DIR/hazelcast-statefulset.yaml"
kubectl scale statefulset hazelcast --replicas=$nodes
kubectl wait --for=condition=Ready pods --all

for pod in $(kubectl get pods -o jsonpath="{.items[*].metadata.name}"); do \
  kubectl create service nodeport ${pod} --tcp=5701 -o yaml --dry-run=client | kubectl set selector --local -f - "statefulset.kubernetes.io/pod-name=${pod}" -o yaml | kubectl create -f -; \
done

echo Done
