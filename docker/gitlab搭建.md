
## 确保机器上安装了docker并启动
    # 安装docker
    yum install docker
    # 启动docker
    systemctl start docker

## 拉取镜像并启动
    # 拉取镜像
    docker pull gitlab/gitlab-ce
    # 启动
    docker run --detach \
    --publish 22443:443 --publish 80:80  --publish 2222:22 \
    --name gitlab \
    --memory 4g \
    --restart always \
    --volume /home/soft/gitlab/config:/etc/gitlab \
    --volume /home/soft/gitlab/logs:/var/log/gitlab \
    --volume /home/soft/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

    --publish 暴露了容器的三个端口, 分别是https对应的443, http对应80以及ssh对应的22(如果不需要配置https, 可以不暴露)
    --memory 限制容器最大内存暂用4G, 这是官方推荐的
    --volume 指定挂载目录, 这个便于我们在本地备份和修改容器的相关数据



## 修改配置文件并重启

    # 打开挂载的配置目录
    vi /home/soft/gitlab/config/gitlab.rb

    ###################################################
    # 添加外部请求的域名(如果不支持https, 可以改成http)
    external_url 'https://gitlab.yinnote.com'
    # 修改gitlab对应的时区 
    gitlab_rails['time_zone'] = 'PRC'
    # 开启邮件支持 
    gitlab_rails['gitlab_email_enabled'] = true
    gitlab_rails['gitlab_email_from'] = '13037125104@163.com'
    gitlab_rails['gitlab_email_display_name'] = 'chmi gitlab'
    # 配置邮件参数
    gitlab_rails['smtp_enable'] = true
    gitlab_rails['smtp_address'] = "smtp.163.com"
    gitlab_rails['smtp_port'] = 465
    gitlab_rails['smtp_user_name'] = "13037125104@163.com"
    gitlab_rails['smtp_password'] = "193427a"
    gitlab_rails['smtp_domain'] = "smtp.163.com"
    gitlab_rails['smtp_authentication'] = "login"
    gitlab_rails['smtp_enable_starttls_auto'] = true
    gitlab_rails['smtp_tls'] = false        
    ###################################################


    #下面以网易163邮箱为例配置邮箱:  vi /home/soft/gitlab/config/gitlab.rb   external_url（只能是域名或者ip 不能有端口）
    gitlab_rails['smtp_enable'] = true
    gitlab_rails['smtp_address'] = "smtp.163.com"
    gitlab_rails['smtp_port'] = 25
    gitlab_rails['smtp_user_name'] = "xxxx@163.com"
    gitlab_rails['smtp_password'] = "xxxxpassword"
    gitlab_rails['smtp_domain'] = "163.com"
    gitlab_rails['smtp_authentication'] = "login"
    gitlab_rails['smtp_enable_starttls_auto'] = false
    gitlab_rails['smtp_openssl_verify_mode'] = "peer"

    gitlab_rails['gitlab_email_from'] = "xxxx@163.com"
    user["git_user_email"] = "xxxx@163.com"

    external_url "http://192.168.50.58"

(选配) 如果配置了https, 需要导入证书

    # 进入挂载配置目录
    cd /srv/gitlab/config
    # 创建密钥文件夹, 并放入证书
    mkdir ssl
    # 内容如下

##重启服务

    # 方法一: 重启容器(其中xxxxxx是容器id)
    docker restart xxxxxx

    # 方法二: 登陆容器, 重启配置
    docker exec -it  xxxxxx bash   
    gitlab-ctl reconfigure

    gitlab-ctl restart


## 参考
    https://www.cnblogs.com/int32bit/p/5310382.html
    https://www.jianshu.com/p/786c0a7a49d4

