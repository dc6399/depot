#!/bin/bash


#選單
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
    1)  echo '你选择了 1'; 
	if [ ! -d /home/backup_tmp ]; then
	  mkdir -p /home/backup_tmp
	else
	  rm -f /home/backup_tmp/*
	fi
        echo -e "\033[44;37m 抓取1RP備份檔案\033[0m"

        echo 抓取1RP備份檔案
        read -p "輸入[b]backend、[f]frontend、[a]app、[p]pay   :"  services
	if [ $services == "backend" ] || [ $services == "b" ]; then
	  services="backend"
	elif [ $services == "frontend" ] || [ $services == "f" ] ; then
	  services="frontend"
	elif [ $services == "app" ] || [ $services == "a" ]; then
	  services="app"
	elif [ $services == "pay" ] || [ $services == "p" ]; then
	  services="pay"
	else
	  echo "請輸入正確服務名稱！"
	  exit 1
	fi
	echo $services
	read -p "輸入品牌號....如030   :"  rp
	sshpass -p "9vdWm8VYkuCgZF6X" rsync --list-only -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@104.199.189.61:/home/backup/$services-$rp-*1/*.tar | tail -7;
	read -p "填入近一周備份日期檔....如2019-01-01 或最新日期[n]  :"  bkdate
	if [ $bkdate == "n" ]; then
	  bkdate=`sshpass -p "9vdWm8VYkuCgZF6X" rsync --list-only -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@104.199.189.61:/home/backup/$services-$rp-*1/*.tar | tail -1 | sed -e 's/^.*\(20.*\)\.tar/\1/'`
	fi
	sshpass -p "9vdWm8VYkuCgZF6X" rsync -avW --delete-before -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@104.199.189.61:/home/backup/$services-$rp-*1/*$bkdate.tar  /home/backup_tmp/;

	ls -lrt  /home/backup_tmp/*$bkdate.tar

	read -p "解壓縮/y ,  離開/n)   :" yn
	[ "$yn" == "Y" -o "$yn" == "y" ]


	if [ "$yn" = "y" ]; then
	echo "你選擇解壓，解壓後開始執行回復設定"
	sleep 3s

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
    
	#解開.tar
	tar xvf /home/backup_tmp/*$bkdate.tar  -C / && 
	#刪除old salt minion.pem minion.pub
	rm -rf /etc/salt/pki/minion/minion.pem
	rm -rf /etc/salt/pki/minion/minion.pub
	#download new salt minion.pem minion.pub
	sshpass -p "9vdWm8VYkuCgZF6X" rsync -avW --delete-before -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@35.194.220.214:/root/minion_key/minion.pem   /etc/salt/pki/minion/
	sshpass -p "9vdWm8VYkuCgZF6X" rsync -avW --delete-before -e 'ssh -o StrictHostKeyChecking=no -p 45092' root@35.194.220.214:/root/minion_key/minion.pub   /etc/salt/pki/minion/
	systemctl stop nginx  && 
	systemctl start nginx &&
	#systemctl stop zabbix-agent &&
	#systemctl start zabbix-agent &&
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


    2)  echo '你选择了 2'

	######Name_Check
	rm -rf /home/check_rp_$(date "+%Y%m%d").txt
	echo Check Date $(date "+%Y-%m-%d %H:%M")| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[43m_1_CHECK_NAME \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_hostname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; uname -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_saltname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/salt/minion_id | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_zabbix_agnet \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/zabbix/zabbix_agentd.conf | grep Hostname | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
        sleep 1s
        ######Service_Check
        echo -e "\033[43m_2_CHECK_Service \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mCheck_Service_NGINX \033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;systemctl  status nginx  | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mCheck_Service_ZABBIX_Agnet \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status zabbix-agent | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mCheck_Service_Salt \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status salt-minion | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mCheck_Service_Iptables前台不使用\033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl status iptables | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -
        echo -
        echo -
        sleep 1s
        ######Nginx_Check
        echo -e "\033[43m_3_Nginx_CHECK_.conf數量&後端IP&nginx設定檔正確性\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36m.conf數量&Check_後端IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mnginx -t \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; nginx -t | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36m使用中SSL證書\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep ssl_certificate | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mSSL證書檔案\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/ssl | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mproxy_pass\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36m保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        #echo -e "\033[36mallow-ips保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/allow-ips | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mAccess_Log_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mGEO_IP \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf | grep " 0;" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mGEO_IP數量 \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf | grep " 0;" | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mServer_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        #######Access Log
        echo -e "\033[43m_4_Access_Log 近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -
        echo -
        echo -
        sleep 1s
        ######Crontab
        echo -e "\033[43m_5_Check Crontab\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
        echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -
        echo -
        echo -
        sleep 1s
        ######Iptables-L-n
        echo -e "\033[43m_6_Iptables 狀態前台不開啟\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
        echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables | grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables |grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt

        echo -
        echo -
        echo -

        ######FE Ymal check
        echo -e "\033[43m_7_前台Ymal檔Check\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
        echo -e "\033[36mymal檔案\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/optdata/*yaml  | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36mymal設定\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/optdata/*yaml | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -
        echo -
        echo -

        ######FE MA check
        echo -e "\033[43m_8_前台MA_Check\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
        echo -e "\033[36m前台維護狀態0為關1為開\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "#" | grep  "MAM " | tee -a /home/check_rp_$(date "+%Y%m%d").txt
        echo -e "\033[36m前台維護Htdoc資料夾Check\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;ls -lrt /opt/Htdocs/service/ | tee -a /home/check_rp_$(date "+%Y%m%d").txt

	;;

	3)  echo '你选择了 3'
        
	######Name_Check
        rm -rf /home/check_rp_$(date "+%Y%m%d").txt
        echo Check Date $(date "+%Y-%m-%d %H:%M")| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[43m_1_CHECK_NAME \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_hostname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; uname -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_saltname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/salt/minion_id | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_zabbix_agnet \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/zabbix/zabbix_agentd.conf | grep Hostname | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Service_Check
	echo -e "\033[43m_2_CHECK_Service \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_NGINX \033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;systemctl  status nginx  | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_ZABBIX_Agnet \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status zabbix-agent | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_Salt \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status salt-minion | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_Iptables APP不使用\033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl status iptables | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Nginx_Check
	echo -e "\033[43m_3_Nginx_CHECK_.conf數量&後端IP&nginx設定檔正確性\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mnginx -t \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; nginx -t | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36m使用中SSL證書\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep ssl_certificate | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mSSL證書檔案\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/ssl | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36m保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mallow-ips保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/allow-ips | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mGEO_IP \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf | grep " 0;" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mGEO_IP數量 \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf | grep " 0;" | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#######Access Log
	echo -e "\033[43m_4_Access_Log近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態APP不使用\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables | grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables |grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	
	echo -
	echo -
	echo -
	
	
	
	######APP MA_Check
	echo -e "\033[43m_9_APP_MA_設定檔_Check\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAPP_MA_wh.dat\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/lua_Script/APP/ | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	
	if [ -f /opt/APP/openresty/nginx/conf/lua_Script/APP/wh.dat ]; then
			echo "wh.dat檔已存在"
	else
			echo "wh.dat檔未存在"
	fi
	
	echo -e "\033[36mAPP_MA狀態_0開1開\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep "AppMaintainLog\|AppMaintainMode" | tee -a /home/check_rp_$(date "+%Y%m%d").txt

    ;;

    4)  echo '你选择了 4'

	######Name_Check
        rm -rf /home/check_rp_$(date "+%Y%m%d").txt
        echo Check Date $(date "+%Y-%m-%d %H:%M")| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[43m_1_CHECK_NAME \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_hostname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; uname -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_saltname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/salt/minion_id | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_zabbix_agnet \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/zabbix/zabbix_agentd.conf | grep Hostname | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo - 
	echo - 
	echo -
	sleep 1s 
	######Service_Check
	echo -e "\033[43m_2_CHECK_Service \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_NGINX \033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;systemctl  status nginx  | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_ZABBIX_Agnet \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status zabbix-agent | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_Salt \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status salt-minion | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_Iptables \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl status iptables | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s 
	######Nginx_Check
	echo -e "\033[43m_3_Nginx_CHECK_.conf數量&後端IP&nginx設定檔正確性\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mnginx -t \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; nginx -t | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mSSL證書\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep ssl_certificate | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mGEO_IP \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf |grep " 0;" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mGEO_IP數量 \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf | grep /32 | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	
	######Access log
	echo -e "\033[43m_4_Access_Log近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s 
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
	#echo -e "\033[36m Iptables -L -n\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; iptables -L -n  | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables | grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables |grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo - 
	echo -
	echo -

        ;;
    5)  echo '你选择了 5'
        
	######Name_Check
        rm -rf /home/check_rp_$(date "+%Y%m%d").txt
        echo Check Date $(date "+%Y-%m-%d %H:%M")| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[43m_1_CHECK_NAME \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_hostname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; uname -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_saltname \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/salt/minion_id | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_zabbix_agnet \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/zabbix/zabbix_agentd.conf | grep Hostname | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo - 
	echo - 
	echo -
	sleep 1s 
	######Service_Check
	echo -e "\033[43m_2_CHECK_Service \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_NGINX \033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;systemctl  status nginx  | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_ZABBIX_Agnet \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status zabbix-agent | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_Salt \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl  status salt-minion | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mCheck_Service_Iptables \033[0m"  | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; systemctl status iptables | grep "Active:" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s 
	######Nginx_Check
	echo -e "\033[43m_3_Nginx_CHECK_.conf數量&後端IP&nginx設定檔正確性\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m.conf數量&Check_後端IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; ls -lrt /opt/APP/openresty/nginx/conf/vhost/*conf ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "ssl_prefer_\|server_name\|server {" | grep server | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mnginx -t \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; nginx -t | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mSSL證書\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep ssl_certificate | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mproxy_pass\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "proxy_pass" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m保留IP\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "203.177.179.69\|203.177.171.98\|112.199.32.122" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mAccess_Log_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*.conf | grep "access_log\|error_log" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mGEO_IP \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf |grep " 0;" | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	#echo -e "\033[36mGEO_IP數量 \033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/nginx.conf | grep /32 | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36mServer_Name\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /opt/APP/openresty/nginx/conf/vhost/*conf | grep -v "server_name  _;" | grep server_name | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	
	######Access log
	echo -e "\033[43m_4_Access_Log近5筆狀態\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;tail /opt/logs/nginx/*access.log | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s
	######Crontab
	echo -e "\033[43m_5_Check Crontab\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
	echo -e "\033[36mCrontab是否有設定，未上線前把Splunk註解掉\033[0m"| tee -a /home/check_rp_$(date "+%Y%m%d").txt ; crontab -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -
	echo -
	echo -
	sleep 1s 
	######Iptables-L-n
	echo -e "\033[43m_6_Iptables 狀態應關閉\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ;
	#echo -e "\033[36m Iptables -L -n\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; iptables -L -n  | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables | grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo -e "\033[36m Iptables筆數\033[0m" | tee -a /home/check_rp_$(date "+%Y%m%d").txt ; cat /etc/sysconfig/iptables |grep -v "#"| grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}|([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -n | wc -l | tee -a /home/check_rp_$(date "+%Y%m%d").txt
	echo - 
	echo -
	echo -

	;;



    *)  echo '你没有输入 1 到 5 之间的数字'
    ;;
	esac

