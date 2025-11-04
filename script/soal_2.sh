# 1) Konfigurasi DHCP Server (Aldarion)
# Instalasi paket DHCP Server:
apt-get update
apt-get install -y isc-dhcp-server

# Konfigurasi interface DHCP:
nano /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""

# Konfigurasi utama DHCP:
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

# Restart DHCP Server:
service isc-dhcp-server restart

############################################################
# 2) Konfigurasi DHCP Relay (Durin)
# Instalasi paket:
apt-get install -y isc-dhcp-relay

# File konfigurasi:
nano /etc/default/isc-dhcp-relay
SERVERS="192.214.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""

# Restart relay:
service isc-dhcp-relay restart

############################################################
# 3) Konfigurasi Client Dinamis dan Fixed (Amandil, Gilgalad, Khamul)
nano /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
#Hapus semua baris address, netmask, dan gateway.

#Jika DHCP client belum otomatis aktif, jalankan (jika tersedia):
dhclient -r eth0 && dhclient eth0

#############################################################
# Pengujian
ip a show eth0
ip route show

