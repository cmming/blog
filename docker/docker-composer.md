## CentOS7下安装Docker-Compose

### 首先检查linux有没有安装python-pip包

    终端执行 pip -V

### 没有python-pip包就执行命令

     yum -y install epel-release
    
### 安装 python-pip

    yum -y install python-pip

### 升级 pip

    sudo pip install --upgrade pip  (pip --default-timeout=200 install -U docker-compose)
    sudo pip install --upgrade pip

### docker-compose (安装)

    sudo pip install docker-compose

### 成功检测

    docker-compose -version


### 因为这里卷的创建依赖卷插件local-persist 所以要保证之前创建的容器volume-plugin-local-persist在运行中
docker run -d --restart always --name volume-plugin-local-persist -v /run/docker/plugins/:/run/docker/plugins/   cwspear/docker-local-persist-volume-plugin
