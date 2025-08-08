# 🛰️ WiFi-warROOOOOOM

**Protocols are weak. Frequencies are open.**  

<div align="center">
  <img src="https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExOXphaWtrOHgwbHJxaWM5Y25oOGQ2dGQzZHZnM3dlZ2g4d29pYTNzZSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/xT1XGYfsullHcbqoFi/giphy.gif" width="500"/>
</div>  

This is my war log — a CLI-first battleground for wireless exploitation.

---

## 🗺️ Overview

A curated collection of **attack flows**, **field notes**, and **hands-on exploits**  
covering WEP, WPA2-PSK, and WPA2-Enterprise.

- No screenshots.  
- No GUIs.  
- **Just command-line.**

Perfect for red teamers, OSWP prep, or anyone who thinks air is free real estate.

---

## 📁 Repo Structure

| File | Description |
|------|-------------|
| `wep_attack_flow.md` | WEP cracking walkthrough using `aircrack-ng` + `wpa_supplicant` |
| `wpa2_psk_flow.md` | WPA2-PSK handshake capture and offline brute-force |
| `wpa2_pmkid_flow.md` | WPA2-PSK brute-force |
| `wpa2_enterprise_rogueAP.md` | WPA2-Enterprise Evil Twin attack with `hostapd-mana` + `freeradius` |
| `Captive_Portal` | Rogue access point, DNS/DHCP spoofing, and a fake login page to phish Wi-Fi |


---

## 🧰 Tools in Use

- `aircrack-ng`, `airodump-ng`, `aireplay-ng`
- `wpa_supplicant`
- `hostapd-mana`, `freeradius`
- `iw`, `ip`, `dhclient`
- `tshark`, `Wireshark`
- `DNS/DHCP spoofing`
- `HTML + php`

All CLI. All tested.  
Most run fine over SSH if you like to break things from a distance.

---

## 🧪 Attack Philosophy

- Manual attacks only  
- No magic scripts  
- Start from `.pcap`, end with creds or keys  
- Emphasis on **understanding every packet**

---

## ⚠️ Notes & Crediz!

All techniques tested in **controlled environments**.
What controlled env? https://lab.wifichallenge.com/

---

## ❤️ Author

Crafted by [@DamBasement](https://github.com/DamBasement)  
Built in frustration, refined by obsession.

---
