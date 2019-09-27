```python
# 生成nginx配置文件
import sys
import os

example_file = """
upstream {poolName} {{
ip_hash;
server 10.0.110.201:{servicePort};
server 10.0.110.202:{servicePort};   
}}

server {{
listen 80;
server_name {serverName};

location / {{
  proxy_pass http://{poolName};
  proxy_set_header HOST $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_connect_timeout 300;
  proxy_send_timeout 300;
  proxy_read_timeout 300;
}}
}}
"""


def create():
    
    if len(sys.argv) < 4:
        print("""
        --usage: python createConfig.py poolname serviceport servername
        --example: python createConfig.py mypool 18080 www.baidu.com
        """)
        sys.exit(1)
    poolname, serviceport, servername = sys.argv[1], sys.argv[2], sys.argv[3]
    tempfile = poolname + ".conf"
    filepath = "/opt/nginx/appconf/"
    try:
        with open(filepath + tempfile, "w") as f:
            f.write(str(example_file).format(poolName=poolname, servicePort=serviceport, serverName=servername))
            if os.path.isfile(filepath + tempfile):
                os.system("echo conf file is ok") # instead of nginx -s reload
                print(os.strerror(0))
            else:
                print("nginx config file is get error")
    except KeyError:
        print("pls check keys from example file")
    except IOError:
        print(os.strerror(2))

# run function
create()


```









# nginx前端页面加速

## 安装 

```
# 下载nginx
wget http://nginx.org/download/nginx-1.14.2.tar.gz
# 解压nginx
tar xf nginx-1.14.2.tar.gz -C /opt/
# 安装依赖
yum install gcc-c++ pcre-devel zlib-devel make unzip libuuid-devel -y
# 下载pagespeed模块
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v1.13.35.2-stable.zip
# 解压
unzip v1.13.35.2-stable.zip
# 进入解压目录
cd incubator-pagespeed-ngx-1.13.35.2-stable/
# 下载优化库
wget https://dl.google.com/dl/page-speed/psol/1.13.35.2-x64.tar.gz
# 解压优化库
tar xf 1.13.35.2-x64.tar.gz
# 进入nginx编译目录
/opt/nginx-1.14.2
# 编译nginx 指定安装目录  指定优化加速模块位置 安装 编译
./configure --prefix=/opt/nginx --add-module=/opt/nginxspeed/incubator-pagespeed-ngx-1.13.35.2-stable && make && make install
# 查看编译后的nginx是否有安装成功nginx加速模块
/opt/nginx/sbin/nginx -V
nginx version: nginx/1.14.2
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC) 
configure arguments: --prefix=/opt/nginx --add-module=/opt/nginxspeed/incubator-pagespeed-ngx-1.13.35.2-stable
```

## 配置 

```
# 配置 nginx.conf 文件
####nginx.conf####

worker_processes  2;

events {
    worker_connections  2024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
# 优化nginx
open_file_cache max=204800 inactive=20s;
open_file_cache_min_uses 1;
open_file_cache_valid 30s;
tcp_nodelay on;
gzip on;
gzip_min_length 1k;
gzip_buffers 4 16k;
gzip_http_version 1.0;
gzip_comp_level 2;
gzip_types text/plain application/x-javascript text/css application/xml;
gzip_vary on;

# 启用ngx_pagespeed 前端加速模块
pagespeed on;
pagespeed FileCachePath /var/ngx_pagespeed_cache;
# 启用CoreFilters
pagespeed RewriteLevel CoreFilters;
# 禁用CoreFilters中的某些过滤器
pagespeed DisableFilters rewrite_images;
# 选择性地启用额外的过滤器
pagespeed EnableFilters local_storage_cache;
pagespeed EnableFilters collapse_whitespace,remove_comments;
pagespeed EnableFilters outline_css;
pagespeed EnableFilters flatten_css_imports;
pagespeed EnableFilters move_css_above_scripts;
pagespeed EnableFilters move_css_to_head;
pagespeed EnableFilters outline_javascript;
pagespeed EnableFilters combine_javascript;
pagespeed EnableFilters combine_css;
pagespeed EnableFilters rewrite_javascript;
pagespeed EnableFilters rewrite_css,sprite_images;
pagespeed EnableFilters rewrite_style_attributes;
pagespeed EnableFilters recompress_images;
pagespeed EnableFilters resize_images;
pagespeed EnableFilters convert_meta_tags;
  
    sendfile        on;
    keepalive_timeout  65;
    
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
    include /opt/nginx/appconf/*.conf;
}
```

检查配置文件 重启nginx

```
[root@swarm conf]# /opt/nginx/sbin/nginx -t
nginx: the configuration file /opt/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /opt/nginx/conf/nginx.conf test is successful
[root@swarm conf]# /opt/nginx/sbin/nginx -s reload
```

