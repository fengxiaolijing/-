#!/bin/bash
#
source /etc/profile

case $deploy_args in
    deploy)
	echo "==>执行部署任务-${BUILD_DISPLAY_NAME}==<"
 
    cd ${WORKSPACE}/ && rm -rf web_prod && cp -r web web_prod  
    cp /home/scripts/10kaoqingwebtest/http_prod.js  ${WORKSPACE}/web_prod/src/js/http.js
    #传正式的配置文件
    cd ${WORKSPACE}/web_prod/ && cnpm rebuild node-sass && \
						cnpm install && npm run build && \
						echo "nodejs前段正式hrca代码打包成功" || echo "nodejs前端正式hrca代码打包失败 "

    echo "==>正在复制/web_prod/static至/web_prod/dist"
    cp -rf ${WORKSPACE}/web_prod/static ${WORKSPACE}/web_prod/dist
    echo "==>正在打包dist"
    cd ${WORKSPACE}/web_prod/
    tar zcf web_prod.tar dist/
    mv web_prod.tar ${WORKSPACE}

    cp /home/scripts/10kaoqingwebtest/http.js  ${WORKSPACE}/web/src/js/http.js
    cd ${WORKSPACE}/web/ && cnpm rebuild node-sass && \
							cnpm install && npm run build  && \
   							echo "nodejs前段正式hrca代码打包成功" || echo "nodejs前端测试hrca代码打包失败 "
   #传测试的配置文件
    echo "==>正在复制/web/static至/web/dist"
    cp -rf ${WORKSPACE}/web/static ${WORKSPACE}/web/dist/
    echo "==>正在打包dist"    
    cd ${WORKSPACE}/web/
    tar zcf web.tar dist/
    mv web.tar ${WORKSPACE}
    
    cd ${WORKSPACE}
    tar zcf reports-web.tar reports-web/
    tar zcf kqcalender-web.tar kqcalender-web/
    tar zcf h5kq-web.tar h5kq-web/

function bulidrun(){

    #projectPath=(
    #"${WORKSPACE}/platform"
    #"${WORKSPACE}/report"
    #"${WORKSPACE}/server"
    #"${WORKSPACE}/mobilecard")

    #warPackage=(
    #"platform/target/platform-0.0.1-SNAPSHOT.war" 
    #"report/target/report-0.0.1-SNAPSHOT.war" 
    #"server/target/taiheattendance-0.0.1-SNAPSHOT.war" 
    #"mobilecard/target/mobilecard-0.0.1-SNAPSHOT.war")

    #tarPackage=(
    #"web.tar" 
    #"reports-web.tar" 
    #"kqcalender-web.tar" 
    #"h5kq-web.tar")

    #ansibleHost="10.0.102.191:/deploy/10kaoqingwebtest/new_deploy/"
    
    #for i in ${projectPath[@]};do
    #   cd $i
    #   mvn clean compile package -Dmaven.test.skip=true && echo "war项目打包成功" || echo "war项目打包失败"
    #done

    #for i in ${warPackage[@]};do
    #   scp ${WORKSPACE}/$i $ansibleHost
    #done

    #for i in ${tarPackage[@]};do
    #   scp ${WORKSPACE}/$i $ansibleHost
    #done
#########################
projectPath=(
    "${WORKSPACE}/platform"
    "${WORKSPACE}/report"
    "${WORKSPACE}/server"
    "${WORKSPACE}/mobilecard")

    warPackage=(
    "platform/target/platform-0.0.1-SNAPSHOT.war"
    "report/target/report-0.0.1-SNAPSHOT.war"
    "server/target/taiheattendance-0.0.1-SNAPSHOT.war"
    "mobilecard/target/mobilecard-0.0.1-SNAPSHOT.war")

    tarPackage=(
    "web.tar"
    "reports-web.tar"
    "kqcalender-web.tar"
    "h5kq-web.tar")

    ansibleHost="10.0.102.191:/deploy/10kaoqingwebtest/new_deploy/"
    num = 1
    for i in ${projectPath[@]};do
       cd $i
       mvn clean compile package -Dmaven.test.skip=true && echo "war项目打包成功" || echo "war项目打包失败"
       scp ${WORKSPACE}/$warPackage[2,3] $ansibleHost 
       scp ${WORKSPACE}/$tarPackage[$num] $ansibleHost
       num += 1
    done


############################
    if [ $? -eq 0 ];then
      echo "==>传包任务成功..."
    else
      echo "==>传包任务失败..."
    fi    
}
bulidrun


    ssh 10.0.102.191 /deploy/10kaoqingwebtest/deploy_kaoqingweb_test.sh
    ;;
    rollback)
    src_file1_path=/var/lib/jenkins/jobs/10kaoqingwebtest/builds/${version}/archive/
    dst_file1_path=/var/lib/jenkins/workspace/10kaoqingwebtest/  #此处有问题
	
	#删除目录中存在的war包
	echo "删除历史数据..."
	rm -rf ${dst_file1_path}*
A
	echo "==>执行恢复任务-版本号-${version}==<"
	echo "正在恢复数据...$(ls ${src_file1_path}*.war)到${dst_file1_path}"
	
	#恢复文件
	cp -rf $(ls ${src_file1_path}*) ${dst_file1_path} 
    scp ${dst_file1_path}/mobilecard-0.0.1-SNAPSHOT.war root@10.0.102.191:/deploy/10kaoqingwebtest/new_deploy/
    scp ${dst_file1_path}/h5kq-web.tar root@10.0.102.191:/deploy/10kaoqingwebtest/new_deploy/

	if [ $? -eq 0 ];then
		echo "恢复成功..."
		echo "执行推送任务..."
	    ssh 10.0.102.191 /deploy/10kaoqingwebtest/deploy_kaoqingweb_test.sh
		sleep 3
		if [ $? -eq 0 ];then
			echo "部署推送成功..." 
		else
			echo "部署推送失败..."
		fi

	else
		echo "恢复失败..."
	fi
	;;
	*)
	exit;;
esac
