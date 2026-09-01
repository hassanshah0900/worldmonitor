#!/bin/bash
set -euxo pipefail

# --- common node preflight (identical to control-plane's) ---
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
apt-get install -y kubelet kubeadm
apt-mark hold kubelet kubeadm

# --- join the cluster ---
# The control plane may still be running its own user-data (installing
# packages, running kubeadm init) when this instance boots, so the SSM
# parameter might not exist yet. Poll instead of failing fast.
JOIN_CMD=""
for i in $(seq 1 60); do
  JOIN_CMD=$(aws ssm get-parameter \
    --region "${aws_region}" \
    --name "${ssm_join_command_param}" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text 2>/dev/null || true)
  [ -n "$JOIN_CMD" ] && [ "$JOIN_CMD" != "None" ] && break
  sleep 10
done

if [ -z "$JOIN_CMD" ] || [ "$JOIN_CMD" == "None" ]; then
  echo "Timed out waiting for join command in SSM parameter ${ssm_join_command_param}" >&2
  exit 1
fi

eval "$JOIN_CMD"
