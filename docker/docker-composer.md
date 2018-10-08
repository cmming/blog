## CentOS7下安装Docker-Compose

### 首先检查linux有没有安装python-pip包

    终端执行 pip -V

### 没有python-pip包就执行命令

     yum -y install epel-release
    
### 安装 python-pip

    yum -y install python-pip

### 升级 pip

    pip install --upgrade pip  (pip --default-timeout=200 install -U docker-compose)

### docker-compose (安装)

    pip install docker-compose

### 成功检测

    docker-compose -version