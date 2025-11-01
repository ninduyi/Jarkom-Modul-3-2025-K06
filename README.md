# Praktikum Komunikasi Data dan Jaringan Komputer Modul 3 - K06

## Anggota Kelompok
| NRP | Nama |
|---|---|
| 5027241006 | Nabilah Anindya Paramesti |
| 5027241041 | Raya Ahmad Syarif |

---

## Daftar Isi
- [Soal 1](#soal-1)
- [Soal 2](#soal-2)
- [Soal 3](#soal-3)
- [Soal 4](#soal-4)
- [Soal 5](#soal-5)
- [Soal 6](#soal-6)
- [Soal 7](#soal-7)
- [Soal 8](#soal-8)
- [Soal 9](#soal-9)
- [Soal 10](#soal-10)
---

## Soal 1 
Di awal Zaman Kedua, setelah kehancuran Beleriand, para Valar menugaskan untuk membangun kembali jaringan komunikasi antar kerajaan. Para Valar menyalakan Minastir, Aldarion, Erendis, Amdir, Palantir, Narvi, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher, Miriel, Amandil, Gilgalad, Celebrimbor, Khamul, dan pastikan setiap node (selain Durin sang penghubung antar dunia) dapat sementara berkomunikasi dengan Valinor/Internet (nameserver 192.168.122.1) untuk menerima instruksi awal.

## Soal 2
**Target:** Aldarion bertindak sebagai **DHCP Server**, Durin sebagai **DHCP Relay**, sehingga klien **Amandil** (Manusia) dan **Gilgalad** (Peri) otomatis mendapat IP dalam **rentang yang diwajibkan soal**.
- **Manusia:** `192.214.1.6–1.34` dan `192.214.1.68–1.94`  
- **Peri:** `192.214.2.35–2.67` dan `192.214.2.96–2.121`

### Langkah
**A. Aldarion — DHCP Server**
```bash
apt-get update
apt-get install -y isc-dhcp-server
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

cat > /etc/dhcp/dhcpd.conf <<'EOF'
authoritative;
default-lease-time 600;
max-lease-time 3600;
option domain-name-servers 192.168.122.1;

subnet 192.214.1.0 netmask 255.255.255.0 {
  option routers 192.214.1.1;
  range 192.214.1.6 192.214.1.34;
  range 192.214.1.68 192.214.1.94;
}

subnet 192.214.2.0 netmask 255.255.255.0 {
  option routers 192.214.2.1;
  range 192.214.2.35 192.214.2.67;
  range 192.214.2.96 192.214.2.121;
}

subnet 192.214.3.0 netmask 255.255.255.0 { option routers 192.214.3.1; }
subnet 192.214.4.0 netmask 255.255.255.0 { option routers 192.214.4.1; }
subnet 192.214.5.0 netmask 255.255.255.252 { option routers 192.214.5.1; }
EOF

dhcpd -t -4 -cf /etc/dhcp/dhcpd.conf
pkill dhcpd 2>/dev/null
: > /var/lib/dhcp/dhcpd.leases
dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf -pf /run/dhcpd.pid eth0 &

# verifikasi
ps aux | grep [d]hcpd
ss -lunp | grep ':67 '
```

**B. Durin — DHCP Relay**
```bash
apt-get update && apt-get install -y isc-dhcp-relay
sed -i 's/^SERVERS=.*/SERVERS="192.214.4.2"/' /etc/default/isc-dhcp-relay
sed -i 's/^INTERFACES=.*/INTERFACES="eth1 eth2 eth3 eth4 eth5"/' /etc/default/isc-dhcp-relay
sed -i 's/^OPTIONS=.*/OPTIONS=""/' /etc/default/isc-dhcp-relay

(/etc/init.d/isc-dhcp-relay start || service isc-dhcp-relay start) 2>/dev/null || \
dhcrelay -4 -q -i eth1 -i eth2 -i eth3 -i eth4 -i eth5 192.214.4.2 &

# verifikasi
ps aux | grep -E '[d]hcrelay|[i]sc-dhcp-relay'
ss -lunp | egrep ':67 |:68 '
ip a show eth1   # harus UP dan 192.214.1.1/24
```

**C. Klien Dinamis — Amandil & Gilgalad (mode DHCP)**
- **Amandil (Manusia)**
  ```bash
  printf "auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces
  ip addr flush dev eth0
  rm -f /var/lib/dhcp/dhclient*.leases 2>/dev/null
  dhclient -v -r eth0
  dhclient -v eth0
  ```
- **Gilgalad (Peri)**
  ```bash
  printf "auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces
  ip addr flush dev eth0
  rm -f /var/lib/dhcp/dhclient*.leases 2>/dev/null
  dhclient -v -r eth0
  dhclient -v eth0
  ```

### Cara Cek & Hasil yang Diharapkan
**Di Amandil (Manusia)**
```bash
# Log transaksi DHCP (harus ada OFFER & ACK)
dhclient -v -r eth0
dhclient -v eth0
# IP, route, DNS, konektivitas
ip a show dev eth0
ip r | head -n1
cat /etc/resolv.conf
ping -c 3 1.1.1.1
ping -4 -c 3 debian.org
```
**Contoh output nyata kami:**
```
DHCPOFFER of 192.214.1.7 from 192.214.1.1
DHCPACK of 192.214.1.7 from 192.214.1.1
bound to 192.214.1.7
default via 192.214.1.1 dev eth0
nameserver 192.168.122.1
PING 1.1.1.1 ... 0% packet loss
PING debian.org ... 0% packet loss
```
→ **Valid** karena `192.214.1.7 ∈ [1.6–1.34]` (pool Manusia).

**Di Gilgalad (Peri)**
```bash
dhclient -v -r eth0
dhclient -v eth0
ip a show dev eth0
ip r | head -n1
cat /etc/resolv.conf
ping -c 3 1.1.1.1
ping -4 -c 3 debian.org
```
**Contoh output nyata kami:**
```
DHCPOFFER of 192.214.2.35 from 192.214.2.1
DHCPACK of 192.214.2.35 from 192.214.2.1
bound to 192.214.2.35
default via 192.214.2.1 dev eth0
nameserver 192.168.122.1
PING 1.1.1.1 ... 0% packet loss
PING debian.org ... 0% packet loss
```
→ **Valid** karena `192.214.2.35 ∈ [2.35–2.67]` (pool Peri).

**Tambahan (Server — Aldarion)**
```bash
tail -n 100 /var/lib/dhcp/dhcpd.leases
```
**Cuplikan hasil nyata kami:**
```text
lease 192.214.1.7 { ... binding state active; client-hostname "Amandil"; ... }
lease 192.214.2.35 { ... binding state active; client-hostname "Gilgalad"; ... }
```

### Dokumentasi
- **Amandil** menerima IP **192.214.1.7** (pool Manusia), **default via 192.214.1.1**, DNS `192.168.122.1`, konektivitas Internet & DNS **sukses**.
- **Gilgalad** menerima IP **192.214.2.35** (pool Peri), **default via 192.214.2.1**, DNS `192.168.122.1`, konektivitas Internet & DNS **sukses**.
- **Aldarion** mencatat kedua lease di `dhcpd.leases` (status **active**).

---