# Git

## 第一章 入门

### 1.1 安装

win Mac 下载官网包点点点  

linux 

```
yum -y install git
```

## 第二章 版本控制

版本控制过程--git管理文件夹

1  进入文件夹

2  初始化（提名）

3  管理

4  生成版本

### 2.1 第一阶段 一条线开发

#### 命令实战

进入管理文件夹

初始化命令

```
git init
```

检测文件夹下所有文件状态

```
git status
```

管理指定文件

```
git add index.html
#index.html可以是任意文件或是文件夹
```

```
git add .          #添加所有文件
```

生成版本版本

```
git add 文件名
git add . 
```

生成版本

```
git commit -m "v1"
```

查看版本记录

```
git log

xxxxxxx
   v2
xxxxxxx
   v1
```



#### git三大区域

工作区

暂存区

版本控制



### 2.2 第二 阶段  新功能

```
git add
git commit -m "新功能"
```

### 2.3 第三阶段 回滚  约饭

#### 回滚语法

回滚之前的版本

```
git log
git reset --hard 版本号md5值
```

回滚之后的版本

```
git reflog
git reset --hard 版本号md5值
```

例子

修改文件后查看文件状态

```
git status
```

提交代码

```
git add .
```

生成版本

```
git commit -m "v2"
```

查看git版本

```
git log
```

xxxxx

v2

xxxxx

v1

如果觉得v2版本不适合想回滚到v1版本

#### 基本回滚语法

```
git reset --hard "版本号对应的md5值"
```

例子

查看所有版本

```
git log
```

commit 792085e5d3c686ce15745c1cf2041fa805507d13 (HEAD -> master, origin/master,
origin/HEAD)
Author: fengxiaolijing <18335300051@163.com>
Date:   Fri Nov 1 17:20:55 2019 +0800

nfs

commit ea01b787d79aa6536c6cf5aabfd0625df5775ae2
Author: fengxiaolijing <18335300051@163.com>
Date:   Fri Nov 1 17:19:53 2019 +0800

nfs

commit 53388b418cc4b898fad3cacec27e634aac646007
Author: fengxiaolijing <18335300051@163.com>
Date:   Thu Oct 31 11:11:47 2019 +0800

uc

#### 已经有一次回滚，想回到上一个版本

回退到 uc版本对应的md5值

```
git reset --hard "53388b418cc4b898fad3cacec27e634aac646007"
```

查看所有版本     #此场景用在最后一次提交了nfs版本回退到了uc版本然后用git log 是无法查看到上次提交的nfs版本的 所以需要用git reflog 查看版本

```
$ git reflog
792085e (HEAD -> master, origin/master, origin/HEAD) HEAD@{0}: commit: nfs
ea01b78 HEAD@{1}: commit: nfs
53388b4 HEAD@{2}: commit: uc
065552f HEAD@{3}: commit: uc-api
ad16ea8 HEAD@{4}: commit: 学习记录
4d70f57 HEAD@{5}: commit: uc
85cbfcd HEAD@{6}: commit: 测试mysql
e471a4a HEAD@{7}: commit: canal
d08b2bc HEAD@{8}: commit: 测试uc
d34eedf HEAD@{9}: clone: from git@github.com:fengxiaolijing/shell.git
```

回到到学习记录版本

```
git reset --hard ad16ea8
```

