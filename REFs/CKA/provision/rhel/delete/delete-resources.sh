#!/usr/bin/env bash
# Run once at any control node

# Delete plugins
kubectl delete -f https://docs.projectcalico.org/manifests/calico.yaml

# Delete all K8s resources
kubectl delete deploy --all
kubectl delete rs --all
kubectl delete sts --all
kubectl delete pvc --all
kubectl delete pv --all
kubectl delete configmaps --all
kubectl delete services --all
kubectl delete ingresses --all
kubectl delete ns --all
kubectl delete secrets --all
kubectl delete roles --all
kubectl delete rolebindings --all
kubectl delete crd --all

