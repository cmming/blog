
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
        docker run -it -d -p 8080:80 --name nx1 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.2 nginx
        docker run -it -d -p 8081:80 --name nx2 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.3 nginx
        docker run -it -d -p 8082:80 --name nx3 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.4 nginx
        docker run -it -d -p 8083:80 --name nx4 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.5 nginx
        docker run -it -d -p 8084:80 --name nx5 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.6 nginx
    ```

5. 对nginx 负载均衡

    ```
        docker run -it -d -p 8085:80 --name nxk1 -v /home/soft/nxk/nginx.conf:/etc/nginx/nginx.conf --privileged --net=net3 --ip 172.20.0.7 nginx
        docker run -it -d -p 8086:80 --name nxk2 -v /home/soft/nxk/nginx.conf:/etc/nginx/nginx.conf --privileged --net=net3 --ip 172.20.0.8 nginx

    ```

6. 将负载均衡进行双击热备

    docker exec -it nxk1 bash
    apt-get update
    apt-get install keepalived -y

    docker exec -it nxk2 bash