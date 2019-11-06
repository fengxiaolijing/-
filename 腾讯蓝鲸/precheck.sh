#!/usr/bin/env bash

export LC_ALL=C LANG=C
SELF_PATH=$(readlink -f $0)
SELF_DIR=$(dirname $(readlink -f $0))
PKG_SRC_PATH=${SELF_DIR%/*}/src

check_yum_repo () {
   yum info nginx rabbitmq-server &>/dev/null
}

check_rabbitmq_version () {
   local mq_ver=$(yum list rabbitmq-server | grep -Eo '3\.[0-9]+\.[0-9]+')
   if [[ -n "$mq_ver" ]]; then
      return 0
   else
      echo "rabbitmq-server version below 3.0"
      return 1
   fi
}

generate_ip_array () {
   local ip_lines=$(awk '{ split($2,module,","); for (i=1; i<=length(module); i++) { print $1,module[i] } }' ${SELF_DIR}/install.config)
   printf "export ALL_IP=(%s)\n" "$(awk '{print $1}' <<<"$ip_lines" | sort -u | xargs)"
   while read m; do
      awk -v module=$m 'BEGIN { printf "export %s_IP=(", toupper(module) }
      $2 == module { printf "%s ", $1}
      END { printf ")\n" } ' <<<"$ip_lines"
   done < <(awk '{print $2}' <<<"$ip_lines" | sort -u)
}

is_centos_7 () {
   which systemctl &>/dev/null
}

check_ssh_nopass () {
   for ip in ${ALL_IP[@]}; do
      echo -ne "$ip\t"
      ssh -o 'PreferredAuthentications=publickey' -o 'StrictHostKeyChecking=no' $ip "true" 2>/dev/null
      if [[ $? -eq 0 ]]; then
          echo "publickey Auth OK"
      else
          echo "publickey Auth FAILED, please configure no-pass login first."
          return 1
      fi
   done
   return 0
}

check_pip_config () {
   local url=$(awk '/^index-url/ { print $NF }'  ${PKG_SRC_PATH}/.pip/pip.conf)
   local code=$(curl -L -s -o /dev/null -w "%{http_code}" "$url")
   if [[ "$code" -eq 200 ]]; then 
       echo "pip config OK"
   else
       echo "check pip mirror in src/.pip/pip.conf "
       return 1
   fi
}

check_systemd_service () {
   local svc=$1
   if systemctl is-active --quiet $svc ; then
      echo "$svc is running, you should shutdown firewalld"
      return 1
   else
      return 0
   fi
}

check_firewalld () {
   check_systemd_service "firewalld"
}

check_networkmanager () {
   check_systemd_service "NetworkManager"
}

check_selinux () {
   if [[ -x /usr/sbin/sestatus ]]; then
      if ! [[ $(/usr/sbin/sestatus -v | awk '/SELinux status/ { print $NF }') = "disabled" ]]; then
	 return 1
      fi
   fi
   return 0
}

check_umask () {
   if ! [[ $(umask) = "0022" ]]; then
      echo "umask shouled be 0022, now is <$(umask)>."
      return 1
   fi
}

check_open_files_limit () {
    if [[ $(ulimit -n) = "1024" ]];then
      echo "ulimit open files (-n)  should not be default 1024"
      echo "increase it up to 102400 or more for all BK hosts"
      return 1
    fi
}

check_get_lan_ip () {
   local ip=$(ip addr | \
      awk -F'[ /]+' '/inet/{
   split($3, N, ".")
   if ($3 ~ /^192.168/) {
      print $3
   }
   if (($3 ~ /^172/) && (N[2] >= 16) && (N[2] <= 31)) {
      print $3
   }
   if ($3 ~ /^10\./) {
      print $3
   }
}')
[[ -n "$ip" ]]
}

check_password () {
   local INVALID=""
   source $SELF_DIR/globals.env 
   for v in MYSQL_PASS REDIS_PASS MQ_PASS ZK_PASS PAAS_ADMIN_PASS ZABBIX_ADMIN_PASS
   do
      eval pass=\$$v
      if [[ "$pass" =~ (\^|\?|%|&|\\|\/|\`|\!) ]]; then
          INVALID="$INVALID $v"
      fi
   done
   if echo "$INVALID" |grep -q "[A-Z]" 2>/dev/null; then
      echo "check $INVALID Variables in ${SELF_DIR}/globals.env"
      return 1
   else
      return 0
   fi

}

get_license_mac () {
   for ip in ${LICENSE_IP[@]}; do
      ssh $ip 'cat /sys/class/net/*/address'
   done
}

check_cert_mac () {
   if [[ ! -f ${PKG_SRC_PATH}/cert/gse_server.crt ]]; then
      echo "cert not exists"
      return 1
   fi
   local detail=$(openssl x509 -noout -text -in ${PKG_SRC_PATH}/cert/gse_server.crt 2>/dev/null)

   local cnt=$(grep -cFf <(get_license_mac) <(awk '/email/ { for(i=1;i<=NF;i++) print substr($i, 7, 17) }' <<<"$detail"))
   [[ $cnt -eq ${#LICENSE_IP[@]} ]]
}
check_http_proxy () {
   if [[ -n "$http_proxy" ]]; then
       echo "http_proxy variable is not empty."
       echo "you should use BK_PROXY in globals.env for http proxy when install blueking."
       return 1
   fi
}

check_domain () {
    local err_domain=""
    local err_fqdn=""
    source ${SELF_DIR}/globals.env

    # BK_DOMAIN 不能是顶级域名，没有\.字符时
    if ! [[ $BK_DOMAIN =~ \. ]]; then
        echo "globals.env中BK_DOMAIN不应该是顶级域名，请配置二级域名或者以上"
        return 1
    fi

    # FQDN等包含合法字符
    for d in BK_DOMAIN PAAS_FQDN JOB_FQDN CMDB_FQDN; do
        if ! [[ $(eval echo "\$$d") =~  ^[A-Za-z0-9.-]+\.[a-z]+$ ]]; then
            err_domain="$err_domain $d"
        fi
    done

    # FQDN 必须基于BK_DOMAIN
    for d in PAAS_FQDN JOB_FQDN CMDB_FQDN; do
        if ! [[ $(eval echo "\$$d") =~ $BK_DOMAIN$ ]]; then
            err_fqdn="$err_fqdn $d" 
        fi
    done

    if [[ -z "$err_domain" && -z "$err_fqdn" ]]; then
        return 0
    else
        [[ -n "$err_domain" ]] && echo "globals.env中以下域名包含非法字符：$err_domain"
        [[ -n "$err_fqdn" ]] && echo "globasl.env中以下FQDN没有以BK_DOMAIN结尾：$err_fqdn"
        return 1
    fi
}

check_rsync () {
    if ! which rsync 2>/dev/null; then
        echo "please install <rsync> on all servers"
        echo "with `yum -y install rsync` command"
        return 1
    fi
    return 0
}

do_check() {
   local item=$1
   local step_file=$HOME/.bk_precheck

   if grep -qw "$item" $step_file; then
        echo "<<$item>> has been checked successfully... SKIP"
   else
        echo -n "start <<$item>> ... "
        message=$($item)
        if [ $? -eq 0 ]; then
            echo "[OK]"
            echo "$item" >> $step_file
        else
            echo "[FAILED]"
            echo -e "\t$message"
            exit 1
        fi
   fi
}

if [[ -z $BK_PRECHECK ]]; then
    BK_PRECHECK="check_ssh_nopass check_password check_cert_mac
     check_umask check_get_lan_ip check_rabbitmq_version
    check_http_proxy check_open_files_limit check_domain check_rsync"
fi

#if [[ -z "$BK_OPTIONAL_CHECK" ]]; then
#    BK_OPTIONAL_CHECK="check_networkmanager check_firewalld"
#fi

STEP_FILE=$HOME/.bk_precheck

# 根据参数设置标记文件
if [ "$1" = "-r" -o "$1" = "--rerun" ]; then
    > "$STEP_FILE"
else
   [ -e "$STEP_FILE" ] || touch $STEP_FILE 
fi

eval "$(generate_ip_array)"
for item in $BK_PRECHECK
do
   do_check $item
done

if is_centos_7 ; then
   for c in $BK_OPTIONAL_CHECK
   do
      do_check $c
   done
fi
