## 如何扩容

    1.15.5

## 个人使用时 nginx:latest 
    出现bug 的时候 可以以尝试指定nginx 版本号进行使用
    nginx:latest ->nginx:1.15.5

    docker-compose up --scale nginx=6 -d