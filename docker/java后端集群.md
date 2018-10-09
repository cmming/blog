
### 网络关系

192.168.50.58:6001          192.168.50.58:6101
192.168.50.58:6002 ----->                       --------> 192.168.50.58:6301
192.168.50.58:6003          192.168.50.58:6102

## 打包部署后端项目

1. 进入后端项目，执行打包（修改配置文件，更改端口，打包三次生成三个JAR文件）

   ```shell
   mvn clean install -Dmaven.test.skip=true
   ```

2. 安装Java镜像

   ```shell
   docker pull java
   ```

3. 创建3节点Java容器

   ```shell
   #创建数据卷，上传JAR文件
   docker volume create j1
   #启动容器
   docker run -it -d --name j1 -v j1:/home/soft --net=host java
   #进入j1容器
   docker exec -it j1 bash
   #启动Java项目
   nohup java -jar /home/soft/renren-fast.jar

   #创建数据卷，上传JAR文件
   docker volume create j2
   #启动容器
   docker run -it -d --name j2 -v j2:/home/soft --net=host java
   #进入j1容器
   docker exec -it j2 bash
   #启动Java项目
   nohup java -jar /home/soft/renren-fast.jar

   #创建数据卷，上传JAR文件
   docker volume create j3
   #启动容器
   docker run -it -d --name j3 -v j3:/home/soft --net=host java
   #进入j1容器
   docker exec -it j3 bash
   #启动Java项目
   nohup java -jar /home/soft/renren-fast.jar
   ```
4. 安装Nginx镜像

 ```shell
   #启动第fn1节点
   docker run -it -d --name n1 -v /home/soft/n1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/n1/keepalived:/etc/keepalived --net=host --privileged nginx
   #进入n1节点
   docker exec -it n1 bash
   #更新软件包
   apt-get update
   #安装VIM
   apt-get install vim
   #安装Keepalived
   apt-get install keepalived
   #编辑Keepalived配置文件(如下)
   vim /etc/keepalived/keepalived.conf
   #启动Keepalived
   service keepalived start


    #启动第fn2节点
   docker run -it -d --name n2 -v /home/soft/n2/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/n2/keepalived:/etc/keepalived --net=host --privileged nginx
   #进入n1节点
   docker exec -it n2 bash
   #更新软件包
   apt-get update
   #安装VIM
   apt-get install vim
   #安装Keepalived
   apt-get install keepalived
   #编辑Keepalived配置文件(如下)
   vim /etc/keepalived/keepalived.conf
   #启动Keepalived
   service keepalived start


```