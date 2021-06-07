#!/usr/bin/env bash
set -e
kubectl --kubeconfig=/etc/kubernetes/admin.conf drain --force=true --ignore-daemonsets=true --delete-local-data "$HOSTNAME"
