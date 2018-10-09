## 采用技术 mysql haproxy keepalive

    最终效果：对外程序是由3306 接口连接数据集群，集群采用 haproxy进行负载均衡，同时使用keepalive对负载均衡进行双机热备，避免机器挂掉

    端口预先分配：mysql->
                        172.18.0.2:3306->3307
                        172.18.0.3:3306->3308
                        172.18.0.4:3306->3309
                        172.18.0.5:3306->3310 
                        172.18.0.6:3306->3311
                                                ------>>>>>
                                                            haproxy->
                                                                    172.18.0.7:8888->4001
                                                                    172.18.0.7:3306->4002     keepalive                              keepalive                   
                                                                                            ------>> 争抢虚拟ip 172.18.0.201:3306   --------->public ip 3306
                                                                    172.18.0.8:8888->4003                       172.18.0.201:8888  ---------->public ip 8888
                                                                    172.18.0.8:3306->4004



### 1.网络创建  net1

    docker network create --subnet=172.18.0.0/16 net1

### 2.数据卷创建

     ```
   docker volume create --name v1
   docker volume create --name v2
   docker volume create --name v3
   docker volume create --name v4
   docker volume create --name v5
   ```

### 3.创建备份数据卷（用于热备份数据）

   ```shell
   docker volume create --name backup
   ```

### 4.创建5节点的PXC集群

   注意，每个MySQL容器创建之后，因为要执行PXC的初始化和加入集群等工作，耐心等待1分钟左右再用客户端连接MySQL。另外，必须第1个MySQL节点启动成功，用MySQL客户端能连接上之后，再去创建其他MySQL节点。

   ```shell
   #创建第1个MySQL节点
   docker run -d -p 3307:3306 -e MYSQL_ROOT_PASSWORD=abc123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=abc123456 -v v1:/var/lib/mysql -v backup:/data --privileged --name=node1 --net=net1 --ip 172.18.0.2 pxc
   #创建第2个MySQL节点
   docker run -d -p 3308:3306 -e MYSQL_ROOT_PASSWORD=abc123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=abc123456 -e CLUSTER_JOIN=node1 -v v2:/var/lib/mysql -v backup:/data --privileged --name=node2 --net=net1 --ip 172.18.0.3 pxc
   #创建第3个MySQL节点
   docker run -d -p 3309:3306 -e MYSQL_ROOT_PASSWORD=abc123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=abc123456 -e CLUSTER_JOIN=node1 -v v3:/var/lib/mysql --privileged --name=node3 --net=net1 --ip 172.18.0.4 pxc
   #创建第4个MySQL节点
   docker run -d -p 3310:3306 -e MYSQL_ROOT_PASSWORD=abc123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=abc123456 -e CLUSTER_JOIN=node1 -v v4:/var/lib/mysql --privileged --name=node4 --net=net1 --ip 172.18.0.5 pxc
   #创建第5个MySQL节点
   docker run -d -p 3311:3306 -e MYSQL_ROOT_PASSWORD=abc123456 -e CLUSTER_NAME=PXC -e XTRABACKUP_PASSWORD=abc123456 -e CLUSTER_JOIN=node1 -v v5:/var/lib/mysql -v backup:/data --privileged --name=node5 --net=net1 --ip 172.18.0.6 pxc
```


```
    上面的端口也可以不用进行映射，如果外网没有访问需求，就可以不用映射，避免端口不够用
```



### 5.安装Haproxy镜像

   ```shell
   docker pull haproxy
   
   ```

### 6.宿主机上编写Haproxy配置文件

    ```shell
   vi /home/soft/h1/haproxy/haproxy.cfg
   vi /home/soft/h2/haproxy/haproxy.cfg
   ```
    #配置文件
    ```
        global
        #工作目录
        chroot /usr/local/etc/haproxy
        #日志文件，使用rsyslog服务中local5日志设备（/var/log/local5），等级info
        log 127.0.0.1 local5 info
        #守护进程运行
        daemon

    defaults
        log	global
        mode	http
        #日志格式
        option	httplog
        #日志中不记录负载均衡的心跳检测记录
        option	dontlognull
        #连接超时（毫秒）
        timeout connect 5000
        #客户端超时（毫秒）
        timeout client  50000
        #服务器超时（毫秒）
        timeout server  50000

    #监控界面	
    listen  admin_stats
        #监控界面的访问的IP和端口
        bind  0.0.0.0:8888
        #访问协议
        mode        http
        #URI相对地址
        stats uri   /dbs
        #统计报告格式
        stats realm     Global\ statistics
        #登陆帐户信息
        stats auth  admin:abc123456
    #数据库负载均衡
    listen  proxy-mysql
        #访问的IP和端口
        bind  0.0.0.0:3306  
        #网络协议
        mode  tcp
        #负载均衡算法（轮询算法）
        #轮询算法：roundrobin
        #权重算法：static-rr
        #最少连接算法：leastconn
        #请求源IP算法：source 
        balance  roundrobin
        #日志格式
        option  tcplog
        #在MySQL中创建一个没有权限的haproxy用户，密码为空。Haproxy使用这个账户对MySQL数据库心跳检测 create user 'haproxy'@'%'  identified by '';
        option  mysql-check user haproxy
        server  MySQL_1 172.18.0.2:3306 check weight 1 maxconn 2000  
        server  MySQL_2 172.18.0.3:3306 check weight 1 maxconn 2000  
        server  MySQL_3 172.18.0.4:3306 check weight 1 maxconn 2000 
        server  MySQL_4 172.18.0.5:3306 check weight 1 maxconn 2000
        server  MySQL_5 172.18.0.6:3306 check weight 1 maxconn 2000
        #使用keepalive检测死链
        option  tcpka 

    ```




### 7.创建两个Haproxy容器

    先将两个配置文件上传到 指定文件夹 /home/soft/haproxy 
   ```shell
   #创建第1个Haproxy负载均衡服务器
   docker run -it -d -p 4001:8888 -p 4002:3306 -v /home/soft/h1/haproxy:/usr/local/etc/haproxy -v /home/soft/h1/keepalived:/etc/keepalived --name h1 --privileged --net=net1 --ip 172.18.0.7 haproxy
   #进入h1容器，启动Haproxy
   docker exec -it h1 bash
   haproxy -f /usr/local/etc/haproxy/haproxy.cfg
   #更新软件包
   apt-get update
   #安装Keepalived
   apt-get install keepalived
   #编辑Keepalived配置文件 (可以采用提前配置)
   vim /etc/keepalived/keepalived.conf
   #启动Keepalived
   service keepalived start
   ## 宿主机执行ping命令 
   ping 172.18.0.201
   #创建第2个Haproxy负载均衡服务器
   docker run -it -d -p 4003:8888 -p 4004:3306 -v /home/soft/h2/haproxy:/usr/local/etc/haproxy -v /home/soft/h2/keepalived:/etc/keepalived --name h2 --privileged --net=net1 --ip 172.18.0.8 haproxy
   #进入h2容器，启动Haproxy
   docker exec -it h2 bash
   haproxy -f /usr/local/etc/haproxy/haproxy.cfg
   #更新软件包
   apt-get update
   #安装Keepalived
   apt-get install keepalived
   #编辑Keepalived配置文件 (可以采用提前配置)
   vim /etc/keepalived/keepalived.conf
   #启动Keepalived
   service keepalived start
   # 关闭 h1    docker pause h1
   ## 宿主机执行ping命令 
   ping 172.18.0.201
   ```

    配置文件内容如下：

    ```shell
    vrrp_instance  VI_1 {
        state  MASTER
        interface  eth0
        virtual_router_id  51
        priority  100
        advert_int  1
        authentication {
            auth_type  PASS
            auth_pass  123456
        }
        virtual_ipaddress {
            172.18.0.201
        }
    }
    ```



### 8.宿主机安装Keepalived，实现双击热备

    ```shell
    #宿主机执行安装Keepalived
    yum -y install keepalived
    #修改Keepalived配置文件
    vi /etc/keepalived/keepalived.conf
    #启动Keepalived
    service keepalived start
    ```

    Keepalived配置文件如下：

    ```shell
    vrrp_instance VI_1 {
        state MASTER
        interface ens33 (使用ip addr 看)
        virtual_router_id 51
        priority 100
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
           	192.168.99.150
        }
    }

    virtual_server 192.168.99.150 8888 {
        delay_loop 3
        lb_algo rr
        lb_kind NAT
        persistence_timeout 50
        protocol TCP

        real_server 172.18.0.201 8888 {
            weight 1
        }
    }

    virtual_server 192.168.99.150 3306 {
        delay_loop 3
        lb_algo rr
        lb_kind NAT
        persistence_timeout 50
        protocol TCP

        real_server 172.18.0.201 3306 {
            weight 1
        }
    }
    ```

### 9. 防火墙打开

    # 所有的端口使用情况
    netstat -ntlp
    ```
    #注意开启 keepalived 时候双机热备的对外暴漏端口写入防火墙，否则外网访问不到，但是docker 的端口代理会自动穿透防火墙（原因未知）
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
     firewall-cmd --zone=public --add-port=8888/tcp --permanent
     firewall-cmd --reload
     # 查看所有打开的端口
     firewall-cmd --zone=public --list-ports
    ```

    ```
    –add-service #添加的服务
    –zone #作用域
    –add-port=80/tcp #添加端口，格式为：端口/通讯协议
    –permanent #永久生效，没有此参数重启后失效
    ```


### 10.最终效果

    使用 3306 可以 连接数据库
    使用 8888 可以看集群状态



### 11. 热备份数据

    ```shell
    #进入node1容器
    docker exec -it node1 bash
    #更新软件包
    apt-get update
    #安装热备工具
    apt-get install percona-xtrabackup-24
    #全量热备
    innobackupex --user=root --password=abc123456 /data/backup/full
    ```

### 12. 冷还原数据
    停止其余4个节点，并删除节点

    ```shell
    docker stop node2
    docker stop node3
    docker stop node4
    docker stop node5
    docker rm node2
    docker rm node3
    docker rm node4
    docker rm node5
    ```

    node1容器中删除MySQL的数据

    ```shell
    #删除数据
    rm -rf /var/lib/mysql/*
    #清空事务
    innobackupex --user=root --password=abc123456 --apply-back /data/backup/full/2018-04-15_05-09-07/
    #还原数据
    innobackupex --user=root --password=abc123456 --copy-back  /data/backup/full/2018-04-15_05-09-07/
    ```

    重新创建其余4个节点，组件PXC集群



    

