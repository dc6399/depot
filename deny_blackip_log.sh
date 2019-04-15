#!/bin/bash
#Author:ZhangGe
#Desc:Auto Deny Black_IP Script.
#Date:2014-11-05
#取得参数$1为并发阈值，若留空则默认允许单IP最大50并发(实际测试发现，2M带宽，十来个并发服务器就已经无法访问了！)
if [[ -z $1 ]];then
        num=3000
else 
        num=$1
fi

check_time=`date '+%Y:%H'`
#巧妙的进入到脚本工作目录
cd $(cd $(dirname $BASH_SOURCE) && pwd)
 
#请求检查、判断及拉黑主功能函数
function check(){
        #iplist=`netstat -an |grep ^tcp.*:443|egrep -v 'LISTEN|127.0.0.1'|awk -F"[ ]+|[:]" '{print $6}'|sort|uniq -c|sort -rn|awk -v str=$num '{if ($1>str){print $2}}'`
        iplist=`cat /opt/logs/nginx/*.access.log | grep "apis/login" | grep "$check_time" |  awk '{print $3}' | awk -F\= '{print $2}' | sort | uniq -c | sort -rn | awk -v str=$num '{if ($1>str){print $2}}'`
        echo "start $check_time"
        echo $iplist
        if [[ ! -z $iplist ]];
                then
                >./black_ip.txt
                for black_ip in $iplist
                do
                        #白名单过滤中已取消IP段的判断功能，可根据需要自行修改以下代码(请参考前天写的脚本)
                        #exclude_ip=`echo $black_ip | awk -F"." '{print $1"."$2"."$3}'`
                        #grep -q $exclude_ip ./white_ip.txt
                        grep -q $black_ip ./white_ip.txt
                        if [[ $? -eq 0 ]];then
                                echo "$black_ip (white_ip)" >>./black_ip.txt
                        else
                                echo $black_ip >>./black_ip.txt     
                                iptables -nL | grep $black_ip ||(iptables -I INPUT -s $black_ip -j DROP & echo "$black_ip  `date +%Y-%m-%d %H:%M:%S`">>./deny.log)
                                sleep 3
                        fi
                done
                #存在并发超过阈值的单IP就发送邮件
                #if [[ `cat ./sendmail` == 1 ]];then sendmsg;fi
        fi
        echo "sleep"
}
 
#发邮件函数
#function sendmsg(){
#       netstat -nutlp | grep "sendmail" >/dev/null 2>&1 || /etc/init.d/sendmail start >/dev/null 2>&1
#        echo -e "From: 发邮件地址@qq.com\nTo:nickchangs@gmail.com\nSubject:Someone Attacking your system!!\nIts Ip is" >./message
#        cat ./black_ip.txt >>./message
#        /usr/sbin/sendmail -f nickchangs@gmail.com -t nickchangs@gmail.com -i <./message
#        >./sendmail
#}
 
#间隔10s无限循环检查函数
while true
do 
        check
        #每隔10s检查一次，时间可根据需要自定义
        sleep 300
done
