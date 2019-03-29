#! /bin/bash
clear
mv /usr/lib/systemd/system/openvpn-client@.service openvpn-client@.old
mv /usr/lib/systemd/system/openvpn-server@.service openvpn-server@.old
mv /usr/lib/systemd/system/openvpn@.service openvpn@.old
wget https://github.com/dc6399/depot/raw/master/ovpn_svr.tgz
cd /
tar -xzvf /root/ovpn_svr.tgz
systemctl restart openvpn@server
