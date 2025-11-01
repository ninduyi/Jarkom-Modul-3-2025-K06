#!/bin/sh
# SOAL 3 — Kontrol arus informasi via MINASTIR (DNS Forwarder)
# Gunakan file ini sebagai CHECKLIST. Jalankan SETIAP BARIS di node yang disebut.
# Asumsi: Soal 1 (routing+NAT Durin) dan Soal 2 (DHCP Server+Relay) SUDAH OK.
# IP penting:
#   Minastir = 192.214.5.2
#   Durin WAN = 192.168.122.2   (WAN network 192.168.122.0/24)
#   DNS upstream lab = 192.168.122.1

############################################################
# 1) MINASTIR — JADIKAN DNS FORWARDER (UNBOUND)
############################################################

# [Minastir] Install unbound
apt-get update
apt-get install -y unbound

# [Minastir] Backup config (opsional)
cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.bak 2>/dev/null || true

# [Minastir] Tulis konfigurasi forwarder
cat > /etc/unbound/unbound.conf <<'EOF'
server:
  interface: 0.0.0.0
  access-control: 192.214.0.0/16 allow
  verbosity: 1
  hide-identity: yes
  hide-version: yes
forward-zone:
  name: "."
  forward-addr: 192.168.122.1
EOF

# [Minastir] Jalankan unbound (tanpa systemd)
pkill unbound 2>/dev/null || true
unbound -d -c /etc/unbound/unbound.conf >/var/log/unbound.log 2>&1 &
sleep 1

# [Minastir] CEK: service & resolusi
ss -lunp | grep ':53 '
dig +short -4 debian.org @127.0.0.1


############################################################
# 2) ALDARION — DHCP ARAHKAN DNS KLIEN → MINASTIR
############################################################

# [Aldarion] Ubah option DNS global
sed -i 's/^option domain-name-servers .*/option domain-name-servers 192.214.5.2;/' /etc/dhcp/dhcpd.conf

# [Aldarion] Uji sintaks DHCP
dhcpd -t -4 -cf /etc/dhcp/dhcpd.conf

# [Aldarion] Pastikan file lease ada
test -f /var/lib/dhcp/dhcpd.leases || install -m 644 -o root -g root /dev/null /var/lib/dhcp/dhcpd.leases

# [Aldarion] Restart dhcpd (tanpa systemd)
pkill dhcpd 2>/dev/null
dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf -pf /run/dhcpd.pid eth0 &
sleep 1

# [Aldarion] CEK: proses & port
ps aux | grep '[d]hcpd'
ss -lunp | grep ':67 '


############################################################
# 3) DURIN — IPTABLES: PAKSA SEMUA DNS LEWAT MINASTIR
############################################################

# [Durin] Variabel cepat
MINASTIR=192.214.5.2
UPSTREAM=192.168.122.0/24

# [Durin] Hapus DROP yang terlalu luas (abaikan error jika tidak ada)
iptables -D FORWARD ! -s $MINASTIR -p udp --dport 53 -j DROP 2>/dev/null || true
iptables -D FORWARD ! -s $MINASTIR -p tcp --dport 53 -j DROP 2>/dev/null || true

# [Durin] IZINKAN: klien → Minastir (DNS)
iptables -I FORWARD 1 -d $MINASTIR -p udp --dport 53 -j ACCEPT
iptables -I FORWARD 2 -d $MINASTIR -p tcp --dport 53 -j ACCEPT

# [Durin] IZINKAN: Minastir → upstream (DNS)
iptables -C FORWARD -s $MINASTIR -p udp --dport 53 -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -s $MINASTIR -p udp --dport 53 -j ACCEPT
iptables -C FORWARD -s $MINASTIR -p tcp --dport 53 -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -s $MINASTIR -p tcp --dport 53 -j ACCEPT

# [Durin] BLOKIR: klien bypass DNS langsung ke WAN
iptables -C FORWARD ! -s $MINASTIR -d $UPSTREAM -p udp --dport 53 -j DROP 2>/dev/null || \
iptables -A FORWARD ! -s $MINASTIR -d $UPSTREAM -p udp --dport 53 -j DROP
iptables -C FORWARD ! -s $MINASTIR -d $UPSTREAM -p tcp --dport 53 -j DROP 2>/dev/null || \
iptables -A FORWARD ! -s $MINASTIR -d $UPSTREAM -p tcp --dport 53 -j DROP

# [Durin] CEK aturan aktif
iptables -S FORWARD | nl


############################################################
# 4) KLIEN — RENEW DHCP & VERIFIKASI (AMANDIL & GILGALAD)
############################################################

# [Klien] Renew DHCP (pastikan iface eth0 mode dhcp)
ip addr flush dev eth0
rm -f /var/lib/dhcp/dhclient*.leases 2>/dev/null
dhclient -v -r eth0
dhclient -v eth0

# [Klien] CEK: resolver harus 192.214.5.2
cat /etc/resolv.conf

# [Klien] CEK: konektivitas via DNS Minastir
ping -4 -c 3 debian.org


############################################################
# 5) OPSIONAL — UJI BYPASS (BUKTI WAJIB LEWAT MINASTIR)
############################################################

# [Klien] Paksa resolver ke 192.168.122.1 → seharusnya GAGAL (diblok Durin)
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf
ping -4 -c 3 debian.org

# [Klien] Kembalikan ke Minastir → sukses lagi
printf "nameserver 192.214.5.2\n" > /etc/resolv.conf
ping -4 -c 3 debian.org

# — SELESAI —
# Soal 3 dianggap LULUS jika:
#  - Minastir listen :53 dan resolve OK
#  - Klien menerima nameserver 192.214.5.2 dari DHCP
#  - Durin mengizinkan DNS klien→Minastir & Minastir→upstream, serta memblok bypass
#  - Klien bisa ping domain saat pakai Minastir, dan gagal saat bypass resolver WAN
