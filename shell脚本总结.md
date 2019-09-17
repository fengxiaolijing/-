# shell脚本总结

## 三剑客

##### （一）cut 列处理

字符切割 用法   

主要参数
-b ：以字节为单位进行分割。（用这个b参数有时候有字符集的问题，切割出来会是乱码）
-c ：以字符为单位进行分割。
-d ：自定义分隔符，默认为制表符。
-f  ：与-d一起使用，指定显示哪个区域。



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

