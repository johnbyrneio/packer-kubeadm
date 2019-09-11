# packer-kubeadm

Thia Packer template `kubeadm.json` builds an Amazon AMI with kubeadm and it's prerequisites installed.
Includes Docker, kubelet, and kubeadm.

| image          | k8s-version | docker-version | os-version   |
|----------------|-------------|----------------|--------------|
| kubeadm-1.15.3 | 1.15.3      | 18.06.2        | Ubuntu 18.04 |

All templates use the latest available official Ubuntu 18.04 AMI as their base.
