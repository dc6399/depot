#!/bin/bash

#選單
#TODO git 還原&更新RP 須解決遠程限制問題
echo -e "\033[44;37m 输入 1 到 4 之间的数字:\033[0m"

echo '1. 1RP解壓回復設定'
echo '2. FE RP 設定檢查'
echo '3. APP RP 設定檢查'
echo '4. BE RP 設定檢查'
echo '5. PAY RP 設定檢查'
echo '你输入的数字为:'
stty erase '^H'
read aNum

case $aNum in
1)
	echo '你选择了 1'

	read -p "輸入[r]eturn、[n]ew :" action
	if [ $action == "return" ] || [ $action == "r" ]; then
		action="return"
	elif [ $action == "new" ] || [ $action == "n" ]; then
		action="new"
	else
		echo "請輸入正確模式！"
		exit 1
	fi

	# 安裝套件
	yum install iftop tcpdump lrzsz iotop httpd-tools sshpass -y
	sleep 3s

	if [ ! -d /home/backup_tmp ]; then
		mkdir -p /home/backup_tmp
	else
		rm -f /home/backup_tmp/*
	fi
	echo -e "\033[44;37m 抓取1RP備份檔案\033[0m"

	echo 抓取1RP備份檔案
	read -p "輸入[b]backend、[f]frontend、[a]app、[p]pay   :" services
	if [ $services == "backend" ] || [ $services == "b" ]; then
		services="backend"
	elif [ $services == "frontend" ] || [ $services == "f" ]; then
		services="fend"
	elif [ $services == "app" ] || [ $services == "a" ]; then
		services="app"
	elif [ $services == "pay" ] || [ $services == "p" ]; then
		services="pay"
	else
		echo "請輸入正確服務名稱！"
		exit 1
	fi
	echo $services
	read -p "輸入品牌號....如030   :" rp
	sshpass -p "9vdWm8VYkuCgZF6X" rsync --list-only -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@104.199.189.61:/home/backup/$services-$rp-*1/*.tar | tail -7
	read -p "填入近一周備份日期檔....如2019-01-01 或最新日期[n]  :" bkdate
	if [ $bkdate == "n" ]; then
		bkdate=$(sshpass -p "9vdWm8VYkuCgZF6X" rsync --list-only -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@104.199.189.61:/home/backup/$services-$rp-*1/*.tar | tail -1 | sed -e 's/^.*\(20.*\)\.tar/\1/')
	fi
	sshpass -p "9vdWm8VYkuCgZF6X" rsync -avW --delete-before -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@104.199.189.61:/home/backup/$services-$rp-*1/*$bkdate.tar /home/backup_tmp/

	ls -lrt /home/backup_tmp/*$bkdate.tar

	#輸入服務代號 ex:01, 02, 21, 22
	read -p "輸入服務代號 ex:01, 02, 11, 12, 13, 21,22, 23 :" rp_num

	#防呆......
	chcek_rp_num=$(echo 01,02,11,12,13,21,22,23 | grep $rp_num)

  if [ -z $chcek_rp_num ]; then
		echo "你別亂好不好?"
		exit
	fi


	# 進入下載資料夾
	cd /home/backup_tmp/
	# 取folder name
	str=$(basename -s _$bkdate.tar ls -t -1 /home/backup_tmp/ | head -n 1)
	echo $str
	# 取目前順序
	nowSort=$($str | awk -F'_' '{print $1}' | awk -F'-' '{print $3}' | cut -c1)
	echo -e "\033[44;37m 目前順序為 :  $nowSort  \033[0m"
	
	if [ $action == "new" ];then	
		# 轉數字
		ascii_num=$(printf "%d" \'$nowSort)
		# 跳下一個順序
		ascii_num=$((ascii_num + 1))
		# 轉字母
		newSort=$(printf \\x$(printf %x $ascii_num))
		echo -e "\033[44;37m 新建順序為 :  $newSort  \033[0m"
	fi

	read -p "解壓縮/y ,  離開/n)   :" yn
	[ "$yn" == "Y" -o "$yn" == "y" ]

	if [ "$yn" = "y" ]; then
		echo "你選擇解壓，解壓後開始執行回復設定"
		#建立資料夾
		mkdir /etc/salt/pki/
		mkdir /etc/salt/pki/minion/
		mkdir /var/log/salt/
		mkdir /etc/salt/minion_id
		mkdir /opt/optdata/
		mkdir /opt/optScript/
		mkdir /opt/Htdocs/   
		mkdir /opt/data/
		if [ $services == "app" ];then
			##app維護路徑
			mkdir /opt/APP/openresty/nginx/conf/lua_Script/           
		elif [ $services == "fend" ];then
			mkdir /opt/data/geoip/
		fi
		
		#刪除原設定
		rm -rf /opt/APP/openresty/nginx/conf/vhost/*
		rm -rf /opt/APP/openresty/nginx/conf/nginx.conf
		rm -rf /opt/APP/openresty/nginx/conf/ssl/*
		rm -rf /opt/Htdocs/*
		rm -rf /etc/sysconfig/iptables
		rm -rf /etc/sysconfig/iptables-config
		rm -rf /opt/APP/openresty/nginx/conf/*.crt
		rm -rf /opt/APP/openresty/nginx/conf/*.cert
		rm -rf /opt/APP/openresty/nginx/conf/*.key
		rm -rf /opt/APP/openresty/nginx/conf/lua_Script/*
		rm -rf /opt/optdata/*
		rm -rf /opt/optScript/*
		rm -rf /etc/salt/minion_id
		rm -rf /etc/salt/minion
		rm -rf /etc/zabbix/*
		rm -rf /var/spool/cron/root
		rm -rf /opt/logs/nginx/*
		rm -rf /var/log/salt/*.gz
		rm -rf /var/log/zabbix/*.gz
		rm -rf /var/log/*.gz

		# 關閉SELINUX
		setenforce 0
		check_selinux=`cat /etc/selinux/config | grep SELINUX=disabled`
		if [ -z $check_selinux ];then
			sed -i "/SELINUX=.*/d" /etc/selinux/config
			echo SELINUX=disabled >> /etc/selinux/config
		fi



		#清除iptables 刪除所有的規則
		iptables -F
		#清除history
		history -c
		#寫入時間點
		check_histtimeformat=`cat /etc/profile | grep HISTTIMEFORMAT=`
		if [[ -z $check_histtimeformat ]];then
			echo HISTTIMEFORMAT='<%F %T>:' >> /etc/profile  
			echo export HISTTIMEFORMAT >> /etc/profile
		fi

		#解開.tar
		tar xvf /home/backup_tmp/*$bkdate.tar -C / &&
		#刪除old salt minion.pem minion.pub
		rm -rf /etc/salt/pki/minion/minion.pem
		rm -rf /etc/salt/pki/minion/minion.pub
		#download new salt minion.pem minion.pub
		sshpass -p "9vdWm8VYkuCgZF6X" rsync -avW --delete-before -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@35.194.220.214:/root/minion_key/minion.pem /etc/salt/pki/minion/
		sshpass -p "9vdWm8VYkuCgZF6X" rsync -avW --delete-before -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@35.194.220.214:/root/minion_key/minion.pub /etc/salt/pki/minion/
		#修改conf 
		sed -i "s/ssl on/#ssl on/g" /opt/APP/openresty/nginx/conf/vhost/*.conf
		sed -i "s/load module/#load module/g" /opt/APP/openresty/nginx/conf/nginx.conf
		#TODO:要先確定是否有加過
		sed -i '/http {/a\variables_hash_max_size 2048;' /opt/APP/openresty/nginx/conf/nginx.conf

		
		if [ $action == "new" ];then
			#修改minion_id
			if [ $services == "app" ];then
				sed -i "s/app-$nowSort.*/app-$newSort$rp_num/g" /etc/salt/minion_id 
			else
				sed -i "s/-$nowSort.*/-$newSort$rp_num/g" /etc/salt/minion_id     
			fi
			# 修改hostname
			hostnamectl set-hostname $services-$rp-$newSort$rp_num

		else

			#修改minion_id
			if [ $services == "app" ];then
				sed -i "s/app-$nowSort.*/app-$nowSort$rp_num/g" /etc/salt/minion_id 
			else
				sed -i "s/-$nowSort.*/-$nowSort$rp_num/g" /etc/salt/minion_id     
			fi
			# 修改hostname
			hostnamectl set-hostname $services-$rp-$nowSort$rp_num
			# 修改agent hostname
			sed -i "s/_$nowSort.*/_$nowSort$rp_num/g" /etc/zabbix/zabbix_agentd.conf
		fi

		echo -e "\033[44;37m minion_id\033[0m"
		cat /etc/salt/minion_id
		echo -e "\033[44;37m hostname\033[0m"
		cat /etc/hostname
		echo -e "\033[44;37m Agent hostname\033[0m"
		cat /etc/zabbix/zabbix_agentd.conf | grep "Hostname"

    #backend 倒回iptables reload 才生效
		if [ $services == "backend" ] || [ $services == "b" ];then
		systemctl reload iptables ; systemctl enable iptables ; systemctl status iptables | grep Active
		fi

		if [ $action == "new" ];then
			#新舊域名替換, 目前用置換域名方式 ex:030-fe-new-old
			change_servername=$(cat /root/rp_servername.txt | grep "$rp-$services")
			if [[ ! -z $change_servername ]];then
			
				for servername in $change_servername; do
					new_servername=$(echo $servername | awk -F\- '{print $3}')
					old_servername=$(echo $servername | awk -F\- '{print $4}') 

					sed -i "s/$old_servername/$new_servername/g" /opt/APP/openresty/nginx/conf/vhost/*.conf
					
					echo -e "\033[43;37m $old_servername ==> $new_servername\033[0m"

				done
			else
				echo -e "\033[41;37m servername error please check!!\033[0m"
			fi
		fi
		source /etc/profile &&
		systemctl stop nginx &&
		systemctl start nginx &&
		systemctl stop firewalld.service && 
		systemctl disable firewalld.service &&
		systemctl stop iptables.service && 
		systemctl stop zabbix-agent &&
		systemctl stop salt-minion &&
		systemctl start salt-minion &&
		systemctl enabled salt-minion.service
		#systemctl start zabbix-agent &&
		systemctl enabled zabbix-agent.service
		echo -e "\033[44;37m Nginx services:\033[0m"
		systemctl status nginx | grep Active
		echo -e "\033[44;37m zabbix-agent services\033[0m"
		systemctl status zabbix-agent | grep Active
		nginx -t
		rm -rf /home/backup_tmp
		rm -rf /home/check_rp_$(date "+%Y%m%d").txt
	else
		echo "STOP!"

	fi
	;;

\
	2)
	echo '你选择了 2'
	echo -e "\033[5m▇▇▇▇▇▇▇ hostname && service status && test healthCheck ▇▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo ===================================================Show hostname
	id=$(uname -n)
	echo -e "\033[47;30m hostname $id \033[0m"
	salt_id=$(cat /etc/salt/minion_id)
	echo -e "\033[47;30m salt_id $salt_id \033[0m"
	agent_id=$(cat /etc/zabbix/zabbix_agentd.conf | grep Hostname)
	echo -e "\033[47;30m agent_id $agent_id \033[0m"

	echo ===================================================Service enabled

	if systemctl list-unit-files | grep nginx.service | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m nginx not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'zabbix-agent.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'salt-minion.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not enabled\033[0m"
	fi

	echo ==================================================Disabled check

    if systemctl list-unit-files | grep firewalld.service | grep disabled ; then
        echo -e "\033[42;37m firewalld disabled OK\033[0m"
    else
        echo -e "\033[41;37m firewalld not disabled\033[0m"
    fi

    if systemctl list-unit-files | grep iptables.service | grep disabled ; then
        echo -e "\033[42;37m iptables disabled OK\033[0m"
    else
        echo -e "\033[41;37m iptables not disabled\033[0m"
    fi

    if cat /etc/selinux/config | grep SELINUX=disabled ; then
            echo -e "\033[42;37m SELINUX disabled OK\033[0m"
    else
            echo -e "\033[41;37m SELINUX not disabled\033[0m"
    fi

	echo ==================================================Service check

	if systemctl is-active --quiet nginx; then
		echo -e "\033[42;37m nginx running OK\033[0m"
	else
		echo -e "\033[41;37m nginx not running\033[0m"
	fi

	if systemctl is-active --quiet zabbix-agent; then
		echo -e "\033[42;37m zabbix-agent running OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not running\033[0m"
	fi

	if systemctl is-active --quiet salt-minion; then
		echo -e "\033[42;37m salt-minion running OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not running\033[0m"
	fi
	echo ==================================================nginx -t
	nginx -t
	echo ==================================================crontab
	crontab -l

	###upstream test

	rm -rf /home/upstream_list.txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | awk '{print $2}' | awk '!a[$1$ $3]++' >>/home/upstream_list.txt

	filename='/home/upstream_list.txt'
	exec <$filename

	while read line; do
		echo ==================================================upstream IP
		echo $line # 一行一行印出內容
		echo ==================================================upstream test healthCheck
		httping -c2 -t2 -s $line/apis/healthCheck | grep '200\|failed\|connect time out'
        curl -I --connect-timeout 2 $line/apis/healthCheck | grep '200'
	done
	echo
	echo
	echo
	echo
	echo
	echo

	######Nginx_Check
	echo -e "\033[5m▇▇▇▇▇▇▇ Nginx詳細設定.conf數量&後端IP&nginx設定檔正確性 ▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m使用中SSL證書\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep ssl_certificate | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mSSL證書檔案\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/APP/openresty/nginx/conf/ssl | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m保留IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mallow-ips保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/allow-ips | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mGEO_IP \033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/nginx.conf | grep " 0;" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mGEO_IP數量 \033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/nginx.conf | grep " 0;" | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#######Access Log
	echo -e "\033[43m_4_Access_Log 近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態前台不開啟\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt

	echo -
	echo -
	echo -

	######FE Ymal check
	echo -e "\033[43m_7_前台Ymal檔Check\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mymal檔案\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/optdata/*yaml | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mymal設定\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/optdata/*yaml | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -

	######FE MA check
	echo -e "\033[43m_8_前台MA_Check\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m前台維護狀態0為關閉 1為開啟\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	if    cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "#" | grep "MAM 1"; 
        then  echo -e "\033[41;37m MA 開啟 \033[0m"      
    elif  cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "#" | grep "MAM 0";
        then  echo -e "\033[42;37m MA 關閉 \033[0m"
    else
        echo -e "\033[41;37m 未有MA字串，請重新查詢 \033[0m"
    fi

	echo -e "\033[36m前台維護Htdoc資料夾Check\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/Htdocs/service/ | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	;;

3)
	echo '你选择了 3'
	echo -e "\033[5m▇▇▇▇▇▇▇ hostname && service status && test healthCheck ▇▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo ===================================================Show hostname
	id=$(uname -n)
	echo -e "\033[47;30m hostname $id \033[0m"
	salt_id=$(cat /etc/salt/minion_id)
	echo -e "\033[47;30m salt_id $salt_id \033[0m"
	agent_id=$(cat /etc/zabbix/zabbix_agentd.conf | grep Hostname)
	echo -e "\033[47;30m agent_id $agent_id \033[0m"

	echo ===================================================Service enabled

	if systemctl list-unit-files | grep nginx.service | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m nginx not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'zabbix-agent.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'salt-minion.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not enabled\033[0m"
	fi

	echo ==================================================Disabled check

    if systemctl list-unit-files | grep firewalld.service | grep disabled ; then
        echo -e "\033[42;37m firewalld disabled OK\033[0m"
    else
        echo -e "\033[41;37m firewalld not disabled\033[0m"
    fi

    if systemctl list-unit-files | grep iptables.service | grep disabled ; then
        echo -e "\033[42;37m iptables disabled OK\033[0m"
    else
        echo -e "\033[41;37m iptables not disabled\033[0m"
    fi

    if cat /etc/selinux/config | grep SELINUX=disabled ; then
            echo -e "\033[42;37m SELINUX disabled OK\033[0m"
    else
            echo -e "\033[41;37m SELINUX not disabled\033[0m"
    fi

	echo ==================================================Service check

	if systemctl is-active --quiet nginx; then
		echo -e "\033[42;37m nginx running OK\033[0m"
	else
		echo -e "\033[41;37m nginx not running\033[0m"
	fi

	if systemctl is-active --quiet zabbix-agent; then
		echo -e "\033[42;37m zabbix-agent running OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not running\033[0m"
	fi

	if systemctl is-active --quiet salt-minion; then
		echo -e "\033[42;37m salt-minion running OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not running\033[0m"
	fi
	echo ==================================================nginx -t
	nginx -t

	echo ==================================================crontab
	crontab -l

	###upstream test

	rm -rf /home/upstream_list.txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | awk '{print $2}' | awk '!a[$1$ $3]++' >>/home/upstream_list.txt

	filename='/home/upstream_list.txt'
	exec <$filename

	while read line; do
		echo ==================================================upstream IP
		echo $line # 一行一行印出內容
		echo ==================================================upstream test healthCheck
		httping -c2 -t2 -s $line/apis/healthCheck | grep '200\|failed\|connect time out'
	    curl -I --connect-timeout 2 $line/apis/healthCheck | grep '200'	
	done
	echo
	echo
	echo
	echo
	echo
	echo

	######Nginx_Check
	echo -e "\033[5m▇▇▇▇▇▇▇ Nginx詳細設定.conf數量&後端IP&nginx設定檔正確性 ▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mallow-ips保留IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/allow-ips | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#######Access Log
	echo -e "\033[43m_4_Access_Log近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態APP不使用\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt

	echo -
	echo -
	echo -

	######APP MA_Check
	echo -e "\033[43m_9_APP_MA_設定檔_Check\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAPP_MA_wh.dat\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/APP/openresty/nginx/conf/lua_Script/APP/ | tee -a /home/check_rp_$(date "+%Y%m%d").txt

	if [ -f /opt/APP/openresty/nginx/conf/lua_Script/APP/wh.dat ]; then
		echo "wh.dat檔已存在"
	else
		echo "wh.dat檔未存在"
	fi

	echo -e "\033[36mAPP_MA狀態_0關閉 1開啟\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt

        if    cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "#" | grep "AppMaintainLog 1\|AppMaintainMode 1";
        then  echo -e "\033[41;37m APP MA 開啟 \033[0m"
        elif  cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "#" | grep "AppMaintainLog 0\|AppMaintainMode 0";
        then  echo -e "\033[42;37m APP MA 關閉 \033[0m"
        else
        echo -e "\033[41;37m 未有MA字串，請重新查詢 \033[0m"
        fi
	;;
	
4)
	echo '你选择了 4'
	echo -e "\033[5m▇▇▇▇▇▇▇ hostname && service status && test healthCheck ▇▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo ===================================================Show hostname
	id=$(uname -n)
	echo -e "\033[47;30m hostname $id \033[0m"
	salt_id=$(cat /etc/salt/minion_id)
	echo -e "\033[47;30m salt_id $salt_id \033[0m"
	agent_id=$(cat /etc/zabbix/zabbix_agentd.conf | grep Hostname)
	echo -e "\033[47;30m agent_id $agent_id \033[0m"

	echo ===================================================Service enabled

	if systemctl list-unit-files | grep nginx.service | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m nginx not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'zabbix-agent.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'salt-minion.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not enabled\033[0m"
	fi

    if systemctl list-unit-files | grep 'iptables.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m iptables not enabled\033[0m"
	fi

    echo ==================================================Disabled check

    if systemctl list-unit-files | grep firewalld.service | grep disabled ; then
            echo -e "\033[42;37m firewalld disabled OK\033[0m"
    else
            echo -e "\033[41;37m firewalld not disabled\033[0m"
    fi

    if cat /etc/selinux/config | grep SELINUX=disabled ; then
            echo -e "\033[42;37m SELINUX disabled OK\033[0m"
    else
            echo -e "\033[41;37m SELINUX not disabled\033[0m"
    fi

	echo ==================================================Service check

	if systemctl is-active --quiet nginx; then
		echo -e "\033[42;37m nginx running OK\033[0m"
	else
		echo -e "\033[41;37m nginx not running\033[0m"
	fi

	if systemctl is-active --quiet zabbix-agent; then
		echo -e "\033[42;37m zabbix-agent running OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not running\033[0m"
	fi

	if systemctl is-active --quiet salt-minion; then
		echo -e "\033[42;37m salt-minion running OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not running\033[0m"
	fi
	echo ==================================================nginx -t
	nginx -t

	echo ==================================================crontab
	crontab -l

	###upstream test

	rm -rf /home/upstream_list.txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | awk '{print $2}' | awk '!a[$1$ $3]++' >>/home/upstream_list.txt

	filename='/home/upstream_list.txt'
	exec <$filename

	while read line; do
		echo ==================================================upstream IP
		echo $line # 一行一行印出內容
		echo ==================================================upstream test healthCheck
		httping -c2 -t2 -s $line/apis/healthCheck
        curl -I --connect-timeout 2 $line/apis/healthCheck | grep '200'
	done

	######Nginx_Check
	echo -e "\033[5m▇▇▇▇▇▇▇ Nginx詳細設定.conf數量&後端IP&nginx設定檔正確性 ▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mSSL證書\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep ssl_certificate | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m保留IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt

	######Access log
	echo -e "\033[43m_4_Access_Log近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36m Iptables -L -n\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; iptables -L -n  | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -

	;;
5)
	echo '你选择了 5'
	echo -e "\033[5m▇▇▇▇▇▇▇ hostname && service status && test healthCheck ▇▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo ===================================================Show hostname
	id=$(uname -n)
	echo -e "\033[47;30m hostname $id \033[0m"
	salt_id=$(cat /etc/salt/minion_id)
	echo -e "\033[47;30m salt_id $salt_id \033[0m"
	agent_id=$(cat /etc/zabbix/zabbix_agentd.conf | grep Hostname)
	echo -e "\033[47;30m agent_id $agent_id \033[0m"

	echo ===================================================Service enabled

	if systemctl list-unit-files | grep nginx.service | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m nginx not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'zabbix-agent.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not enabled\033[0m"
	fi

	if systemctl list-unit-files | grep 'salt-minion.service' | grep enabled; then
		echo -e "\033[42;37m enabled OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not enabled\033[0m"
	fi

	echo ==================================================Disabled check

    if systemctl list-unit-files | grep firewalld.service | grep disabled ; then
        echo -e "\033[42;37m firewalld disabled OK\033[0m"
    else
        echo -e "\033[41;37m firewalld not disabled\033[0m"
    fi

    if systemctl list-unit-files | grep iptables.service | grep disabled ; then
        echo -e "\033[42;37m iptables disabled OK\033[0m"
    else
        echo -e "\033[41;37m iptables not disabled\033[0m"
    fi

    if cat /etc/selinux/config | grep SELINUX=disabled ; then
            echo -e "\033[42;37m SELINUX disabled OK\033[0m"
    else
            echo -e "\033[41;37m SELINUX not disabled\033[0m"
    fi

	echo ==================================================Service check

	if systemctl is-active --quiet nginx; then
		echo -e "\033[42;37m nginx running OK\033[0m"
	else
		echo -e "\033[41;37m nginx not running\033[0m"
	fi

	if systemctl is-active --quiet zabbix-agent; then
		echo -e "\033[42;37m zabbix-agent running OK\033[0m"
	else
		echo -e "\033[41;37m zabbix-agent not running\033[0m"
	fi

	if systemctl is-active --quiet salt-minion; then
		echo -e "\033[42;37m salt-minion running OK\033[0m"
	else
		echo -e "\033[41;37m salt-minion not running\033[0m"
	fi
	echo ==================================================nginx -t
	nginx -t

	echo ==================================================crontab
	crontab -l

	###upstream test

	rm -rf /home/upstream_list.txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | awk '{print $2}' | awk '!a[$1$ $3]++' >>/home/upstream_list.txt

	filename='/home/upstream_list.txt'
	exec <$filename

	while read line; do
		echo ==================================================upstream IP
		echo $line # 一行一行印出內容
		echo ==================================================upstream test healthCheck
		httping -c2 -t2 -s $line/info
        curl -I --connect-timeout 2 $line/info | grep '200'
	done

	######Nginx_Check
	echo -e "\033[5m▇▇▇▇▇▇▇ Nginx詳細設定.conf數量&後端IP&nginx設定檔正確性 ▇▇▇▇▇▇▇\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m保留IP\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt

	######Access log
	echo -e "\033[43m_4_Access_Log近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態應關閉\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36m Iptables -L -n\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; iptables -L -n  | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	cat /etc/sysconfig/iptables | grep -v "#" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -

	;;

\
	*)
	echo '你没有输入 1 到 5 之间的数字'
	;;
esac

