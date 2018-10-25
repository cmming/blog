
1. 创建网络

```shell
   docker network create --subnet=172.20.0.0/16 net3
```

2. 下载镜像

    ```shell
   docker pull nginx
   ```

3. 创建数据卷

      ```
   docker volume create --name nx1
   docker volume create --name nx2
   docker volume create --name nx3
   docker volume create --name nx4
   docker volume create --name nx5
   ```
    
4. 创建 集群

    ```
        docker run -it -d --name nx1 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.2 nginx
        docker run -it -d --name nx2 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.3 nginx
        docker run -it -d --name nx3 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.4 nginx
        docker run -it -d --name nx4 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.5 nginx
        docker run -it -d --name nx5 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.6 nginx
    ```

5. 对nginx 负载均衡

    ```
        docker run -it -d --name nxk1 -v /home/soft/nxk/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nxk/keepalived:/etc/keepalived --privileged --net=net3 --ip 172.20.0.7 nginx
        docker run -it -d --name nxk2 -v /home/soft/nxk/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nxk/keepalived:/etc/keepalived --privileged --net=net3 --ip 172.20.0.8 nginx

    ```

6. 将负载均衡进行双击热备

    docker exec -it nxk1 bash
    apt-get update
    apt-get install keepalived -y
    service keepalived start

    docker exec -it nxk2 bash

7. 在宿主机中添加keepalived配置

    ```
        virtual_server 192.168.50.58 80 {


            delay_loop 3
            lb_algo rr 
            lb_kind NAT
            persistence_timeout 50
            protocol TCP

            real_server 172.20.0.201 80 {
                weight 1
            }
        }

    ```


8. 开启防火墙

    ```
    #将80添加防火墙
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    #重新加载网络配置
    firewall-cmd --reload
    #看已经开启的端口
    firewall-cmd --zone=public --list-ports
    ```




