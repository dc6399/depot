#!/bin/bash
#抓取vhost config內綁定域名並解析出IP，把每個域名與IP中間用空白隔開，並每筆輸出成一行
regex='^\w+\.+\w'

output_file=/tmp/`hostname`.txt

if [[ -e $output_file ]]
then
	rm $output_file
fi

domains=`find /opt/APP/openresty/nginx/conf/vhost/ -type f -name "*.conf" -print0 | xargs -0 egrep '^(\s|\t)*server_name[ \s\t]*\w+\.+\w' | sed -r 's/(.*server_name\s*|;)//g' | uniq`

for domain in $domains; do
    if [[ $domain =~ $regex ]]; then
        echo -n $domain >> $output_file;
        ip=$(nslookup "$domain" | awk '/^Address: / { print $2 }')
        echo -n ' ' >> $output_file;
        echo $ip >> $output_file;
        echo -e "\r\n" >> $output_file;
    else
        echo $domain " is not match" >> $output_file;
    fi
done
