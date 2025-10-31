## 🎯 Tujuan  
Membuat sistem **Forward Proxy (Squid)** pada **Minastir** yang akan menjadi penghubung akses internet untuk seluruh klien melalui **Durin** sebagai router/NAT.  
Seluruh koneksi HTTP/HTTPS dari klien hanya diizinkan lewat proxy Minastir (port 8080).

---

## ⚙️ Langkah Konfigurasi

### 🖥️ 1. Minastir – Proxy Server (Squid)

#### 🔹 Instalasi Squid
```bash
apt-get update
apt-get install -y squid
```

#### Backup dan Edit Konfigurasi
```bash
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
nano /etc/squid/squid.conf
```
Tambahkan atau ubah konfigurasi berikut:
```conf
http_port 8080
visible_hostname minastir.k06

# ACL jaringan lokal
acl localnet src 192.214.0.0/16

# Port aman (HTTPS)
acl SSL_ports port 443
acl Safe_ports port 80 443 21 70 210 280 488 591 777 1025-65535
acl CONNECT method CONNECT

# Izin akses untuk jaringan lokal saja
http_access allow localnet
http_access deny all

# Pengaturan cache
cache_mem 64 MB
maximum_object_size 32 MB
cache_dir ufs /var/spool/squid 100 16 256
```

#### Jalankan dan Verifikasi
```bash
systemctl restart squid 2>/dev/null || service squid restart || /etc/init.d/squid restart
ss -ltnp | grep 8080
````

# Durin – Router dan NAT
#### Aktifkan IP Forwarding
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
````
#### Atur Firewall Untuk Akses Proxy Saja
```bash
# Izinkan klien ke proxy Minastir (port 8080)
iptables -A FORWARD -s 192.214.0.0/16 -d 192.214.5.2 -p tcp --dport 8080 -j ACCEPT

# Izinkan Minastir keluar ke internet
iptables -A FORWARD -s 192.214.5.2 -o eth0 -j ACCEPT

# Blokir akses langsung HTTP/HTTPS dari klien
iptables -A FORWARD -s 192.214.0.0/16 -o eth0 -p tcp -m multiport --dports 80,443 -j REJECT

# Izinkan DNS supaya klien bisa resolve domain
iptables -A FORWARD -s 192.214.0.0/16 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s 192.214.0.0/16 -p tcp --dport 53 -j ACCEPT
```

### Simpan Aturan
```bash
apt-get install -y iptables-persistent
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
```

# Amandil & Gilgalad – Klien Proxy
### Atur DNS
```bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
### Tes Tanpa Proxy (Harus Gagal)
```bash
curl -I http://deb.debian.org
curl -I https://example.com
```
### Tes Dengan Proxy (harus berhasil)
```bash
export http_proxy=http://192.214.5.2:8080
export https_proxy=http://192.214.5.2:8080

curl -I http://deb.debian.org
curl -I https://example.com
```
### Set Proxy Permanen
```bash
echo 'http_proxy=http://192.214.5.2:8080'  >> /etc/environment
echo 'https_proxy=http://192.214.5.2:8080' >> /etc/environment
````
### Atur Proxy Untuk APT
```bash
cat > /etc/apt/apt.conf.d/80proxy <<'EOF'
Acquire::http::Proxy "http://192.214.5.2:8080";
Acquire::https::Proxy "http://192.214.5.2:8080";
EOF
```
### Pengujian
```
curl -I http://deb.debian.org        # Harus gagal tanpa proxy
curl -I -x 192.214.5.2:8080 http://deb.debian.org  # Harus berhasil
```