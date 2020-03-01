#!/bin/bash

## maintain 產生base
## salt  0*-*-fe-d* cmd.run "cat /opt/Htdocs/service/maintain.json"  --out=json --static   > /etc/salt/deploy/scripts/json/maintain_base.json >>複製 maintain_base.json 至/var/www/html/json/maintain

#需要給予zabbix sudo 權限 vi /etc/sudoers
# Defaults   !visiblepw => Defaults   visiblepw
# zabbix  ALL=(ALL)       NOPASSWD:ALL

salt_minion=$(cat /etc/salt/minion_id)
agent_hostname=$(cat /etc/zabbix/zabbix_agentd.conf | grep -e Hostname=.* | awk -F'=' '{print $2}')

# 對proxy 拉取 maintian_base, 需安裝jq
maintain_base=$(curl -s http://104.155.239.122:8943/json/maintain/maintain_base.json | jq ".\"$salt_minion\"" | sed 's/\\//g'| sed 's/^"//' | sed 's/"$//' >/tmp/"$salt_minion"_base)

local_maintain=$(cat /opt/Htdocs/service/maintain.json >/tmp/"$salt_minion"_maintain)

# 比較差異
sdiff -E -b -i -s /tmp/"$salt_minion"_base /tmp/"$salt_minion"_maintain

# 發出zabbix告警, 需安裝zabbix_sender
# rpm -ivh http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-sender-4.2.8-1.el7.x86_64.rpm

if [ $? = 1 ]; then
  # zabbix_sender -vv -z 121.18.238.84 -p 10051 -s "Hebei_WebMonitor" -k "888cdn.bbftr.com" -o "error"
  /usr/bin/zabbix_sender -z 104.155.239.122 -p 10051 -s "$agent_hostname" -k maintain_check -o 'error' --tls-connect psk --tls-psk-identity "PSK 001" --tls-psk-file /etc/zabbix/zabbix_agentd.psk
else
  /usr/bin/zabbix_sender -z 104.155.239.122 -p 10051 -s "$agent_hostname" -k maintain_check -o 'success' --tls-connect psk --tls-psk-identity "PSK 001" --tls-psk-file /etc/zabbix/zabbix_agentd.psk
fi

