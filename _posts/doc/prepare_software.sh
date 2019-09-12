#!/bin/bash -x
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
sudo sh -c "echo deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list"
sudo apt update

sudo apt -y install docker.io kubeadm kubectl kubelet
sudo usermod -aG docker $(whoami)
sudo systemctl start docker kubelet
sudo systemctl enable docker kubelet

cat <<EOF > daemon.json
{
    "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"],
    "insecure-registries":["192.168.146.61:5000"]
}
EOF
sudo mv daemon.json /etc/docker/daemon.json

sudo sed -e 's/^dns=dnsmasq/#dns=dnsmasq/g' -i /etc/NetworkManager/NetworkManager.conf
sudo reboot
