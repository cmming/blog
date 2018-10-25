## 网络规划(nginx apache php)


1. 创建网络
    ```shell
        docker network create --subnet=172.21.0.0/16 net4
    ```

2. 下载镜像
    docker pull php:7.1-fpm
    docker tag php:7.1-fpm php7.1

3. 创建 集群

    ```
        docker run -it -d --name php1 -v /home/soft/nx1/nginx.conf:/etc/nginx/nginx.conf -v /home/soft/nx1/www:/home/www --privileged --net=net3 --ip 172.20.0.2 nginx
    ```

    172.21.0.2:9000