# Elasticsearch集群

### 环境Centos7

ip地址

192.168.8.161

192.168.8.173

192.168.8.105

### 下载es

```
cd /home/es/
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.0-linux-x86_64.tar.gz
```

解压

```
tar xf elasticsearch-7.2.0-linux-x86_64.tar.gz
cd elasticsearch-7.2.0/config/
mkdir date
```

下载node

```
wget https://nodejs.org/dist/v12.14.1/node-v12.14.1-linux-x64.tar.xz
```

下载head管理es

```
git clone https://github.com/mobz/elasticsearch-head.git
```

### 基础环境

#### 创建普通账户及授权

```
adduser es
passwd es
chown -R es:es /home/es/elasticsearch-7.2.0/
```

#### 系统参数配置

vim /etc/security/limits.conf

```
es soft nofile 65536
es hard nofile 65536
es soft nproc 4096
es hard nproc 4096
```

vim /etc/security/limits.d/20-nproc.conf

```
es          soft    nproc     4096
root       soft    nproc     unlimited
```

/etc/sysctl.conf

```
vm.max_map_count = 655360
```

生成系统配置

```
sysctl -p
```



### es配置文件及启动

控制使用内存  （每个主机配置相同）

/home/es/elasticsearch-7.2.0/config/jvm.options

```
 22 -Xms512m
 23 -Xmx512m
```

node1配置文件   （每个主机配置基本相同，pid_node_主机号不同）

```
#用管理head的时候会涉及跨域访问
http.cors.enabled: true
http.cors.allow-origin: "*"
cluster.name: pid #集群名称
node.name: pid_node_1 #节点名称  这里每个节点不一样 
#数据和日志的存储目录
path.data: /home/es/elasticsearch-7.2.0/data
path.logs: /home/es/elasticsearch-7.2.0/logs
##设置绑定的ip，设置为0.0.0.0以后就可以让任何计算机节点访问到了
network.host: 0.0.0.0
#服务端口号
http.port: 9200 #端口
#集群间通信端口号
transport.tcp.port: 9300
#设置集群自动发现机器IP地址集合
discovery.zen.ping.unicast.hosts: ["192.168.8.161:9300","192.168.8.173:9300","192.168.8.105:9300"]
```

进入es目录启动  加-d是后台启动

```
sh /home/es/elasticsearch-7.2.0/bin/elasticsearch -d
```

### es管理插件head

解压

```
tar xf node-v12.14.1-linux-x64.tar.xz
cd node-v12.14.1-linux-x64/
```

配置node环境变量

/etc/profile

```
export NODE_HOME=/root/node-v12.14.1-linux-x64
export PATH=$NODE_HOME/bin:$PATH
```

生产变量

```
 source /etc/profile
```

查看变量

```
node -v
```

安装head插件及启动head

```
cd elasticsearch-head/
npm install
npm install -g grunt-cli
npm install -g cnpm --registry=https://registry.npm.taobao.org
 grunt server
```

启动后页面访问ip:9100

在页面点击Elasticsearch 旁边的链接 输入node1的IP地址 完成后点击连接，会出现三个node

