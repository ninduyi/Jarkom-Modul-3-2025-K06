# DI MINASTIR
# ----- Mulai Salin Blok untuk MINASTIR -----
echo "--- [Minastir] Menginstal BIND9... ---"
apt-get update
apt-get install -y bind9

echo "--- [Minastir] Konfigurasi /etc/bind/named.conf.options... ---"
# Mengatur Minastir sebagai DNS Forwarder [cite: 162, 221]
# Meneruskan query ke DNS Valinor/Internet [cite: 154]
# Konfigurasi ini diambil dari file soal_3.sh Anda
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

echo "--- [Minastir] Restart dan cek status BIND9... ---"
service named restart
service named status
echo "--- [Minastir] Selesai. Pastikan status di atas 'is running'. ---"
# ----- Selesai Salin Blok untuk MINASTIR -----

# DI ALDARION
# ----- Mulai Salin Blok untuk ALDARION -----
echo "--- [Aldarion] Memperbarui /etc/dhcp/dhcpd.conf... ---"
# Mengubah 'option domain-name-servers' dari 192.168.122.1
# menjadi 192.214.5.2 (IP Minastir)
sed -i 's/option domain-name-servers 192.168.122.1;/option domain-name-servers 192.214.5.2;/g' /etc/dhcp/dhcpd.conf

echo "--- [Aldarion] Restart dan cek status server... ---"
service isc-dhcp-server restart
service isc-dhcp-server status
echo "--- [Aldarion] Selesai. Pastikan status di atas 'is running'. ---"
# ----- Selesai Salin Blok untuk ALDARION -----

# DI AMANDIL. GILGALAD, KHAMUL
# ----- Mulai Salin Blok untuk CLIENT DINAMIS -----
echo "--- [Client] Memperbarui lease DHCP untuk DNS baru... ---"
dhclient -r eth0 && dhclient eth0

echo "--- [Client] Verifikasi /etc/resolv.conf. Cek 'nameserver' di bawah: ---"
cat /etc/resolv.conf
echo "--- [Client] Selesai. Pastikan nameserver adalah 192.214.5.2 ---"
# ----- Selesai Salin Blok untuk CLIENT DINAMIS -----

# DI SEMUA NODE KECUALI DI DURIN
echo "nameserver 192.214.5.2" > /etc/resolv.conf

############################################################
# coba
dig google.com