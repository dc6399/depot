#! /bin/bash
clear
cd /root
mv /usr/lib/systemd/system/openvpn-client@.service /usr/lib/systemd/system/openvpn-client@.old
mv /usr/lib/systemd/system/openvpn-server@.service /usr/lib/systemd/system/openvpn-server@.old
mv /usr/lib/systemd/system/openvpn@.service /usr/lib/systemd/system/openvpn@.old
wget https://github.com/dc6399/depot/raw/master/ovpn_svr.tgz
cd /
tar -xzvf /root/ovpn_svr.tgz
cd /root
#VPS安裝(proxy採用docker container建置)
#取得變數
ipaddr=`ss -t | grep ssh | awk '{ print $4}' | awk -F':' '{print $1}'`
echo "VPS地區選擇："
echo "請輸入地區代號："
echo "001：江蘇 002：廣東 003：廣西 004：河北 005：福建"
echo "006：淅江 007：貴州 008：河南 009：江西 010：北京"
echo "011：湖南 012：四川 013：山東 014：上海 015：安徵"
echo "016：遼寧 017：吉林 018：重慶 019：湖北 020：黑龍江"
echo "21：天津 22：陝西 23：山西"
read -p "請輸入VPS所在地區代號(請輸入三位數數字): " NewName
case "$NewName" in
"001")
    sed -i 's/remote 221.204.213.252/remote 58.218.198.140/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 58.218.198.140/g' /root/VPN-name.ovpn
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"002")
    sed -i 's/remote 221.204.213.252/remote 121.201.126.154/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 121.201.126.154/g' /root/VPN-name.ovpn
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"003")
    sed -i 's/remote 221.204.213.252/remote 121.31.40.102/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 121.31.40.102/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"004")
    sed -i 's/remote 221.204.213.252/remote 121.18.238.84/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 121.18.238.84/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"005")
    sed -i 's/remote 221.204.213.252/remote 218.85.133.196/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 218.85.133.196/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"006")
    sed -i 's/remote 221.204.213.252/remote 122.228.244.207/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 122.228.244.207/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"007")
    sed -i 's/remote 221.204.213.252/remote 123.249.34.189/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 123.249.34.189/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"008")
    sed -i 's/remote 221.204.213.252/remote 222.88.94.206/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 222.88.94.206/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"009")
    sed -i 's/remote 221.204.213.252/remote 117.21.191.101/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 117.21.191.101/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"010")
    sed -i 's/remote 221.204.213.252/remote 119.90.126.103/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 119.90.126.103/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"011")
    sed -i 's/remote 221.204.213.252/remote 124.232.137.43/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 124.232.137.43/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"012")
    sed -i 's/remote 221.204.213.252/remote 118.123.243.214/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 118.123.243.214/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"013")
    sed -i 's/remote 221.204.213.252/remote 27.221.52.39/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 27.221.52.39/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"014")
    sed -i 's/remote 221.204.213.252/remote 221.181.73.38/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 221.181.73.38/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"015")
    sed -i 's/remote 221.204.213.252/remote 60.169.77.177/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 60.169.77.177/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"016")
    sed -i 's/remote 221.204.213.252/remote 42.7.27.156/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 42.7.27.156/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"017")
    sed -i 's/remote 221.204.213.252/remote 202.111.175.61/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 202.111.175.61/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"018")
    sed -i 's/remote 221.204.213.252/remote 219.153.49.198/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 219.153.49.198/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"019")
    sed -i 's/remote 221.204.213.252/remote 219.138.135.102/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 219.138.135.102/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"020")
    sed -i 's/remote 221.204.213.252/remote 125.211.218.83/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 125.211.218.83/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"021")
    sed -i 's/remote 221.204.213.252/remote 60.28.24.175/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 60.28.24.175/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"022")
    sed -i 's/remote 221.204.213.252/remote 117.34.109.53/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 117.34.109.53/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
"023")
    sed -i 's/remote 221.204.213.252/remote 221.204.213.252/g' /root/VPN-cert.ovpn 
    sed -i 's/remote 221.204.213.252/remote 221.204.213.252/g' /root/VPN-name.ovpn 
    cp /root/VPN-cert.ovpn /root/VPN-$NewName-$(date "+%Y%m%d").ovpn
    ;;
esac

systemctl restart openvpn@server
systemctl daemon-reload
systemctl restart openvpn@server
rm -rf /root/ovpn_svr.tgz

systemctl status openvpn@server