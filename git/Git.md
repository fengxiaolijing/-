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

### 2.4 阶段总结

```
git init #初始化
git add   #添加代码
git log  #查看版本
git reflog #查看回退之前版本
git reset --hard 版本号

```

切换三大区域代码  工作区  暂存区  版本区

#### git 工作区域的回退   

##### 例子1

查看现在代码库的状态，目前的状态是没有文件需要更新

```
Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git status
On branch master
nothing to commit, working tree clean
```

新增加一个文件，再次检查git status发现变红色

```
Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        test.txt

nothing added to commit but untracked files present (use "git add" to track)
```

这时想回到之前那个时候，不想要新建的文件了

```
Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git checkout
```

再查看文件夹下面的所有文件，新建的文件没有了，文件变成绿色的了

```
Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:  
        modified:   "\346\226\260\345\273\272\346\226\207\346\234\254\346\226\207\346\241\243.txt"
```

##### 例子2

查看一个文件的状态是绿色的，修改文件，文件内容666，后变成红色，用git checkout --"文件名" 回退后发现文件内容666 没有了，文件状态是依然是绿色的。

```

Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   test.txt
        modified:   "\346\226\260\345\273\272\346\226\207\346\234\254\346\226\207\346\241\243.txt"

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   test.txt


Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git checkout -- test.txt

$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   test.txt
        modified:   "\346\226\260\345\273\272\346\226\207\346\234\254\346\226\207\346\241\243.txt"
```

#### git 暂存区回退到工作区

##### 例子1

写完代码添加到工作区，查看状态时绿色的状态，git reset HEAD -- "文件名" 将暂存区的代码回退到工作区，查看代码状态是红色的

```
Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git add .

Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   test.txt
        new file:   "\345\244\264\345\203\217.jpg"
        modified:   "\346\226\260\345\273\272\346\226\207\346\234\254\346\226\207\346\241\243.txt"


Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)

Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git reset HEAD -- 头像.jpg

Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   test.txt
        modified:   "\346\226\260\345\273\272\346\226\207\346\234\254\346\226\207\346\241\243.txt"

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        "\345\244\264\345\203\217.jpg"


Administrator@PC-201907020238 MINGW64 ~/Desktop/新建文件夹 (master)
$ git checkout
A       test.txt
M       "\346\226\260\345\273\272\346\226\207\346\234\254\346\226\207\346\241\243.txt"
```



学到 第9章

https://www.bilibili.com/video/av70229191/?p=9