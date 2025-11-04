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

### Topologi
![](/assets/1-topologi.png)

### Pengerjaan
1. Konfigurasi Interface:
- eth0: Interface ini terhubung ke NAT1 (Internet/Valinor). Kita mengaturnya sebagai dhcp agar mendapatkan IP secara otomatis dari jaringan GNS3.
- eth1 - eth5: Interface ini terhubung ke switch di masing-masing jaringan internal. Kita mengaturnya dengan IP statis yang akan berfungsi sebagai gateway untuk semua node di subnet tersebut.

  - eth1: 192.214.1.1 (Jaringan Numenor - Workers)
  - eth2: 192.214.2.1 (Jaringan Elf - Workers)
  - eth3: 192.214.3.1 (Jaringan Numenor - Services)
  - eth4: 192.214.4.1 (Jaringan Numenor - Database)
  - eth5: 192.214.5.1 (Jaringan Numenor - DNS Forwarder)
2. Konfigurasi NAT (Masquerade): Kita menambahkan aturan iptables agar semua trafik dari jaringan internal (192.214.0.0/16) yang keluar melalui eth0 (internet) akan "disamarkan" menggunakan IP eth0 milik Durin.
```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.214.0.0/16
```
3. Pengaturan DNS Sementara (Sesuai Soal 1): Untuk memungkinkan node berkomunikasi dengan Valinor/Internet (misalnya, untuk apt-get update), kita perlu mengatur resolver DNS sementara. Sesuai soal dan prasyarat, kita menggunakan 192.168.122.1.
- Kita menggunakan perintah `up echo nameserver 192.168.122.1 > /etc/resolv.conf` pada setiap konfigurasi interface node. Ini akan secara otomatis menulis file /etc/resolv.conf setiap kali interface eth0 aktif.

### Pengecekan
**1. Cek Durin**
![](/assets/1-cekdurin.png)
**2. Cek node lain**
![](/assets/1-cekclient.png)

## Soal 2
Raja Pelaut **Aldarion** memutuskan pembagian alamat IP secara dinamis untuk para client. 
Ketentuannya sebagai berikut:

- **Client Keluarga Manusia (subnet 1)** → 192.214.1.6 – 192.214.1.34 dan 192.214.1.68 – 192.214.1.94  
- **Client Keluarga Peri (subnet 2)** → 192.214.2.35 – 192.214.2.67 dan 192.214.2.96 – 192.214.2.121  
- **Khamul (subnet 3)** → alamat tetap 192.214.3.95  

DHCP Server dijalankan pada **Aldarion**, dengan **Durin** sebagai DHCP Relay. 
Seluruh client pada subnet 1, 2, dan 3 harus memperoleh IP sesuai rentang yang ditentukan.

---

## Pengerjaan

### 1. Konfigurasi DHCP Server (Aldarion)

**File:** `/etc/network/interfaces`
```bash
auto eth0
iface eth0 inet static
    address 192.214.4.2
    netmask 255.255.255.0
    gateway 192.214.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```

**Instalasi paket DHCP Server:**
```bash
apt-get update
apt-get install -y isc-dhcp-server
```

**Konfigurasi interface DHCP:**
```
/etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
```

**Konfigurasi utama DHCP:**  
```
/etc/dhcp/dhcpd.conf
default-lease-time 1800;
max-lease-time 3600;
authoritative;

# Subnet manusia
subnet 192.214.1.0 netmask 255.255.255.0 {
    range 192.214.1.6 192.214.1.34;
    range 192.214.1.68 192.214.1.94;
    option routers 192.214.1.1;
    option broadcast-address 192.214.1.255;
    option domain-name-servers 192.168.122.1;
}

# Subnet peri
subnet 192.214.2.0 netmask 255.255.255.0 {
    range 192.214.2.35 192.214.2.67;
    range 192.214.2.96 192.214.2.121;
    option routers 192.214.2.1;
    option broadcast-address 192.214.2.255;
    option domain-name-servers 192.168.122.1;
}

# Subnet khamul (fixed address)
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.168.122.1;
}

# Subnet server
subnet 192.214.4.0 netmask 255.255.255.0 {
    option routers 192.214.4.1;
    option broadcast-address 192.214.4.255;
}

# Subnet tambahan (Durin-Minastir)
subnet 192.214.5.0 netmask 255.255.255.0 {
    option routers 192.214.5.1;
    option broadcast-address 192.214.5.255;
    option domain-name-servers 192.168.122.1;
}

# Fixed address Khamul (gunakan MAC sebenarnya)
host khamul {
    hardware ethernet 02:42:38:a1:28:00;
    fixed-address 192.214.3.95;
}
```

**Restart DHCP Server:**
```bash
service isc-dhcp-server restart
```

---

### 2. Konfigurasi DHCP Relay (Durin)

**Instalasi paket:**
```bash
apt-get install -y isc-dhcp-relay
```

**File konfigurasi:**
```
/etc/default/isc-dhcp-relay
SERVERS="192.214.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""
```

**Restart relay:**
```bash
service isc-dhcp-relay restart
```

---

### 3. Konfigurasi Client Dinamis dan Fixed

Untuk client dinamis dan fixed, gunakan konfigurasi berikut:

**File:** `/etc/network/interfaces`
```bash
auto eth0
iface eth0 inet dhcp
```

Hapus semua baris `address`, `netmask`, dan `gateway`.

**Aktifkan ulang interface:**
```bash
ip addr flush dev eth0
ip link set eth0 down
sleep 2
ip link set eth0 up
```

Jika DHCP client belum otomatis aktif, jalankan (jika tersedia):
```bash
dhclient -r eth0 && dhclient eth0
```

---

## Pengecekan

### 1. Cek IP dan Route Amandil
![](/assets/2-Amandil.png)

### 2. Cek IP dan Route Gilgalad
![](/assets/2-gilgalad.png)

### 3. Cek IP dan Route Khamul
![](/assets/2-khamul.png)

---

## Soal 3
Bangun **Minastir** sebagai penjaga arus informasi ke dunia luar (Valinor/Internet). 
Semua node (kecuali Durin) hanya dapat melakukan resolusi DNS **melalui Minastir**.

---

## Pengerjaan

### 1. Konfigurasi Minastir
#### a. Atur IP
```
auto eth0
iface eth0 inet static
    address 192.214.5.2
    netmask 255.255.255.0
    gateway 192.214.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```

#### b. Instal BIND9
```
apt-get update
apt-get install -y bind9
```

#### c. Konfigurasi Forwarder
Edit `/etc/bind/named.conf.options`:
```
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    recursion yes;
};
```

---

### 2. Atur DNS Klien
Pada semua node **kecuali Durin**:
```
echo "nameserver 192.214.5.2" > /etc/resolv.conf
```
Agar semua query DNS diarahkan ke Minastir.

---

### 3. Enforce DNS via Durin (iptables)
> Langkah opsional tapi direkomendasikan agar seluruh DNS ke internet **harus** lewat Minastir.

Jalankan di **Durin**:

```
# 1) Izinkan Minastir (192.214.5.2) kirim DNS ke mana pun (internal & internet)
iptables -I FORWARD -s 192.214.5.2 -p udp --dport 53 -j ACCEPT
iptables -I FORWARD -s 192.214.5.2 -p tcp --dport 53 -j ACCEPT

# 2) Blok DNS yang menuju internet (keluar via eth0) KECUALI dari Minastir
iptables -I FORWARD -o eth0 -p udp --dport 53 ! -s 192.214.5.2 -j REJECT
iptables -I FORWARD -o eth0 -p tcp --dport 53 ! -s 192.214.5.2 -j REJECT
```

---

## Pengecekan

### A. Dari Klien
```
dig @192.214.5.2 google.com +short
ping -c 3 google.com
```
**Tes gagal (langsung ke DNS luar):**
```
dig @192.168.122.1 google.com +short
```
![](/assets/3-cek1.png)


---

