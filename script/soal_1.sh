# CONFIG NODE

# ============== Durin =================
auto lo
iface lo inet loopback

# ke NAT/internet
auto eth0
iface eth0 inet static
    address 192.168.122.2
    netmask 255.255.255.0
    gateway 192.168.122.1

# Manusia
auto eth1
iface eth1 inet static
    address 192.214.1.1
    netmask 255.255.255.0

# Peri
auto eth2
iface eth2 inet static
    address 192.214.2.1
    netmask 255.255.255.0

# DNS
auto eth3
iface eth3 inet static
    address 192.214.3.1
    netmask 255.255.255.0

# Infra
auto eth4
iface eth4 inet static
    address 192.214.4.1
    netmask 255.255.255.0

# Link ke Minastir (/30)
auto eth5
iface eth5 inet static
    address 192.214.5.1
    netmask 255.255.255.252

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# Aktifkan IP forwarding + NAT
# forwarding on (runtime + permanent)
echo 1 > /proc/sys/net/ipv4/ip_forward
printf "net.ipv4.ip_forward=1\n" > /etc/sysctl.d/99-ipforward.conf
sysctl --system

# NAT keluar via eth0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# (opsional) izinkan FORWARD (biar tidak ketahan policy)
iptables -P FORWARD ACCEPT

# ============== MANUSIA {GW = 192.214.1.1} =================
# ELENDIL
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# ISILDUR
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# ANARION
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.1.4
    netmask 255.255.255.0
    gateway 192.214.1.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# ELROS
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.1.5
    netmask 255.255.255.0
    gateway 192.214.1.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# MIRIEL
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.1.200
    netmask 255.255.255.0
    gateway 192.214.1.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# AMANDIL
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.1.201
    netmask 255.255.255.0
    gateway 192.214.1.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# ============== ELF {GW = 192.214.2.1} =================
# GALADRIEL
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.2.2
    netmask 255.255.255.0
    gateway 192.214.2.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# CELEBORN
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.2.3
    netmask 255.255.255.0
    gateway 192.214.2.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# OROPHER
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.2.4
    netmask 255.255.255.0
    gateway 192.214.2.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# PHARAZON
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.2.5
    netmask 255.255.255.0
    gateway 192.214.2.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# CELEBRIMBOR
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.2.200
    netmask 255.255.255.0
    gateway 192.214.2.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# GILGALAD
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.2.201
    netmask 255.255.255.0
    gateway 192.214.2.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# ============== DNS =================
# ERENDIS (DNS MASTER)
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.3.2
    netmask 255.255.255.0
    gateway 192.214.3.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# AMDIR (DNS SLAVE)
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.3.3
    netmask 255.255.255.0
    gateway 192.214.3.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# KHAMUL
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.3.95
    netmask 255.255.255.0
    gateway 192.214.3.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# ============== INFRA =================
# ALDARION
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.4.2
    netmask 255.255.255.0
    gateway 192.214.4.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# PALANTIR
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.4.3
    netmask 255.255.255.0
    gateway 192.214.4.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# NARVI 
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
    address 192.214.4.4
    netmask 255.255.255.0
    gateway 192.214.4.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

# =============== LINK TO MINASTIR =================
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.214.5.2
    netmask 255.255.255.252
    gateway 192.214.5.1

printf "nameserver 192.168.122.1\n" > /etc/resolv.conf
