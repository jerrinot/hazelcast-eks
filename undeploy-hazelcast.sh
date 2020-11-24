#!/bin/sh

kubectl delete statefulsets.apps hazelcast
kubectl delete configmaps hazelcast-configuration
