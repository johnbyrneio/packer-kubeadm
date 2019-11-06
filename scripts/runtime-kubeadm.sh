#!/bin/bash -e

# This script is copied to the AMI by Packer and is intended to be run when an
# instance is lanched from the AMI. It will initialize the first master node of a new
# cluster.

K8S_VERSION=1.16.2

# Wait for cloud-init to finish running in case user-data is providing additional config
# NOTE: This is script will be run by cloud-init. This check is now disabled and will likely be removed.
# while [ ! -f /var/lib/cloud/instance/boot-finished ]
# do    
#     echo "Waiting for cloud-init to complete..."
#     sleep 5
# done

# Backup the log file if this is a re-run.
if [[ -e /tmp/kubeadm.log ]] ; then
    mv /tmp/kubeadm.log /tmp/kubeadm.log.bak
fi

# Configure Kubernetes Master Node
echo "Starting Kubernetes. This will take several minutes..."
sudo su -c "kubeadm init --kubernetes-version ${K8S_VERSION} \
             --pod-network-cidr=192.168.0.0/16 \
             --apiserver-cert-extra-sans 'kubernetes'" \
             >> /tmp/kubeadm.log

echo "Copying kubeconfig for Kubernetes admin user..."
mkdir -p /home/ubuntu/.kube                                                                                                                                                
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config                                                                                                            
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Install Calico
echo "Installing Calico..."
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml --kubeconfig /etc/kubernetes/admin.conf >> /tmp/kubeadm.log

# Install Kubernetes Dashboard
echo "Deploying Kubernetes Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml --kubeconfig /etc/kubernetes/admin.conf >> /tmp/kubeadm.log

# Expose the dashboard via NodePort but keep it secure
kubectl apply -f /opt/kubernetes-dashboard-public.yaml --kubeconfig /etc/kubernetes/admin.conf >> /tmp/kubeadm.log

echo ""
echo "Kubernetes started, but system pods are still initializing."
echo "Run 'kubectl get pods -n kube-system' to verify all pods are running."
echo "Run 'kubectl taint nodes --all node-role.kubernetes.io/master-' to use this as a single node cluster."
echo "Run 'k8s-dashboard' for Kubernetes Dashboard connection details"
echo ""