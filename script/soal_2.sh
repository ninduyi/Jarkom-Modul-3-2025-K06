# 1) Konfigurasi DHCP Server (Aldarion)
# ----- Mulai Salin Blok untuk ALDARION -----
echo "--- [Aldarion] Menginstal isc-dhcp-server... ---"
apt-get update
apt-get install -y isc-dhcp-server

echo "--- [Aldarion] Konfigurasi /etc/default/isc-dhcp-server... ---"
cat << EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

echo "--- [Aldarion] Konfigurasi /etc/dhcp/dhcpd.conf (Tanpa Lease Time)... ---"
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

# Fixed address Khamul (menggunakan MAC dari soal_2.sh Anda)
host khamul {
    hardware ethernet 02:42:38:a1:28:00;
    fixed-address 192.214.3.95;
}
EOF

echo "--- [Aldarion] Restart dan cek status server... ---"
service isc-dhcp-server restart
service isc-dhcp-server status
echo "--- [Aldarion] Selesai. Pastikan status di atas 'is running'. ---"
# ----- Selesai Salin Blok untuk ALDARION -----

############################################################
# 2) Konfigurasi DHCP Relay (Durin)
# ----- Mulai Salin Blok untuk DURIN -----
echo "--- [Durin] Menginstal isc-dhcp-relay... ---"
apt-get update
apt-get install -y isc-dhcp-relay

echo "--- [Durin] Konfigurasi /etc/default/isc-dhcp-relay (Sesuai Permintaan)... ---"
# Mengatur INTERFACES ke "eth1 eth2 eth3 eth4" sesuai permintaan Anda
cat << EOF > /etc/default/isc-dhcp-relay
SERVERS="192.214.4.2"
INTERFACES="eth1 eth2 eth3 eth4"
OPTIONS=""
EOF

echo "--- [Durin] Restart dan cek status relay... ---"
service isc-dhcp-relay restart
service isc-dhcp-relay status
echo "--- [Durin] Selesai. Pastikan status di atas 'is running'. ---"
# ----- Selesai Salin Blok untuk DURIN -----

#############################################################
# Di amandil gilgalad khamul
# ----- Mulai Salin Blok untuk CLIENT -----
echo "--- [Client] Konfigurasi /etc/network/interfaces... ---"
cat << EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

echo "--- [Client] Menghapus IP lama dan meminta IP baru... ---"
ip addr flush dev eth0
dhclient -r eth0 && dhclient eth0

echo "--- [Client] Verifikasi IP. Cek baris 'inet' di bawah: ---"
ip a show eth0
echo "--- [Client] Selesai. ---"
# ----- Selesai Salin Blok untuk CLIENT -----
