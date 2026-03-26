!/bin/bash

# Prerequisites:
# - Linux system with root access
# - iproute2 package installed
# - net-tools package installed
sudo apt update
sudo apt upgrade -y
sudo apt install iproute2
sudo apt install net-tools


# Create two bridges: br0 and br1
sudo ip link add dev br0 type bridge
sudo ip link add dev br1 type bridge

# Verify bridge creation
sudo ip link show

# Set the bridges up
sudo ip link set dev br0 up
sudo ip link set dev br1 up

# Assign IP addresses to the bridges
sudo ip addr add 10.0.0.1/24 dev br0
sudo ip addr add 11.0.0.1/24 dev br1

# Verify bridge configuration
sudo ip addr show br0
sudo ip addr show br1

# Create network namespaces: ns1, ns2, and router-ns
sudo ip netns add ns1
sudo ip netns add ns2
sudo ip netns add router-ns

# Verify namespace creation
sudo ip netns list

# Create veth pairs to connect namespaces to bridges and router
sudo ip link add veth-ns1 type veth peer name veth-br0-ns1
sudo ip link add veth-ns2 type veth peer name veth-br1-ns2

sudo ip link add veth-r0 type veth peer name veth-br0-r
sudo ip link add veth-r1 type veth peer name veth-br1-r

# Verify veth pair creation
sudo ip link show


# Connect the veth pairs to the respective namespaces and bridges

# ns1 <-> br0
sudo ip link set dev veth-ns1 netns ns1
sudo ip link set dev veth-br0-ns1 master br0

# ns2 <-> br1
sudo ip link set dev veth-ns2 netns ns2
sudo ip link set dev veth-br1-ns2 master br1

# router-ns <-> br0
sudo ip link set dev veth-r0 netns router-ns
sudo ip link set dev veth-br0-r master br0

# router-ns <-> br1
sudo ip link set dev veth-r1 netns router-ns
sudo ip link set dev veth-br1-r master br1

# Verify connections
sudo ip link show

# Set the veth interfaces up in the namespaces and on the bridges
sudo ip netns exec ns1 ip link show
sudo ip netns exec ns2 ip link show
sudo ip netns exec router-ns ip link show

sudo ip link set dev veth-br0-ns1 up
sudo ip link set dev veth-br1-ns2 up
sudo ip link set dev veth-br0-r up
sudo ip link set dev veth-br1-r up

# Verify interface status
sudo ip link show

# Set the loopback interfaces up in the namespaces
sudo ip netns exec ns1 ip link set lo up  
sudo ip netns exec ns2 ip link set lo up  
sudo ip netns exec router-ns ip link set lo up

# Set the veth interfaces up in the namespaces
sudo ip netns exec ns1 ip link set dev veth-ns1 up
sudo ip netns exec ns2 ip link set dev veth-ns2 up
sudo ip netns exec router-ns ip link set dev veth-r0 up
sudo ip netns exec router-ns ip link set dev veth-r1 up

# Verify interface status in namespaces
sudo ip netns exec ns1 ip link show
sudo ip netns exec ns2 ip link show
sudo ip netns exec router-ns ip link show

# Assign IP addresses to the interfaces in the namespaces and set up routing
sudo ip netns exec ns1 ip address add 10.0.0.11/24 dev veth-ns1
sudo ip netns exec ns1 ip route add default via 10.0.0.21

sudo ip netns exec ns2 ip address add 11.0.0.11/24 dev veth-ns2
sudo ip netns exec ns2 ip route add default via 11.0.0.21

sudo ip netns exec router-ns ip address add 10.0.0.21/24 dev veth-r0
sudo ip netns exec router-ns ip address add 11.0.0.21/24 dev veth-r1

# Verify IP address assignment and routing configuration
sudo ip netns exec ns1 route
sudo ip netns exec ns2 route
sudo ip netns exec router-ns route

# Enable IP forwarding in the router namespace
sudo ip netns exec router-ns sysctl -w net.ipv4.ip_forward=1

# Set up iptables rules to allow forwarding between the bridges
sudo iptables --append FORWARD --in-interface br0 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br0 --jump ACCEPT

sudo iptables --append FORWARD --in-interface br1 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br1 --jump ACCEPT

# Verify connectivity by pinging from ns1 to the router and from ns2 to the router
sudo ip netns exec ns1 ping 10.0.0.1

sudo ip netns exec ns2 ping 11.0.0.1

sudo ip netns exec ns1 ping -c 3 11.0.0.11

sudo ip netns exec ns2 ping -c 3 10.0.0.11

# Cleanup: Delete the namespaces, bridges, and veth pairs
sudo ip netns del ns1
sudo ip netns del ns2
sudo ip netns del router-ns
sudo ip link del br0
sudo ip link del br1

# Verify cleanup
sudo ip netns list
sudo ip link show
