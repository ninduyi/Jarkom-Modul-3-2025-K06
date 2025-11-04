# DI MINASTIR
apt-get update
apt-get install -y bind9

nano /etc/bind/named.conf.options

options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1; // DNS ITS/internet
    };
    allow-query { any; };
    recursion yes;
};

service named restart

# DI SEMUA NODE KECUALI DI DURIN
echo "nameserver 192.214.5.2" > /etc/resolv.conf

# DI DURIN
# 1) Izinkan Minastir (192.214.5.2) kirim DNS ke mana pun (internal & internet)
iptables -I FORWARD -s 192.214.5.2 -p udp --dport 53 -j ACCEPT 
iptables -I FORWARD -s 192.214.5.2 -p tcp --dport 53 -j ACCEPT
# 2) Blok DNS yang menuju internet (keluar via eth0) KECUALI dari Minastir
iptables -I FORWARD -o eth0 -p udp --dport 53 ! -s 192.214.5.2 -j REJECT 
iptables -I FORWARD -o eth0 -p tcp --dport 53 ! -s 192.214.5.2 -j REJECT