#!/usr/bin/env bash

helm package ../terraform/k8s/manifests/helm-kustomize/confluent-platform

helm repo index . --url https://jrhoward.github.io/kube-bootstrap/helm-charts/