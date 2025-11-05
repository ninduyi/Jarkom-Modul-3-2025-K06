# durin

auto eth0
iface eth0 inet dhcp
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.214.0.0/16

auto eth1
iface eth1 inet static
address 192.214.1.1
netmask 255.255.255.0

auto eth2
iface eth2 inet static
address 192.214.2.1
netmask 255.255.255.0

auto eth3
iface eth3 inet static
address 192.214.3.1
netmask 255.255.255.0

auto eth4
iface eth4 inet static
address 192.214.4.1
netmask 255.255.255.0

auto eth5
iface eth5 inet static
address 192.214.5.1
netmask 255.255.255.0

# elendil
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# isildur
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# anarion
auto eth0
iface eth0 inet static
    address 192.214.1.4
    netmask 255.255.255.0
    gateway 192.214.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# miriel
auto eth0
iface eth0 inet static
    address 192.214.1.5
    netmask 255.255.255.0
    gateway 192.214.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# amandil
auto eth0
iface eth0 inet static
    address 192.214.1.6
    netmask 255.255.255.0
    gateway 192.214.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# elros
auto eth0
iface eth0 inet static
    address 192.214.1.7
    netmask 255.255.255.0
    gateway 192.214.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# khamul
auto eth0
iface eth0 inet static
    address 192.214.3.2
    netmask 255.255.255.0
    gateway 192.214.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# erendis
auto eth0
iface eth0 inet static
    address 192.214.3.3
    netmask 255.255.255.0
    gateway 192.214.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# amdir
auto eth0
iface eth0 inet static
    address 192.214.3.4
    netmask 255.255.255.0
    gateway 192.214.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf



# aldarion
auto eth0
iface eth0 inet static
    address 192.214.4.2
    netmask 255.255.255.0
    gateway 192.214.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# palantir
auto eth0
iface eth0 inet static
    address 192.214.4.3
    netmask 255.255.255.0
    gateway 192.214.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# narvi
auto eth0
iface eth0 inet static
    address 192.214.4.4
    netmask 255.255.255.0
    gateway 192.214.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# minastir
auto eth0
iface eth0 inet static
    address 192.214.5.2
    netmask 255.255.255.0
    gateway 192.214.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# gilgalad
auto eth0
iface eth0 inet static
    address 192.214.2.2
    netmask 255.255.255.0
    gateway 192.214.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# celebrimor
auto eth0
iface eth0 inet static
    address 192.214.2.3
    netmask 255.255.255.0
    gateway 192.214.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# pharazon
auto eth0
iface eth0 inet static
    address 192.214.2.4
    netmask 255.255.255.0
    gateway 192.214.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# galadriel
auto eth0
iface eth0 inet static
    address 192.214.2.5
    netmask 255.255.255.0
    gateway 192.214.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# celeborn
auto eth0
iface eth0 inet static
    address 192.214.2.6
    netmask 255.255.255.0
    gateway 192.214.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# oropher
auto eth0
iface eth0 inet static
    address 192.214.2.7
    netmask 255.255.255.0
    gateway 192.214.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf


############################################################
# Cek ping google
# Cek elendil ke isildur
ping 192.214.1.3 -c 3

# Elendil ke Galadriel
# Dari Elendil (192.214.1.2)
ping 192.214.2.5 -c 3
