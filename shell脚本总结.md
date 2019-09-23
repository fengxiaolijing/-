# shell脚本总结

## 三剑客

### （一）cut 列处理

#### 主要参数详解

字符列切割

-b ：以字节为单位进行分割。（用这个b参数有时候有字符集的问题，切割出来会是乱码）
-c ：以字符为单位进行分割。
-d ：自定义分隔符，默认为制表符。
-f  ：与-d一起使用，指定显示哪个区域。

#### 实例用法详解

用-c参数 切割指定的1到5列的字符

```
cut -c n-m 文件
```

实例

```
cut -c 1-5 /etc/passwd

xxxxx

xxxxx
```



用-d参数 自定义分隔符 定义以: 号为切割符号 -f 指定区域 1 这样会切出来第一块区域的字符

```
# cat /etc/passwd | cut -d : -f 1
sshd
tcpdump
th
sxit
work
zabbix
thh
```

用-f参数 指定切割的域  切出来 以分号为切割的第一列和第三列

```
# cat /etc/passwd | cut -d : -f 1,3
th:1000
sxit:1001
work:1002
zabbix:988
thh:0

```

### （二）awk  列处理 字符处理

基本用法     直接打印输出

awk的变量 在awk里面  输出的 第一行 文件系统 容量这一整行 （从文件系统到挂载点这期间都）是$0 文件系统是$1 容量是$2 每一行都是这样传的变量

```shell
[root@localhost ~]# df -lh
文件系统                 容量  已用  可用 已用% 挂载点
/dev/mapper/centos-root   17G  1.1G   16G    6% /
devtmpfs                 3.8G     0  3.8G    0% /dev
```



#### 主要参数详解



printf    输出的时候是以字符串形式输出的

```
[root@localhost ~]# printf '%s' $(cat /etc/passwd) 
root:x:0:0:root:/root:/bin/bashbin:x:1:1:bin:/bin:/sbin/nologindaemon:x:2:2:daemon:/sbin:/sbin/nologinadm:x:3:4:adm:/var/adm:/sbin/nologinlp:x:4:7:lp:/var/spool/lpd:/sbin/nologinsync:x:5:0:sync:/sbin:/bin/syncshutdown:x:6:0:shutdown:/sbin:/sbin/shutdownhalt:x:7:0:halt:/sbin:/sbin/haltmail:x:8:12:
```

printf输出要想有格式 需要加入s\t 有格式  \n换行 这样打印出来的文件就会有一定的格式

```
[root@localhost ~]# printf '%s\t %s\t \n' $(cat /etc/passwd)
root:x:0:0:root:/root:/bin/bash	 bin:x:1:1:bin:/bin:/sbin/nologin	 
daemon:x:2:2:daemon:/sbin:/sbin/nologin	 adm:x:3:4:adm:/var/adm:/sbin/nologin	 
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin	 sync:x:5:0:sync:/sbin:/bin/sync   


```

print 和printf区别在于 printf的时候需要加上\n 换行 如果不加的话就会把输出的列打乱，print语法不用加\n 

提取文件中的第2列和第3列   中间加上制表符 \t  



awk 的基本语法  中间条件需要加上引号，动作需要加上{}号

awk '条件1{动作} 条件2{动作2}....' 文件名

```
[root@localhost ~]# df -lh | awk '{print $2 "\t" $3}'
容量	已用
17G	1.1G
3.8G	0
3.9G	0
3.9G	12M
3.9G	0
1014M	146M
781M	0
[root@localhost ~]# df -lh | awk '{printf $2 "\t" $3}'
容量	已用17G	1.1G3.8G	03.9G	03.9G	12M3.9G	01014M	146M781M	0[root@
```



#### 实例用法详解

查看根分区下的硬盘使用百分比 输出后 不要看到%号

输出文件 ，过滤出centos的行，awk切割第5行，cut 以%为分割 切出第一列 

```shell
[root@localhost ~]# df -lh | grep centos | awk '{print $5}' | cut -d "%" -f 1 
6
```

或是 cut -c 取第一个字符

```
[root@localhost ~]# df -lh | grep centos | awk '{print $5}' | cut -c 1
6

```



中级用法 条件

主要参数详解

awk 保留字 

BEGIN 在程序一开始时，尚未读取任何数据之前执行，BEGIN后的动作只在程序开始时执行一次

BND 在程序处理完所有数据，即将结束时执行。END后动作只在程序结束时执行一次

```shell
BEGIN 在最开始打印 111 
[root@localhost ~]# df -lh | awk 'BEGIN{print 111} {print $1}'
111
文件系统
/dev/mapper/centos-root
devtmpfs
tmpfs
tmpfs
tmpfs
/dev/sda1
tmpfs

END 在最后打印111
[root@localhost ~]# df -lh | awk 'END{print 111} {print $1}'
文件系统
/dev/mapper/centos-root
devtmpfs
tmpfs
tmpfs
tmpfs
/dev/sda1
tmpfs
111

```

awk 条件判断

条件是文件中  第二列中大于等于4的 且 输出第一列  

```
[root@localhost ~]# cat 1.txt | grep -v 文件系统
/dev/mapper/centos-root   17  1.1G   16G    6% /
devtmpfs                 3.8     0  3.8G    0% /dev
tmpfs                    3.9     0  3.9G    0% /dev/shm
tmpfs                    3.9   12M  3.8G    1% /run
tmpfs                    3.9     0  3.9G    0% /sys/fs/cgroup
/dev/sda1               1014  146M  869M   15% /boot
tmpfs                    781     0  781M    0% /run/user/0
[root@localhost ~]# cat 1.txt | grep -v 文件系统 | awk '$2>=4 {print $1} '
/dev/mapper/centos-root
/dev/sda1
tmpfs
```



实例用法详解

awk '条件 {动作}' 文件

条件这个文件用包含sda1的列   且 打印出第3列           这里用的是正则匹配 

```
[root@localhost ~]# cat 1.txt 
文件系统                 容量  已用  可用 已用% 挂载点
/dev/mapper/centos-root   17  1.1G   16G    6% /
devtmpfs                 3.8     0  3.8G    0% /dev
tmpfs                    3.9     0  3.9G    0% /dev/shm
tmpfs                    3.9   12M  3.8G    1% /run
tmpfs                    3.9     0  3.9G    0% /sys/fs/cgroup
/dev/sda1               1014  146M  869M   15% /boot
tmpfs                    781     0  781M    0% /run/user/0
[root@localhost ~]# cat 1.txt | awk '$1 ~ /sda1/ {print $3}'
146M

```

条件这个文件不包含sda1的列   且 打印出第3列             用感叹号取反

```
[root@localhost ~]# cat 1.txt | awk '$1 !~ /sda1/ {print $3}'
已用
1.1G
0
0
12M
0
0
```

条件 这个文件中  有sda1   就打印出来 第3列  

```
[root@localhost ~]# cat 1.txt | awk '/sda1/ {print $3}'
xxx
xxx
xxx
```



awk 的内置变量

变量      作用

$0        代表awk读入整行数据 $0代表当前读入行的数据

$n         代表读入行的第n个字段

NF        当前行拥有字段（列）总数

NR        当前awk所处理的行  是总数据的第几行

FS          用户定义分隔符 awk默认分割是空格 ，如果想使用其他的就需要 分号指定



例子

$0         代表把文件里 带/M/的行都 打印出来   

```
[root@localhost ~]# cat 1.txt | awk '/M/ {print $0}'
tmpfs                    3.9   12M  3.8G    1% /run
/dev/sda1               1014  146M  869M   15% /boot
tmpfs                    781     0  781M    0% /run/user/0
```



FS     用户指定分隔符 BEGIN提前指定分隔符是 FS : 冒号 打印第一列

```
[root@localhost ~]# cat /etc/passwd | grep "/bin/bash" | awk 'BEGIN{FS=":"} {print $1}'
root
feng
```



判断两个字符串是否相等用 ==



再加上一层判断 判断UID 是1000的用户

FS     用户指定分隔符 BEGIN提前指定分隔符是 FS : 冒号 打印第一列 

```
[root@localhost ~]# cat /etc/passwd | grep "/bin/bash" | awk 'BEGIN{FS=":"} $3==1000 {print $1}'
feng
```

查看指定文件在第几行 指定文件总有几列  

NR 是打印出root在第几行 NF是打印出root所在的一共几列

```
[root@localhost ~]# cat /etc/passwd | grep "/bin/bash" | awk 'BEGIN{FS=":"} {print $1 "\t" NR "\t" NF}'
root	1	7
feng	2	7
[root@localhost ~]# cat /etc/passwd 
root:x:0:0:root:/root:/bin/bash
```



### （三）sed 字符处理

#### 主要参数详解

```
sed 选项 '动作' 文件
```

 选项

-n       一般sed 命令把所有数据输出，加入选项，只会把经过sed命令处理的行输出到屏幕

-e        允许对输入数据应用多条sed 命令编辑

-f          从sed脚本中读入sed操作

-r          在sed中支持扩展正则表达式

-i           用sed 修改直接输出

动作          

\           用来替换多行

a \          追加 在当前行后添加一行或多行    

c  \           行替换  用c后面的字符串替换源数据行 

i   \           插入 在当前行前插入一行或多行 

d              删除指定行

p              打印指定的行

#### 实例用法详解

指定文件 输出第2到6行

```
[root@localhost ~]# cat /etc/passwd | sed -n '2,6p'
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
```

指定文件 删除第2到6行           

```
[root@localhost ~]# cat /etc/passwd | sed '2,6d'
```

如果想直接修改文件加入  -i

```
[root@localhost ~]# cat /etc/passwd | sed -i '2,6d'
```

在文件里的第1行后 直接追加 1111

```
[root@localhost ~]# sed -i '1a 11111' /etc/passwd 
[root@localhost ~]# cat /etc/passwd 
root:x:0:0:root:/root:/bin/bash
11111
```

在文件里第1行前 追加666

```
[root@localhost ~]# sed '1i 11111' /etc/passwd 
11111
root:x:0:0:root:/root:/bin/bash
```

行的替换        第二行换成6666

```
[root@localhost ~]# cat /etc/passwd | sed '2c 6666'
root:x:0:0:root:/root:/bin/bash
6666
```

替换的时候有多个动作  -e 指定   同时删除2行 3行

```
[root@localhost ~]# cat /etc/passwd | sed -e '2d ; 3d'
root:x:0:0:root:/root:/bin/bash
daemon:x:2:2:daemon:/sbin:/sbin/nologin
```

全文替换     's/旧的内容/新的内容/g'  s前面不加行号就是全文替换

```
[root@localhost ~]# cat /etc/passwd | sed -e 's/root/cang/g'
cang:x:0:0:cang:/cang:/bin/bash
```

多条替换语句    root改为cang  1111改为6666  3行替换为88888

```
[root@localhost ~]# cat /etc/passwd | sed -e 's/root/cang/g 
s/1111/6666/g ; 3c 888888'
cang:x:0:0:cang:/cang:/bin/bash
66661
888888
```



### （四）sort 排序

#### 主要参数详解

sort 选项 文件名

-f    忽略大小写

-b    忽略每行前面的空白部分

-n     以数值型进行排序

-r      反向排序

-u      删除重复行 就是uniq命令

-t      指定分隔符

#### 实例用法详解

默认sort安装首字符排序一个文件 （安装每行的第一个字母）      正序

```
[root@localhost ~]# sort /etc/passwd
11111
adm:x:3:4:adm:/var/adm:/sbin/nologin
bin:x:1:1:bin:/bin:/sbin/nologin
chrony:x:998:996::/var/lib/chrony:/sbin/nologin
```

取这个文件排序的反结果            倒序

```
[root@localhost ~]# sort -r /etc/passwd
systemd-network:x:192:192:systemd Network Management:/:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

排序文件中的uid              -n 安装整数输出 -t 指定分割对象是 : 号 -k 是以第3列开始 以第3列结束排序

```
[root@localhost ~]# sort -n -t ":" -k 3,3 /etc/passwd
11111
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
```

### （五）uniq 取消重复行  和  sort -u 效果一样

```
uniq 选项  文件名
```

-i   忽略大小写

实例用法详解

```
[root@localhost ~]# cat /etc/passwd
11111
11111

[root@localhost ~]# uniq -u /etc/passwd
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin

#这里效果还是有区别的  sort -u 是把重复的排序但留下一行  uniq不保留只要重复的全部删掉
[root@localhost ~]# sort -u /etc/passwd
11111
adm:x:3:4:adm:/var/adm:/sbin/nologin
```

### （六）wc 统计

#### 主要参数详解

-l    统计行数         l

-w    统计单词数

-m   统计字符数

#### 实例用法详解

统计文件行数

```
[root@localhost ~]# wc -l /etc/passwd
21 /etc/passwd

```

统计单词数  和统计 字符数

```
[root@localhost ~]# wc -w /etc/passwd
29 /etc/passwd
[root@localhost ~]# wc -m /etc/passwd
869 /etc/passwd
```

