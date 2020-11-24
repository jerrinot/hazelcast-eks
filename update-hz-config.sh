#!/bin/sh
#kubectl create configmap hazelcast-configuration --from-file hazelcast-config.yaml -o yaml --dry-run=client|kubectl replace -f -

DIR="$(cd "$(dirname "$0")" && pwd)"
$DIR/undeploy-hazelcast.sh
$DIR/deploy-hazelcast.sh
