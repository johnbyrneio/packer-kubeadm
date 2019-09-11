#!/bin/bash -e

# This script is copied to the AMI by Packer. It is intended to be run by the user to retrieve
# Kubernetes dashboard connection/login information.

EXTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
NODE_PORT=$(kubectl get svc kubernetes-dashboard-public -n kube-system -o jsonpath={.spec.ports[0].nodePort})
SECRET_NAME=$(kubectl get sa -n kube-system dashboard-admin -o jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl get secret -n kube-system ${SECRET_NAME} -o jsonpath='{.data.token}' | base64 --decode)

echo ""
echo "Dashboard URL: https://${EXTERNAL_IP}:${NODE_PORT}"
echo ""
echo "Dashboard Token:"
echo "----------------"
echo ""
echo "${TOKEN}"
echo ""
