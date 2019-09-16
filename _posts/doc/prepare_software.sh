#!/bin/bash -x
apt_update_log=apt_update.log
sudo apt update 2> $apt_update_log
if [ $? != 0 ]; then
    pub_key=$(grep NO_PUBKEY $apt_update_log | awk '{print $NF}')
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $pub_key
    sudo apt update
    if [ $? != 0 ]; then
        exit 1
    fi
fi

sudo apt -y install curl
if [ $? != 0 ]; then
    exit 1
fi

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
sudo sh -c "echo deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main > /etc/apt/sources.list.d/kubernetes.list"
sudo apt update
if [ $? != 0 ]; then
    exit 1
fi

sudo apt -y install git docker.io kubeadm kubectl kubelet
if [ $? != 0 ]; then
    exit 1
fi

sudo usermod -aG docker $(whoami)
sudo systemctl start docker kubelet
sudo systemctl enable docker kubelet
sudo service docker status | grep running
if [ $? != 0 ]; then
    echo "docker is not running"
    exit 1
fi


cat <<EOF > daemon.json
{
    "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]
}
EOF
sudo mv daemon.json /etc/docker/daemon.json

grep "raw.githubusercontent.com" /etc/hosts
if [ $? != 0 ]; then
    sudo sh -c "echo \"151.101.228.133 raw.githubusercontent.com\" >> /etc/hosts"
    grep "raw.githubusercontent.com" /etc/hosts
    if [ $? != 0 ]; then
        exit 1
    fi
fi

sudo sed -e 's/^dns=dnsmasq/#dns=dnsmasq/g' -i /etc/NetworkManager/NetworkManager.conf
sudo reboot
