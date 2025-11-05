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

Soal 2 meminta konfigurasi **DHCP Server** di **Aldarion** untuk membagikan alamat IP secara dinamis sesuai rentang yang ditentukan, dan **DHCP Relay** di **Durin** untuk meneruskan permintaan DHCP dari berbagai subnet ke server DHCP.

---

### 1. 🖥️ Konfigurasi Aldarion (DHCP Server)

Langkah pertama adalah mengonfigurasi Aldarion sebagai server DHCP.

#### a. Instalasi Paket
Instal paket **isc-dhcp-server**:

```bash
apt-get update
apt-get install -y isc-dhcp-server
```

#### b. Konfigurasi Interface
Edit file `/etc/default/isc-dhcp-server` agar server mendengarkan permintaan di interface **eth0**:

```bash
cat << EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF
```

#### c. Konfigurasi dhcpd.conf
File `/etc/dhcp/dhcpd.conf` diatur untuk menentukan rentang IP tiap subnet dan reservasi alamat tertentu:

```bash
cat << EOF > /etc/dhcp/dhcpd.conf
authoritative;

# Subnet manusia (dilayani via Durin eth1)
subnet 192.214.1.0 netmask 255.255.255.0 {
    range 192.214.1.6 192.214.1.34;
    range 192.214.1.68 192.214.1.94;
    option routers 192.214.1.1;
    option broadcast-address 192.214.1.255;
    option domain-name-servers 192.168.122.1;
}

# Subnet peri (dilayani via Durin eth2)
subnet 192.214.2.0 netmask 255.255.255.0 {
    range 192.214.2.35 192.214.2.67;
    range 192.214.2.96 192.214.2.121;
    option routers 192.214.2.1;
    option broadcast-address 192.214.2.255;
    option domain-name-servers 192.168.122.1;
}

# Subnet khamul (dilayani via Durin eth3)
subnet 192.214.3.0 netmask 255.255.255.0 {
    option routers 192.214.3.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.168.122.1;
}

# Subnet Aldarion sendiri (PENTING agar service mau start)
subnet 192.214.4.0 netmask 255.255.255.0 {
}

# Fixed address Khamul
host khamul {
    hardware ethernet 02:42:38:a1:28:00;
    fixed-address 192.214.3.95;
}
EOF
```

#### d. Restart Service DHCP
Layanan DHCP di-restart untuk menerapkan konfigurasi baru:

```bash
service isc-dhcp-server restart
service isc-dhcp-server status
```

---

### 2. Konfigurasi Durin (DHCP Relay)

Durin berperan sebagai DHCP Relay, meneruskan permintaan DHCP dari setiap subnet ke server Aldarion.

#### a. Instalasi Paket
```bash
apt-get update
apt-get install -y isc-dhcp-relay
```

#### b. Konfigurasi Relay
File `/etc/default/isc-dhcp-relay` disesuaikan:

```bash
cat << EOF > /etc/default/isc-dhcp-relay
SERVERS="192.214.4.2"
INTERFACES="eth1 eth2 eth3 eth4"
OPTIONS=""
EOF
```

#### c. Restart Service
```bash
service isc-dhcp-relay restart
service isc-dhcp-relay status
```

---

### 3. Konfigurasi Client (Amandil, Gilgalad, Khamul)

#### a. Konfigurasi Interface
Setiap client dikonfigurasi agar **eth0** mendapatkan IP secara otomatis melalui DHCP:

```bash
cat << EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF
```

#### b. Memperbarui IP
Lepaskan IP lama dan minta IP baru dari server DHCP:

```bash
ip addr flush dev eth0
dhclient -r eth0 && dhclient eth0
```

#### c. Verifikasi
Cek hasil konfigurasi IP baru:

```bash
ip a show eth0
```

## Pengecekan

**1. Amandil**

![](/assets/2-amandil.png)

**2. Gilgalad**

![](/assets/2-gilgalad.png)

**3. Khamul**

![](/assets/2-khamul.png)

---

## Soal 3
Soal 3 bertujuan untuk mengonfigurasi **Minastir** sebagai satu-satunya *DNS Forwarder* bagi seluruh jaringan. Semua node (kecuali Durin) harus mengirimkan permintaan DNS mereka ke Minastir, yang kemudian akan meneruskannya ke internet (Valinor).

### 1. Konfigurasi Minastir sebagai DNS Forwarder

Langkah pertama adalah menginstal dan mengonfigurasi BIND9 agar Minastir dapat meneruskan seluruh permintaan DNS.

#### a. Instalasi Paket
```bash
apt-get update
apt-get install -y bind9
```

#### b. Konfigurasi `named.conf.options`
File `/etc/bind/named.conf.options` diatur agar Minastir bertindak sebagai DNS forwarder, yang meneruskan permintaan ke DNS eksternal.

```bash
cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    recursion yes;
};
EOF
```

#### c. Restart Layanan
Setelah konfigurasi selesai, restart layanan BIND9 agar perubahan diterapkan.

```bash
service named restart
service named status
```

> Pastikan status layanan menunjukkan **“is running”**. Jika gagal, periksa log error di `/var/log/syslog` atau `/var/log/named/named.log`.

---

### 2. Memperbarui Resolver DNS di Seluruh Jaringan

Setelah Minastir siap, semua node di jaringan perlu diarahkan untuk menggunakan IP Minastir (`192.214.5.2`) sebagai nameserver utama.

#### a. Klien Dinamis (melalui DHCP)

Untuk node dengan alamat IP dinamis (Amandil, Gilgalad, Khamul), konfigurasi DHCP di Aldarion harus diperbarui.

##### i. Perbarui dhcpd.conf di Aldarion
```bash
sed -i 's/option domain-name-servers 192.168.122.1;/option domain-name-servers 192.214.5.2;/g' /etc/dhcp/dhcpd.conf
```

##### ii. Restart DHCP Server
```bash
service isc-dhcp-server restart
```

##### iii. Perbarui Lease di Klien
Di setiap klien dinamis, jalankan perintah berikut untuk melepaskan lease lama dan mendapatkan yang baru:

```bash
dhclient -r eth0 && dhclient eth0
```

---

#### b. Klien Statis

Untuk node dengan alamat IP statis (misalnya Elendil, Miriel, Palantir, Elros, Galadriel, dll.), file `/etc/resolv.conf` harus diubah secara manual agar mengarah ke Minastir.

```bash
echo "nameserver 192.214.5.2" > /etc/resolv.conf
```

> Langkah ini dilakukan di semua node **statis**, kecuali Durin.

---

## Pengecekan

Setelah semua konfigurasi diterapkan, lakukan pengujian untuk memastikan DNS forwarding berfungsi dengan baik.

### Langkah Verifikasi

1. Jalankan perintah berikut di salah satu node client:
   ```bash
   ping google.com
   ```

   ![](/assets/3-cek.png)



---
## Soal 4

### 1. Di Erendis (DNS Master)

Salin-tempel seluruh blok ini ke terminal Erendis.

```bash
# ----- Mulai Salin Blok untuk ERENDIS (Master) -----
echo "--- [Erendis] Menginstal BIND9... ---"
apt-get update
apt-get install -y bind9

echo "--- [Erendis] Konfigurasi /etc/bind/named.conf.options... ---"
cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    allow-query { 192.214.0.0/16; localhost; localnets; };
    allow-recursion { 192.214.0.0/16; localhost; localnets; };
    recursion yes;
    forwarders {
        192.214.5.2; # IP Minastir
    };
    listen-on-v6 { any; };
};
EOF

echo "--- [Erendis] Konfigurasi /etc/bind/named.conf.local... ---"
cat << EOF > /etc/bind/named.conf.local
zone "K06.com" {
    type master;
    file "/etc/bind/db.K06";
    allow-transfer { 192.214.3.4; }; # IP Amdir
};
EOF

echo "--- [Erendis] Membuat file zona /etc/bind/db.K06... ---"
# Asumsi IP Anarion sudah diperbaiki menjadi 192.214.1.4
cat << EOF > /etc/bind/db.K06
$TTL    604800
@       IN      SOA     ns1.K06.com. root.K06.com. ( 2 604800 86400 2419200 604800 )
@       IN      NS      ns1.K06.com.
@       IN      NS      ns2.K06.com.
ns1     IN      A       192.214.3.3     ; IP Erendis
ns2     IN      A       192.214.3.4     ; IP Amdir
Elendil   IN    A       192.214.1.2     ;
Isildur   IN    A       192.214.1.3     ;
Anarion   IN    A       192.214.1.4     ; (IP Asumsi - perbaikan dari .1.2)
Elros     IN    A       192.214.1.7     ;
Galadriel IN    A       192.214.2.5     ;
Celeborn  IN    A       192.214.2.6     ;
Oropher   IN    A       192.214.2.7     ;
Pharazon  IN    A       192.214.2.4     ;
Palantir  IN    A       192.214.4.3     ;
EOF

echo "--- [Erendis] Restart dan cek status BIND9... ---"
service bind9 restart
service bind9 status
echo "--- [Erendis] Selesai. Pastikan 'is running'. ---"
# ----- Selesai Salin Blok untuk ERENDIS (Master) -----
```

---

### 2. Di Amdir (DNS Slave)

Salin-tempel seluruh blok ini ke terminal Amdir.

```bash
# ----- Mulai Salin Blok untuk AMDIR (Slave) -----
echo "--- [Amdir] Menginstal BIND9... ---"
apt-get update
apt-get install -y bind9

echo "--- [Amdir] Konfigurasi /etc/bind/named.conf.options... ---"
cat << EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    allow-query { 192.214.0.0/16; localhost; localnets; };
    allow-recursion { 192.214.0.0/16; localhost; localnets; };
    recursion yes;
    forwarders {
        192.214.5.2; # IP Minastir
    };
    listen-on-v6 { any; };
};
EOF

echo "--- [Amdir] Konfigurasi /etc/bind/named.conf.local... ---"
cat << EOF > /etc/bind/named.conf.local
zone "K06.com" {
    type slave;
    file "db.K06";
    masters { 192.214.3.3; }; # IP Erendis (Master)
};
EOF

echo "--- [Amdir] Restart dan cek status BIND9... ---"
service bind9 restart
service bind9 status
echo "--- [Amdir] Selesai. Pastikan 'is running'. ---"
# ----- Selesai Salin Blok untuk AMDIR (Slave) -----
```

---

### 3. Di Aldarion (DHCP Server)

Salin-tempel blok ini ke Aldarion untuk memperbarui client dinamis.

```bash
# ----- Mulai Salin Blok untuk ALDARION -----
echo "--- [Aldarion] Memperbarui /etc/dhcp/dhcpd.conf... ---"
sed -i 's/option domain-name-servers 192.214.5.2;/option domain-name-servers 192.214.3.3, 192.214.3.4;/g' /etc/dhcp/dhcpd.conf
echo "--- [Aldarion] Restart server... ---"
service isc-dhcp-server restart
echo "--- [Aldarion] Selesai. ---"
# ----- Selesai Salin Blok untuk ALDARION -----
```

---

### 4. Di Client Dinamis (Amandil, Gilgalad, Khamul)

Jalankan blok ini di ketiga node client tersebut.

```bash
# ----- Mulai Salin Blok untuk CLIENT DINAMIS -----
echo "--- [Client] Memperbarui lease DHCP untuk DNS baru... ---"
dhclient -r eth0 && dhclient eth0
echo "--- [Client] Verifikasi /etc/resolv.conf: ---"
cat /etc/resolv.conf
echo "--- [Client] Selesai. Pastikan nameserver adalah 192.214.3.3 dan 192.214.3.4 ---"
# ----- Selesai Salin Blok untuk CLIENT DINAMIS -----
```

---

### 5. Di Semua Node Statis Lainnya

Jalankan blok ini di semua node statis lainnya (Elendil, Isildur, Miriel, Palantir, Elros, Pharazon, Galadriel, Celeborn, Oropher, Celebrimbor).

```bash
# ----- Mulai Salin Blok untuk CLIENT STATIS -----
echo "--- [Client Statis] Memperbarui /etc/resolv.conf... ---"
cat << EOF > /etc/resolv.conf
nameserver 192.214.3.3
nameserver 192.214.3.4
EOF
echo "--- [Client Statis] Selesai. ---"
# ----- Selesai Salin Blok untuk CLIENT STATIS -----
```

---

## Pengecekan

Dari node client (misal Miriel), jalankan perintah berikut untuk memverifikasi konfigurasi:

```bash
# 1. Tes internal
nslookup elros.K06.com

# 2. Tes eksternal (forwarding)
nslookup google.com

# 3. Tes ke slave (Amdir)
nslookup palantir.K06.com 192.214.3.4
```

