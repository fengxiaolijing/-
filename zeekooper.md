# zeekooper

简介：自我理解

文件性一致性数据库



环境

192.168.8.161

192.168.8.173

192.168.8.105

### 基础环境

每台机器添加

```
[root@master bin]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.8.161 Master
192.168.8.173 Slave1
192.168.8.105 Slave2
```



### 搭建zk集群

三台机器全部要做

下载zk包及解压包

```
tar xf zookeeper-3.4.9.tar.gz
```

配置文件在conf目录里

```
cd /root/zookeeper-3.4.9/conf
cp zoo_sample.cfg zoo.cfg
```

在第12行修改

```
dataDir=/root/zookeeper-3.4.9/data
dataLogDir=/root/zookeeper-3.4.9/logs
```

创建存储目录及日子目录

```
cd /root/zookeeper-3.4.9
[root@localhost zookeeper-3.4.9]# mkdir data
[root@localhost zookeeper-3.4.9]# mkdir log
```

在不同的机器上配置不同的id   和下面的配置文件中的server.1 等等 对应

```
[root@master zookeeper-3.4.9]# cat data/myid 
1
[root@slave1 zookeeper-3.4.9]# cat data/myid 
2
[root@slave2 zookeeper-3.4.9]# cat data/myid 
3
```

配置文件总览 zoo.cfg

```
[root@localhost conf]# grep -v "#" zoo.cfg 
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/root/zookeeper-3.4.9/data
dataLogDir=/root/zookeeper-3.4.9/logs
clientPort=2181
server.1=192.168.8.161:2888:3888
server.2=192.168.8.173:2888:3888
server.3=192.168.8.105:2888:3888
```

开启zk服务  进入bin目录

```
[root@localhost bin]# ./zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /root/zookeeper-3.4.9/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
[root@localhost bin]# pwd
/root/zookeeper-3.4.9/bin

```

查看服务状态  follower为从节点   leader为主节点

```
[root@master bin]# ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /root/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: follower
[root@slave1 bin]#  ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /root/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: leader
[root@slave2 bin]#  ./zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /root/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: follower
```

### 验证集群

```
在任意节点连接集群
./zkCli.sh -server Master:2181,Slave1:2181,Slave2:2181


#######################
[root@slave2 bin]# ./zkCli.sh -server Master:2181,Slave1:2181,Slave2:2181
Connecting to Master:2181,Slave1:2181,Slave2:2181
2020-01-13 07:25:09,557 [myid:] - INFO  [main:Environment@100] - Client environment:zookeeper.version=3.4.9-1757313, built on 08/23/2016 06:50 GMT
2020-01-13 07:25:09,561 [myid:] - INFO  [main:Environment@100] - Client environment:host.name=Slave2
2020-01-13 07:25:09,562 [myid:] - INFO  [main:Environment@100] - Client environment:java.version=11-ea
2020-01-13 07:25:09,564 [myid:] - INFO  [main:Environment@100] - Client environment:java.vendor=Oracle Corporation
2020-01-13 07:25:09,564 [myid:] - INFO  [main:Environment@100] - Client environment:java.home=/usr/lib/jvm/java-11-openjdk-11.0.ea.28-7.el7.x86_64
2020-01-13 07:25:09,564 [myid:] - INFO  [main:Environment@100] - Client environment:java.class.path=/root/zookeeper-3.4.9/bin/../build/classes:/root/zookeeper-3.4.9/bin/../build/lib/*.jar:/root/zookeeper-3.4.9/bin/../lib/slf4j-log4j12-1.6.1.jar:/root/zookeeper-3.4.9/bin/../lib/slf4j-api-1.6.1.jar:/root/zookeeper-3.4.9/bin/../lib/netty-3.10.5.Final.jar:/root/zookeeper-3.4.9/bin/../lib/log4j-1.2.16.jar:/root/zookeeper-3.4.9/bin/../lib/jline-0.9.94.jar:/root/zookeeper-3.4.9/bin/../zookeeper-3.4.9.jar:/root/zookeeper-3.4.9/bin/../src/java/lib/*.jar:/root/zookeeper-3.4.9/bin/../conf:
2020-01-13 07:25:09,565 [myid:] - INFO  [main:Environment@100] - Client environment:java.library.path=/usr/java/packages/lib:/usr/lib64:/lib64:/lib:/usr/lib
2020-01-13 07:25:09,565 [myid:] - INFO  [main:Environment@100] - Client environment:java.io.tmpdir=/tmp
2020-01-13 07:25:09,565 [myid:] - INFO  [main:Environment@100] - Client environment:java.compiler=<NA>
2020-01-13 07:25:09,565 [myid:] - INFO  [main:Environment@100] - Client environment:os.name=Linux
2020-01-13 07:25:09,565 [myid:] - INFO  [main:Environment@100] - Client environment:os.arch=amd64
2020-01-13 07:25:09,566 [myid:] - INFO  [main:Environment@100] - Client environment:os.version=3.10.0-957.el7.x86_64
2020-01-13 07:25:09,566 [myid:] - INFO  [main:Environment@100] - Client environment:user.name=root
2020-01-13 07:25:09,567 [myid:] - INFO  [main:Environment@100] - Client environment:user.home=/root
2020-01-13 07:25:09,569 [myid:] - INFO  [main:Environment@100] - Client environment:user.dir=/root/zookeeper-3.4.9/bin
2020-01-13 07:25:09,575 [myid:] - INFO  [main:ZooKeeper@438] - Initiating client connection, connectString=Master:2181,Slave1:2181,Slave2:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@591f989e
Welcome to ZooKeeper!
2020-01-13 07:25:09,627 [myid:] - INFO  [main-SendThread(Slave2:2181):ClientCnxn$SendThread@1032] - Opening socket connection to server Slave2/192.168.8.105:2181. Will not attempt to authenticate using SASL (unknown error)
2020-01-13 07:25:09,647 [myid:] - INFO  [main-SendThread(Slave2:2181):ClientCnxn$SendThread@876] - Socket connection established to Slave2/192.168.8.105:2181, initiating session
JLine support is enabled
2020-01-13 07:25:09,711 [myid:] - INFO  [main-SendThread(Slave2:2181):ClientCnxn$SendThread@1299] - Session establishment complete on server Slave2/192.168.8.105:2181, sessionid = 0x36f9c0b96d70000, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: Master:2181,Slave1:2181,Slave2:2181(CONNECTED) 0] 
#################
```

连接客户端，在另外一个节点创建，查看客户端是否能查询到

在节点192.168.8.173上操作

在一个node上查看zook 是空的

```
[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 1] 
```

现在插入节点数据

```
[zk: localhost:2181(CONNECTED) 1] create /feng 666
Created /feng
```

在节点192.168.8.161上操作

查看是否查询到数据666 

```
[zk: localhost:2181(CONNECTED) 1] get /feng
666
cZxid = 0x100000004
ctime = Mon Jan 13 07:32:28 CST 2020
mZxid = 0x100000004
mtime = Mon Jan 13 07:32:28 CST 2020
pZxid = 0x100000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```

在集群连接里查看

```
连接集群
#####
./zkCli.sh -server Master:2181,Slave1:2181,Slave2:2181

#####
[zk: Master:2181,Slave1:2181,Slave2:2181(CONNECTED) 0] get /feng
666
cZxid = 0x100000004
ctime = Mon Jan 13 07:32:28 CST 2020
mZxid = 0x100000004
mtime = Mon Jan 13 07:32:28 CST 2020
pZxid = 0x100000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```

