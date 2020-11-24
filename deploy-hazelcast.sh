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
kubectl apply -f "$DIR/rbac.yaml"
kubectl apply -f "$DIR/hazelcast-statefulset.yaml"
kubectl scale statefulset hazelcast --replicas=$nodes

echo waiting for all replicas to be ready
ready_replicas=$(kubectl get statefulsets.apps hazelcast -o yaml|grep readyReplicas)
echo $ready_replicas
while [[ ! "$ready_replicas" == *"readyReplicas: $nodes"* ]]
do
  echo "$ready_replicas out of $nodes"
  sleep 1
  ready_replicas=$(kubectl get statefulsets.apps hazelcast -o yaml|grep readyReplicas)
done
echo "$ready_replicas out of $nodes"


for pod in $(kubectl get pods -o jsonpath="{.items[*].metadata.name}"); do \
  kubectl create service nodeport ${pod} --tcp=5701 -o yaml --dry-run=client | kubectl set selector --local -f - "statefulset.kubernetes.io/pod-name=${pod}" -o yaml | kubectl create -f -; \
done

echo --------------------
echo Information needed to connect from outside of the cluster
kubectl cluster-info|grep master
token_name=$(kubectl get secret -o name|grep hazelcast)
echo API Token:
kubectl get "$token_name" -o jsonpath={.data.token} | base64 --decode | xargs echo
echo Certificate:
kubectl get "$token_name" -o jsonpath='{.data.ca\.crt}' | base64 --decode
