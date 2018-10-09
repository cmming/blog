1. 断电重启
     
     cd /
    find .  -name 'grastate.dat'

    vi  path

    修改safe_to_bootstrap 值 当前文件为0 改为1
    
    结构如下:

    # GALERA saved state
    version: 2.1
    uuid:    002bd039-c2c8-11e7-82c7-36d79987c3c9
    seqno:   -1
    safe_to_bootstrap: 1
