#!/bin/bash

HOSTNAME=$(hostname)

#####################
#check configuration
#####################

cat /etc/resolv.conf | grep 127
if [ $? == 0 ]; then
    echo "/etc/resolv.conf has lo, this maybe cause coreDNS cannot start"
    exit 1
fi

sudo service docker status | grep running
if [ $? != 0 ]; then
    echo "docker is not running"
    exit 1
fi

#enter installation dir
kube_install_dir="install/"
if [ ! -d $kube_install_dir ]; then
    mkdir -p $kube_install_dir
fi

cd $kube_install_dir


#################
#k8s
#################
#由于google镜像源被墙，使用国内docker镜像源替代
genDockerDownloaderFile() {
downloader_file=$1
docker_images=$2

cat << EOF > $downloader_file
#!/bin/bash
images=(
EOF

cat << EOF >> $downloader_file
$docker_images
EOF

cat << "EOF" >> $downloader_file
)

for imageName in ${images[@]} ; do
  if [[ $imageName == k8s.gcr.io/* ]]; then
    proxy_images=${imageName/k8s.gcr.io/gcr.azk8s.cn\/google_containers}
  elif [[ $imageName == quay.io/* ]]; then
    proxy_images=${imageName/quay.io/quay.azk8s.cn}
  else
    continue
  fi

  docker pull $proxy_images
  docker tag  $proxy_images $imageName
  docker rmi  $proxy_images
done
EOF
}

images_dir="images"
if [ ! -d $images_dir ]; then
    mkdir -p $images_dir
fi

node_status=$(kubectl get node | grep $HOSTNAME | awk '{print $2}')
if [ $? != 'Ready' ]; then
    #安装master节点
    kube_dockers_path="$images_dir/kube_dockers.sh"
    
    kube_depend_images=$(kubeadm config images list)
    genDockerDownloaderFile "$kube_dockers_path" "$kube_depend_images"
    
    chmod +x $kube_dockers_path
    ./$kube_dockers_path
    if [ $? != 0 ]; then
        echo "exec $kube_dockers_path failed!"
        exit 1
    fi
    
    
    # 关闭swap
    sudo swapoff -a
    sudo sed 's/\(^[^#].*swap.*$\)/#\1/' -i /etc/fstab
    
    current_ip=$(hostname -I | awk '{print $1}')
    sudo kubeadm init --apiserver-advertise-address=$current_ip --pod-network-cidr=10.244.0.0/16
    
    kube_config_dir=".kube"
    if [ ! -d  $kube_config_dir ]; then
        mkdir -p ~/$kube_config_dir
    fi
    sudo cp -i /etc/kubernetes/admin.conf ~/$kube_config_dir/config
    
    user=$(whoami)
    sudo chown $user:$user ~/$kube_config_dir/config
fi


#####################
#网络插件flannel
#####################
flannel_yaml=kube-flannel.yml
flannel_images_script="$images_dir/flannel_images.sh"

if [ ! -f $flannel_yaml ]; then
    wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/$flannel_yaml
    if [ $? != 0 ]; then
        echo "wget $flannel_yaml failed!"
        exit 1
    fi
fi

#下载镜像，不使用该方法，直接替换源
#flannel_images=$(cat $flannel_yaml | grep 'image' | grep 'arm64' | awk '{print $2}')
#genDockerDownloaderFile "$flannel_images_script" "$flannel_images"
#if [ $? != 0 ]; then
#    exit 1
#fi
#chmod +x $flannel_images_script
#./$flannel_images_script

sed -e 's/quay.io/quay.azk8s.cn/g' -i $flannel_yaml
kubectl apply -f $flannel_yaml
if [ $? != 0 ]; then
    echo "apply $flannel_yaml failed!"
    exit 1
fi




######################
#HPA插件metrics-server
######################

metrics_dir=metrics-server
metrics_deploy_path=metrics-server/deploy/1.8+

#重置metrics-server
if [ -d $metrics_dir ]; then
    kubectl delete -f $metrics_deploy_path
    cd $metrics_dir
    git reset --hard
    git pull
    cd -
else
    git clone https://github.com/kubernetes-incubator/$metrics_dir.git
    if [ $? != 0 ]; then
        echo "git clone $metrics_dir.git failed!"
        exit 1
    fi
fi

#安装metrics-server
metrics_server_yaml=$metrics_deploy_path/metrics-server-deployment.yaml

grep "nodeSelector:" $metrics_server_yaml
if [[ $? != 0 ]]; then
    sed -i "/^    spec:/a\      nodeSelector:\n\
        kubernetes.io/hostname: $HOSTNAME\n\
      tolerations:\n\
      - key: node-role.kubernetes.io/master\n\
        operator: Equal\n\
        value: ''\n\
        effect: NoSchedule" $metrics_server_yaml
fi

grep "kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP" $metrics_server_yaml
if [[ $? != 0 ]]; then
    sed -i '/^      - name: metrics-server/a\
        args:\
        - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP\
        - --kubelet-insecure-tls' $metrics_server_yaml
fi

sed -i 's/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/g' $metrics_server_yaml
sed -i 's/k8s.gcr.io/gcr.azk8s.cn\/google_containers/g' $metrics_server_yaml
kubectl apply -f $metrics_deploy_path
if [ $? != 0 ]; then
    echo "apply $metrics_deploy_path failed"
    exit 1
fi

##################
#界面组件dashboard
##################

dashboardVer=v1.10.1
dashboard_dir=dashboard
dashboard_yaml=kubernetes-dashboard.yaml

# 重置
if [ -d $dashboard_dir ]; then
    kubectl delete -f $dashboard_dir
else
    mkdir $dashboard_dir
fi

cd $dashboard_dir

# 安装dashboard
if [ ! -f $dashboard_yaml ]; then
    wget https://raw.githubusercontent.com/kubernetes/dashboard/$dashboardVer/src/deploy/recommended/$dashboard_yaml -O $dashboard_yaml
    if [ $? != 0 ]; then
        echo "wget $dashboard_yaml failed"
        exit 1
    fi
fi

sed -i 's/k8s.gcr.io/gcr.azk8s.cn\/google_containers/g' $dashboard_yaml
kubectl apply -f $dashboard_yaml
if [ $? != 0 ]; then
    echo "apply $dashboard_yaml failed"
    exit 1
fi

admin_role_yaml=admin-role.yaml
# 增加admin
cat << EOF > $admin_role_yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
EOF

kubectl apply -f $admin_role_yaml
if [ $? != 0 ]; then
    echo "apply $admin_role_yaml failed!"
    exit 1
fi

cd ..

##########################
#反向代理组件ingress-nginx
##########################

ingress_dir=ingress
if [ ! -d $ingress_dir ]; then
    mkdir -p $ingress_dir
fi
cd $ingress_dir

ingress_nginx_dir=ingress-nginx
ingress_nginx_yaml=deploy/static/mandatory.yaml

#重置
if [ ! -d $ingress_nginx_dir ]; then
    git clone https://github.com/kubernetes/$ingress_nginx_dir.git
    if [ $? != 0 ]; then
        echo "git clone $ingress_nginx_dir.git failed!"
        exit 1
    fi
    cd $ingress_nginx_dir
else
    cd $ingress_nginx_dir
    kubectl delete -f $ingress_nginx_yaml
    git reset --hard
    git pull
fi

#修改配置
grep "nodeSelector:" $ingress_nginx_yaml
if [[ $? != 0 ]]; then
    sed -i "/^    spec:/a\      nodeSelector:\n\
        kubernetes.io/hostname: $HOSTNAME\n\
      tolerations:\n\
      - key: node-role.kubernetes.io/master\n\
        operator: Equal\n\
        value: ''\n\
        effect: NoSchedule\n\
      hostNetwork: true" $ingress_nginx_yaml
fi

sed -e 's/quay.io/quay.azk8s.cn/g' -i $ingress_nginx_yaml

kubectl apply -f $ingress_nginx_yaml
if [ $? != 0 ]; then
    echo "apply $ingress_nginx_yaml failed!"
    exit 1
fi

cd ../..



cd ..
