service stop vpnserver

rm /root/vpnserver

cd /root

rm /root/softether*.gz

yum install -y gcc

yum update -y

wget https://github.com/dc6399/depot/blob/master/softether-vpnserver-v4.22-9634-beta-2016.11.27-linux-x64-64bit.tar.gz

tar -zxvf softether-vpnserver-v4.22-9634-beta-2016.11.27-linux-x64-64bit.tar.gz

cd /vpnserver

./.install.sh

./vpnserver start
