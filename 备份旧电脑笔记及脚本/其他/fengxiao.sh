#!/bin/bash
#name   fengxiao
#update 19年2月2号15点41分

#定义判断变量
y=Y
n=N

#输出提示语句
echo -e "\033[1;31m ==>正在更改Ansible.yml文件 ==< \033[0m"  
echo -e "\033[1;32m ==>输出后请输出Y或N进行确认和否定操作 ==< \033[0m"  

#输出更改项目
read -p '请输出目标主机名:' hosts
#遍历ansible.hosts文件里的主机名是否与当前主机名冲突
if [   ]
then
  unset hosts
  echo -e "\033[1;31m 目标主机名当前已经使用请更换主机名! \033[0m"
else
  echo -e "\033[1;38m 主机名可以正常使用 \033[0m"
fi
#判断是否确定使用当前主机名
read -p "确定主机名为$hosts吗？请做出判断，摁Y或是N " x
if [ "$x" != "$y"  ]
then
 unset hosts
else
 echo "目标主机名改为$hosts"
 unset x
fi
