## 安装Redis，配置RedisCluster集群


    数据预先分析

    集群采用3个节点组成，每个节点都有一个备份节点

1. 安装Redis镜像

   ```shell
   docker pull yyyyttttwwww/redis
   docker tag yyyyttttwwww/redis redis
   ```

2. 创建net2网段

   ```shell
   docker network create --subnet=172.19.0.0/16 net2
   ```
 

3. 创建6节点Redis容器

   ```shell
   docker run -it -d -v /home/soft/redis/redis.conf:/usr/redis/redis.conf --name r1 --privileged -p 5001:6379 --net=net2 --ip 172.19.0.2 redis bash
   docker run -it -d -v /home/soft/redis/redis.conf:/usr/redis/redis.conf --name r2 --privileged -p 5002:6379 --net=net2 --ip 172.19.0.3 redis bash
   docker run -it -d -v /home/soft/redis/redis.conf:/usr/redis/redis.conf --name r3 --privileged -p 5003:6379 --net=net2 --ip 172.19.0.4 redis bash
   docker run -it -d -v /home/soft/redis/redis.conf:/usr/redis/redis.conf --name r4 --privileged -p 5004:6379 --net=net2 --ip 172.19.0.5 redis bash
   docker run -it -d -v /home/soft/redis/redis.conf:/usr/redis/redis.conf --name r5 --privileged -p 5005:6379 --net=net2 --ip 172.19.0.6 redis bash
   docker run -it -d -v /home/soft/redis/redis.conf:/usr/redis/redis.conf --name r6 --privileged -p 5006:6379 --net=net2 --ip 172.19.0.7 redis bash
   ```

4. 启动6节点Redis服务器

   ```shell
   #进入r1节点
   docker exec -it r1 bash
   cd /usr/redis/src
   ./redis-server ../redis.conf
   exit
   #进入r2节点
   docker exec -it r2 bash
   
   cd /usr/redis/src
   ./redis-server ../redis.conf
   exit
   #进入r3节点
   docker exec -it r3 bash
   
   cd /usr/redis/src
   ./redis-server ../redis.conf
   exit
    #进入r4节点
    docker exec -it r4 bash
    
    cd /usr/redis/src
    ./redis-server ../redis.conf
    exit
    #进入r5节点
    docker exec -it r5 bash
    
    cd /usr/redis/src
    ./redis-server ../redis.conf
    exit
    #进入r6节点
    docker exec -it r6 bash
    
    cd /usr/redis/src
    ./redis-server ../redis.conf
    exit
    ```

5. 创建Cluster集群

   ```shell
   #在r1节点上执行下面的指令
   docker exec -it r1 bash
   cd /usr/redis/src
   mkdir -p ../cluster
   cp redis-trib.rb ../cluster/
   cd ../cluster
   #创建Cluster集群
   ./redis-trib.rb create --replicas 1 172.19.0.2:6379 172.19.0.3:6379 172.19.0.4:6379 172.19.0.5:6379 172.19.0.6:6379 172.19.0.7:6379
   ```

6.程序连接
    public ip +5001 到5006