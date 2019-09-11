#!/bin/bash -e

# This installs/configures Docker to be used by Kubernetes.
# It closely follows the official kubeadm docs.
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

DOCKER_VERSION="18.06.2~ce~3-0~ubuntu"

# Update Ubuntu
echo "Running apt update/upgrade..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install Docker
echo "Installing Docker..."

apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update && apt-get install -y docker-ce="${DOCKER_VERSION}"

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker

apt-mark hold docker.io

# Set sysctl for iptbales stuff
echo "Setting sysctl settings..."
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p

# Cleanup
echo "Cleaning up apt data..."
apt autoremove --purge