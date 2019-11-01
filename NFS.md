# NFS



## 1安装

服务端和客户端

```
yum install -y nfs-utils
```

## 2配置

在服务端配置

```
[root@swarm packages]# cat /etc/exports
/root/scripts/uc/mysql/packages *(rw,sync,anonuid=0,anongid=0)
```

```
*表示可以被任意ip地址访问
rw表示允许读写，
sync表示同步方式，
```

## 3启动服务

服务端

```
systemctl restart rpcbind.service
systemctl restart nfs-server.service
```

客户端

```
systemctl start nfs-client.target
```

## 4检查

服务端检查服务

```
[root@swarm packages]# showmount -e 127.0.0.1
Export list for 127.0.0.1:
/root/scripts/uc/mysql/packages *
```

## 5挂载

客户端挂载

语法

```
mount -t nfs 【服务器端IP地址】:/data /data
```

例子

```
mount -t nfs 10.0.110.201:/root/scripts/uc/mysql/packages /root/scripts/uc/mysql/packages 
```

客户端取消挂载

语法

```
umount 指定目录
```

例子

```
[root@swarm ~]# umount /root/data/
[root@swarm ~]# ls data/
redis.conf  redis.yml  redis.yml.bak
```

6验证

客户端查看

```
[root@swarm packages]# mount
。。。。。。。。。。
。。。。。。。。。。
10.0.110.201:/root/scripts/uc/mysql/packages on /root/scripts/uc/mysql/packages type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.110.201,mountvers=3,mountport=20048,mountproto=tcp,local_lock=none,addr=10.0.110.201)
```

