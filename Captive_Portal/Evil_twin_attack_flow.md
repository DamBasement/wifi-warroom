
# ☠️ Evil Twin Captive Portal Lab (Demo Environment)

A fully self-contained Evil Twin + Captive Portal lab for educational and authorized demonstration purposes.

This setup lets you simulate a rogue Wi-Fi access point with a fake login portal (Google-style) and log test credentials — all offline and legally.

---

## ⚙️ Requirements

- Linux (Kali recommended)
- `hostapd`, `dnsmasq`, `php`, `xterm`
- One Wi-Fi adapter in AP mode (e.g. Alfa AWUS036NHA)
- A mobile phone or laptop as the victim device

---

## 🗂️ Folder Structure

```
evil-twin-lab/
├── captive_portal/
│   ├── google.html        ← Fake Google login page
│   └── submit.php         ← Logs credentials to creds.txt
├── configs/
│   ├── hostapd.conf
│   └── dnsmasq.conf
├── start_lab.sh           ← Launches everything
├── creds.txt              ← Populated at runtime
```

---

## 🚀 Run the Lab

### 1. Make sure your Wi-Fi interface is clean

```bash
sudo ip link set wlan0 down
sudo ip addr flush dev wlan0
sudo ip link set wlan0 up
```

> Replace `wlan0` with your interface.

---

### 2. Start the lab

```bash
chmod +x start_lab.sh
sudo ./start_lab.sh
```

Three terminals will open:
- `hostapd`: Rogue AP with SSID `CorpNet`
- `dnsmasq`: DHCP + DNS redirect
- `php`: Fake login page server

---

## 🧪 Test the setup

1. Connect your phone to **CorpNet**
2. Open a browser and go to:

```
http://neverssl.com
```

3. You’ll be redirected to the fake Google login
4. Enter test credentials
5. Check `creds.txt`

---

## ⚠️ Legal & Ethical Use Only

This lab is **not** for real-world deployment. Use only:
- In offline or airgapped environments
- With your own devices
- With full awareness and consent of participants

---

## 📜 License

MIT — This project is educational and must be used responsibly.
