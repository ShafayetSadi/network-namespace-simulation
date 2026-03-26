# Network Namespace Simulation

A simple Linux networking lab that simulates two isolated networks connected through a router namespace using bridges and veth interfaces.

## Topology Summary

- Bridge br0 connects ns1 and router-ns
- Bridge br1 connects ns2 and router-ns
- ns1 subnet: 10.0.0.0/24
- ns2 subnet: 11.0.0.0/24
- Router forwards traffic between both subnets

## Files

- [simulation.sh](./simulation.sh): setup, test, and cleanup automation
- [Solution.md](./Solution.md): step-by-step documentation and details

## Prerequisites

- Linux host
- sudo access
- iproute2
- iptables

## How To Run

Make the script executable:

```sh
chmod +x simulation.sh
```

Run the simulation:

```sh
./simulation.sh
```

or,

```sh
bash simulation.sh
```
