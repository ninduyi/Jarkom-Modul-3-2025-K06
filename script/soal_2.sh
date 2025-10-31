## 🎯 Tujuan  
Membuat sistem **DHCP Server** (Aldarion) yang melayani beberapa subnet melalui **DHCP Relay** (Durin), sehingga **klien** (Amandil dan Gilgalad) mendapat IP otomatis tanpa konfigurasi manual.

---

## ⚙️ Langkah Konfigurasi

### 🖥️ 1. Aldarion – DHCP Server

#### 🔹 Instalasi
```bash
apt-get update
apt-get install -y isc-dhcp-server
```
#### 🔹 Konfigurasi DHCP Server
``bash
nano /etc/dhcp/dhcpd.conf
```
Tambahkan konfigurasi berikut:
```conf
# Subnet untuk jaringan Manusia
subnet 192.214.1.0 netmask 255.255.255.0 {
    range 192.214.1.50 192.214.1.100;
    option routers 192.214.1.1;
    option broadcast-address 192.214.1.255;
    option domain-name-servers 192.168.122.1;
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet untuk jaringan Peri
subnet 192.214.2.0 netmask 255.255.255.0 {
    range 192.214.2.50 192.214.2.100;
    option routers 192.214.2.1;
    option broadcast-address 192.214.2.255;
    option domain-name-servers 192.168.122.1;
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet langsung terhubung dengan Durin
subnet 192.214.4.0 netmask 255.255.255.0 {
    option routers 192.214.4.1;
}
```

#### Persiapan File Lease
```bash
mkdir -p /var/lib/dhcp
touch /var/lib/dhcp/dhcpd.leases
```

#### Jalankan DHCP Server
```bash
    dhcpd -t -4 -cf /etc/dhcp/dhcpd.conf
    dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf eth0 &
```

#### Verifikasi
```bash
    ps aux | grep dhcpd
    ss -lunp | grep ':67'
````

# Durin – DHCP Relay
#### 🔹 Instalasi
```bash
apt-get install -y isc-dhcp-relay
```

#### Jalankan DHCP Relay
```bash
dhcrelay -4 -i eth1 -i eth2 -i eth3 -i eth4 -i eth5 192.214.4.2 &
```
Pastikan 192.214.4.2 adalah IP Aldarion, dan eth1–eth5 adalah interface LAN yang terhubung ke subnet klien.

#### Verifikasi
```bash
ps aux | grep dhcrelay
ss -lunp | grep ':67'
```

# Amandil & Gilgalad – DHCP Client
#### Instalasi DHCP Client
```bash
apt-get install -y isc-dhcp-client
```

#### Meminta IP Otomatis
```bash
dhclient -v -r eth0 && dhclient -v eth0
```

#### Verifikasi IP
```bash
ip a | grep 192.214.
ip r | head -n 1
cat /etc/resolv.conf
```

# Pengujian
### Cek IP Klien
```bash
ip a | grep 192.214
```
### ping Gateway
```bash
ping -c 3 192.214.1.1
```
#### Ping ke Internet (melalui Durin NAT)
```bash
ping -c 3 deb.debian.org
````

#### CEK DNS
```bash
cat /etc/resolv.conf
```