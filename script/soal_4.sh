# DI ERENDIS
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
\$TTL    604800
@       IN      SOA     ns1.K06.com. root.K06.com. ( 2 604800 86400 2419200 604800 )
@       IN      NS      ns1.K06.com.
@       IN      NS      ns2.K06.com.
ns1     IN      A       192.214.3.3     ; IP Erendis
ns2     IN      A       192.214.3.4     ; IP Amdir
Elendil   IN    A       192.214.1.2     ;
Isildur   IN    A       192.214.1.3     ;
Anarion   IN    A       192.214.1.4     ; (IP Asumsi - perbaikan dari .1.2) [cite: 166]
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


# DI AMDIR
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
service named restart
service named status
echo "--- [Amdir] Selesai. Pastikan 'is running'. ---"
# ----- Selesai Salin Blok untuk AMDIR (Slave) -----


# DI ALDARION
# ----- Mulai Salin Blok untuk ALDARION -----
echo "--- [Aldarion] Memperbarui /etc/dhcp/dhcpd.conf... ---"
sed -i 's/option domain-name-servers 192.214.5.2;/option domain-name-servers 192.214.3.3, 192.214.3.4;/g' /etc/dhcp/dhcpd.conf
echo "--- [Aldarion] Restart server... ---"
service isc-dhcp-server restart
echo "--- [Aldarion] Selesai. ---"
# ----- Selesai Salin Blok untuk ALDARION -----


#Di Client Dinamis (Amandil, Gilgalad, Khamul)
# ----- Mulai Salin Blok untuk CLIENT DINAMIS -----
echo "--- [Client] Memperbarui lease DHCP untuk DNS baru... ---"
dhclient -r eth0 && dhclient eth0
echo "--- [Client] Verifikasi /etc/resolv.conf: ---"
cat /etc/resolv.conf
echo "--- [Client] Selesai. Pastikan nameserver adalah 192.214.3.3 dan 192.214.3.4 ---"
# ----- Selesai Salin Blok untuk CLIENT DINAMIS -----



# Di Elendil, Isildur, Miriel, Palantir, Elros, Pharazon, Galadriel, Celeborn, Oropher, Celebrimbor).
# ----- Mulai Salin Blok untuk CLIENT STATIS -----
echo "--- [Client Statis] Memperbarui /etc/resolv.conf... ---"
cat << EOF > /etc/resolv.conf
nameserver 192.214.3.3
nameserver 192.214.3.4
EOF
echo "--- [Client Statis] Selesai. ---"
# ----- Selesai Salin Blok untuk CLIENT STATIS -----



# VERIFIKASI (MIS Miriel)
# 1. Tes internal
nslookup elros.K06.com

# 2. Tes eksternal (forwarding)
nslookup google.com

# 3. Tes ke slave (Amdir)
nslookup palantir.K06.com 192.214.3.4

