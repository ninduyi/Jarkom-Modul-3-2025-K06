# === Aldarion — DHCP Server ===
# 1) Install & set interface
apt-get update
apt-get install -y isc-dhcp-server
sed -i 's/^INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

# 2) Konfigurasi dhcpd.conf (persis sesuai soal: 2 rentang per keluarga)
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak.$(date +%s)

cat > /etc/dhcp/dhcpd.conf <<'EOF'
authoritative;
default-lease-time 600;
max-lease-time 3600;

# resolver sementara (fase awal modul)
option domain-name-servers 192.168.122.1;

# MANUSIA (192.214.1.0/24) — dua rentang
subnet 192.214.1.0 netmask 255.255.255.0 {
  option routers 192.214.1.1;
  range 192.214.1.6 192.214.1.34;
  range 192.214.1.68 192.214.1.94;
}

# PERI (192.214.2.0/24) — dua rentang
subnet 192.214.2.0 netmask 255.255.255.0 {
  option routers 192.214.2.1;
  range 192.214.2.35 192.214.2.67;
  range 192.214.2.96 192.214.2.121;
}

# Deklarasi subnet lain tanpa pool (biar dhcpd paham topologi)
subnet 192.214.3.0 netmask 255.255.255.0 { option routers 192.214.3.1; }
subnet 192.214.4.0 netmask 255.255.255.0 { option routers 192.214.4.1; }
subnet 192.214.5.0 netmask 255.255.255.252 { option routers 192.214.5.1; }
EOF

# 3) Start dhcpd “bersih”
dhcpd -t -4 -cf /etc/dhcp/dhcpd.conf        # test config → harus tanpa error
pkill dhcpd 2>/dev/null
cp /var/lib/dhcp/dhcpd.leases /var/lib/dhcp/dhcpd.leases.bak 2>/dev/null || true
: > /var/lib/dhcp/dhcpd.leases
dhcpd -4 -q -cf /etc/dhcp/dhcpd.conf -pf /run/dhcpd.pid eth0 &

# verifikasi server aktif & listen UDP 67
ps aux | grep [d]hcpd
ss -lunp | grep ':67 '

# Yang seharusnya terlihat (contoh)
- dhcpd -t: tidak ada baris “error”.
- ps aux: ada proses dhcpd ... eth0.
- ss -lunp: 0.0.0.0:67 users:(("dhcpd",pid=...)).




# ====== B) Durin — DHCP Relay → Aldarion  ======
#1) Install & set relay
apt-get update && apt-get install -y isc-dhcp-relay

sed -i 's/^SERVERS=.*/SERVERS="192.214.4.2"/' /etc/default/isc-dhcp-relay
sed -i 's/^INTERFACES=.*/INTERFACES="eth1 eth2 eth3 eth4 eth5"/' /etc/default/isc-dhcp-relay
sed -i 's/^OPTIONS=.*/OPTIONS=""/' /etc/default/isc-dhcp-relay

# 2) Start relay (tanpa systemd) & cek
(/etc/init.d/isc-dhcp-relay start || service isc-dhcp-relay start) 2>/dev/null || \
dhcrelay -4 -i eth1 -i eth2 -i eth3 -i eth4 -i eth5 192.214.4.2 &

ps aux | grep -E '[d]hcrelay|[i]sc-dhcp-relay'
ss -lunp | egrep ':67 |:68 '

# Yang seharusnya terlihat (contoh)
- Proses dhcrelay -i eth1 -i eth2 -i eth3 -i eth4 -i eth5 192.214.4.2 berjalan.
- ss -lunp menunjukkan listener UDP 67 oleh dhcrelay.



# ======== C) Klien Dinamis — Amandil & Gilgalad ========
# 1) Amandil (keluarga Manusia)
# mode DHCP murni
printf "auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces

ip addr flush dev eth0
rm -f /var/lib/dhcp/dhclient*.leases 2>/dev/null

# minta IP (tampilkan transaksi)
dhclient -v -r eth0
dhclient -v eth0

# Cara cek + hasil yang diharapkan
ip a show dev eth0
ip r | head -n1
cat /etc/resolv.conf
ping -c 3 1.1.1.1
ping -4 -c 3 debian.org


# Seharusnya: Output dhclient -v mengandung:

DHCPDISCOVER ...
DHCPOFFER of 192.214.1.X from 192.214.1.1
DHCPACK of 192.214.1.X from 192.214.1.1
bound to 192.214.1.X

- X berada di 1.6–1.34 atau 1.68–1.94.
- ip r: default via 192.214.1.1.
- /etc/resolv.conf: nameserver 192.168.122.1.
- Ping IP publik & DNS (IPv4) sukses.

# 2) Gilgalad (keluarga Peri)
# mode DHCP murni
printf "auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp\n" > /etc/network/interfaces

ip addr flush dev eth0
rm -f /var/lib/dhcp/dhclient*.leases 2>/dev/null

dhclient -v -r eth0
dhclient -v eth0

# Cara cek + hasil yang diharapkan
ip a show dev eth0
ip r | head -n1
cat /etc/resolv.conf
ping -c 3 1.1.1.1
ping -4 -c 3 debian.org


# Seharusnya: 
- Output dhclient -v mengandung OFFER/ACK.
- IP 192.214.2.Y dan Y berada di 2.35–2.67 atau 2.96–2.121.
- default via 192.214.2.1.
- DNS & internet jalan.