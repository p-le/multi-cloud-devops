#!/usr/bin/env bash
set -e
kubectl --kubeconfig=/etc/kubernetes/admin.conf drain --force --ignore-daemonsets --delete-local-data "$HOSTNAME"
