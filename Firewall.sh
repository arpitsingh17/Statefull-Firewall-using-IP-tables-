# This is a firewall script
SERVER_IP="192.168.220.131"
KALI="192.168.220.128"
META="192.168.220.129"

#Setting default policies
iptables --flush
iptables -t mangle --flush
iptables --policy INPUT DROP
iptables --policy OUTPUT ACCEPT
iptables --policy FORWARD DROP

#Accept packets to and from local interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Accept the packets of already connected streams
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#Allow everyone except KALI to connect using SSH
iptables -A INPUT -i eth0 -p tcp -s $KALI -d $SERVER_IP --dport 21 -j DROP
iptables -A INPUT -i eth0 -p tcp -d $SERVER_IP --dport 21 -j ACCEPT

#Allow ICMP to local network but block for others
iptables -A INPUT -i eth0 -p icmp -s 192.168.220.0/24 -j ACCEPT
iptables -A OUTPUT -o eth0 -p icmp -d 192.168.220.0/24 -j REJECT
iptables -A INPUT -i eth0 -p icmp -j REJECT

#Block bad or private ip addresses
iptables -A INPUT -i eth0 -s 0.0.0.0/8 -j DROP
iptables -A INPUT -i eth0 -s 127.0.0.0/8 -j DROP
iptables -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP
iptables -A INPUT -i eth0 -s 172.16.0.0/12 -j DROP
iptables -A INPUT -i eth0 -s 224.0.0.0/3 -j DROP

# Protection against port scanning 
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j REJECT

#Block flag based in Pre-routing
iptables -t mangle -A PREROUTING -i lo -j ACCEPT
iptables -t mangle -A PREROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t mangle -A PREROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

#DDoS attack protection
iptables -A INPUT -p tcp -m connlimit --connlimit-above 20 -j REJECT --reject-with tcp-reset

#SSH brute-force protection 
iptables -A INPUT -p tcp --dport 21 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport 21 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

#Log of the Passed and Dropped Data
iptables -I INPUT 5 -m limit --limit 5/min -j LOG --log-prefix "IPTABLE_LOGGED " --log-level 6 







