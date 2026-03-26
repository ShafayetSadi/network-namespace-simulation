#!/bin/bash

echo "Welcome to the Linux Network Namespace Simulation Script!"

echo "Checking for required tools: iproute2 and iptables..."
command -v ip >/dev/null || { echo "iproute2 is missing"; exit 1; }
command -v iptables >/dev/null || { echo "iptables is missing"; exit 1; }

# Create two bridges: br0 and br1
echo "Creating bridges br0 and br1..."
sudo ip link add dev br0 type bridge
sudo ip link add dev br1 type bridge
echo

# Verify bridge creation
echo "Verifying bridge creation..."
sudo ip link show
echo

# Set the bridges up
echo "Setting bridges up..."
sudo ip link set dev br0 up
sudo ip link set dev br1 up
echo

# Assign IP addresses to the bridges
echo "Assigning IP addresses to bridges..."
sudo ip addr add 10.0.0.1/24 dev br0
sudo ip addr add 11.0.0.1/24 dev br1
echo

# Verify bridge configuration
echo "Verifying bridge configuration..."
sudo ip addr show br0
sudo ip addr show br1
echo

# Create network namespaces: ns1, ns2, and router-ns
echo "Creating network namespaces..."
sudo ip netns add ns1
sudo ip netns add ns2
sudo ip netns add router-ns
echo

# Verify namespace creation
echo "Verifying namespace creation..."
sudo ip netns list
echo

# Create veth pairs to connect namespaces to bridges and router
echo "Creating veth pairs..."
sudo ip link add veth-ns1 type veth peer name veth-br0-ns1
sudo ip link add veth-ns2 type veth peer name veth-br1-ns2

sudo ip link add veth-r0 type veth peer name veth-br0-r
sudo ip link add veth-r1 type veth peer name veth-br1-r
echo

# Verify veth pair creation
echo "Verifying veth pair creation..."
sudo ip link show
echo


# Connect the veth pairs to the respective namespaces and bridges
echo "Connecting veth pairs to namespaces and bridges..."
echo

# ns1 <-> br0
echo "Connecting ns1 to br0..."
sudo ip link set dev veth-ns1 netns ns1
sudo ip link set dev veth-br0-ns1 master br0
echo

# ns2 <-> br1
echo "Connecting ns2 to br1..."
sudo ip link set dev veth-ns2 netns ns2
sudo ip link set dev veth-br1-ns2 master br1
echo

# router-ns <-> br0
echo "Connecting router-ns to br0..."
sudo ip link set dev veth-r0 netns router-ns
sudo ip link set dev veth-br0-r master br0
echo

# router-ns <-> br1
echo "Connecting router-ns to br1..."
sudo ip link set dev veth-r1 netns router-ns
sudo ip link set dev veth-br1-r master br1
echo

# Verify connections
echo "Verifying connections..."
sudo ip link show
echo

# Set the veth interfaces up in the namespaces and on the bridges
echo "Setting veth interfaces up..."
sudo ip netns exec ns1 ip link show
sudo ip netns exec ns2 ip link show
sudo ip netns exec router-ns ip link show
echo

sudo ip link set dev veth-br0-ns1 up
sudo ip link set dev veth-br1-ns2 up
sudo ip link set dev veth-br0-r up
sudo ip link set dev veth-br1-r up
echo

# Verify interface status
echo "Verifying interface status..."
sudo ip link show
echo

# Set the loopback interfaces up in the namespaces
echo "Setting loopback interfaces up in namespaces..."
sudo ip netns exec ns1 ip link set lo up  
sudo ip netns exec ns2 ip link set lo up  
sudo ip netns exec router-ns ip link set lo up
echo

# Set the veth interfaces up in the namespaces
echo "Setting veth interfaces up in namespaces..."
sudo ip netns exec ns1 ip link set dev veth-ns1 up
sudo ip netns exec ns2 ip link set dev veth-ns2 up
sudo ip netns exec router-ns ip link set dev veth-r0 up
sudo ip netns exec router-ns ip link set dev veth-r1 up
echo

# Verify interface status in namespaces
echo "Verifying interface status in namespaces..."
sudo ip netns exec ns1 ip link show
sudo ip netns exec ns2 ip link show
sudo ip netns exec router-ns ip link show
echo

# Assign IP addresses to the interfaces in the namespaces and set up routing
echo "Assigning IP addresses and setting up routing in namespaces..."
sudo ip netns exec ns1 ip address add 10.0.0.11/24 dev veth-ns1
sudo ip netns exec ns1 ip route add default via 10.0.0.21
echo

sudo ip netns exec ns2 ip address add 11.0.0.11/24 dev veth-ns2
sudo ip netns exec ns2 ip route add default via 11.0.0.21
echo

sudo ip netns exec router-ns ip address add 10.0.0.21/24 dev veth-r0
sudo ip netns exec router-ns ip address add 11.0.0.21/24 dev veth-r1
echo

# Verify IP address assignment and routing configuration
echo "Verifying IP address assignment and routing configuration..."
sudo ip netns exec ns1 ip route show
sudo ip netns exec ns2 ip route show
sudo ip netns exec router-ns ip route show
echo

# Enable IP forwarding in the router namespace
echo "Enabling IP forwarding in router-ns..."
sudo ip netns exec router-ns sysctl -w net.ipv4.ip_forward=1
echo

# Set up iptables rules to allow forwarding between the bridges
echo "Setting up iptables rules for forwarding between bridges..."
sudo iptables --append FORWARD --in-interface br0 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br0 --jump ACCEPT
echo

sudo iptables --append FORWARD --in-interface br1 --jump ACCEPT
sudo iptables --append FORWARD --out-interface br1 --jump ACCEPT
echo

# Set up iptables rules in the router namespace to allow forwarding between the veth interfaces
echo "Setting up iptables rules in router-ns for forwarding between veth interfaces..."
sudo ip netns exec router-ns iptables --append FORWARD --in-interface veth-r0 --jump ACCEPT
sudo ip netns exec router-ns iptables --append FORWARD --out-interface veth-r0 --jump ACCEPT
echo

sudo ip netns exec router-ns iptables --append FORWARD --in-interface veth-r1 --jump ACCEPT
sudo ip netns exec router-ns iptables --append FORWARD --out-interface veth-r1 --jump ACCEPT
echo


# Verify connectivity by pinging from ns1 to the router and from ns2 to the router
echo "Verifying connectivity..."

echo "Pinging from ns1 to router-ns (10.0.0.21):"
sudo ip netns exec ns1 ping -c 3 10.0.0.21
echo

echo "Pinging from ns2 to router-ns (11.0.0.21):"
sudo ip netns exec ns2 ping -c 3 11.0.0.21
echo

# Verify connectivity by pinging from ns1 to ns2 and from ns2 to ns1
echo "Pinging from ns1 to ns2 (11.0.0.11):"
sudo ip netns exec ns1 ping -c 3 11.0.0.11
echo

echo "Pinging from ns2 to ns1 (10.0.0.11):"
sudo ip netns exec ns2 ping -c 3 10.0.0.11
echo

# Cleanup: Delete the namespaces, bridges, and veth pairs
echo "Cleaning up..."
sudo ip netns del ns1
sudo ip netns del ns2
sudo ip netns del router-ns
sudo ip link del br0
sudo ip link del br1
echo

# Verify cleanup
echo "Verifying cleanup..."
sudo ip netns list
sudo ip link show
echo

echo "Simulation completed successfully!"