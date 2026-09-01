#!/bin/bash
set -euxo pipefail

# --- common node preflight ---
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

apt-get update
apt-get install -y containerd awscli curl gpg apt-transport-https ca-certificates

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# --- control plane init ---
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

kubeadm init \
  --pod-network-cidr="${pod_network_cidr}" \
  --control-plane-endpoint="$PRIVATE_IP:6443"

export KUBECONFIG=/etc/kubernetes/admin.conf
mkdir -p /root/.kube
cp -f /etc/kubernetes/admin.conf /root/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Non-expiring bootstrap token: an ASG can replace worker instances at any
# point in the fleet's lifetime, long past the default 24h token TTL. This
# token only grants node-bootstrap RBAC (nothing admin-level); rotate it by
# re-running `kubeadm token create` and overwriting the SSM parameter below
# if it's ever compromised.
JOIN_CMD=$(kubeadm token create --ttl 0 --print-join-command)

aws ssm put-parameter \
  --region "${aws_region}" \
  --name "${ssm_join_command_param}" \
  --type SecureString \
  --value "$JOIN_CMD" \
  --overwrite

aws ssm put-parameter \
  --region "${aws_region}" \
  --name "${ssm_kubeconfig_param}" \
  --type SecureString \
  --value "$(base64 -w0 /etc/kubernetes/admin.conf)" \
  --overwrite
