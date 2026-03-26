# Linux Network Namespace Simulation Assignment

## Background

Network namespaces in Linux allow for the creation of isolated network environments within a single host. This assignment will help you understand how to create and manage multiple network namespaces and connect them using bridges and routing.

## Main Objective

Create a network simulation with two separate networks connected via a router using Linux network namespaces and bridges.

## Required Components

### Network Bridges

- ⁠Bridge 0 (br0)
- Bridge 1 (br1)

### Network Namespaces

- ⁠Namespace 1 (ns1) - connected to br0
- ⁠Namespace 2 (ns2) - connected to br1
- ⁠Router namespace (router-ns) - connects both bridges

## Required Tasks

1.⁠ ⁠Create Network Bridges

- Set up br0 and br1
- Ensure bridges are properly configured and active

2.⁠ ⁠Create Network Namespaces

- Create three separate network namespaces (ns1, ns2, router-ns)
- Verify namespace creation

3.⁠ ⁠Create Virtual Interfaces and Connections

- Create appropriate virtual ethernet (veth) pairs
- Connect interfaces to correct namespaces
- Connect interfaces to appropriate bridges

4.⁠ ⁠Configure IP Addresses

- Assign appropriate IP addresses to all interfaces
- Ensure proper subnet configuration
- Document your IP addressing scheme

5.⁠ ⁠Set Up Routing

- Configure routing between namespaces
- Enable IP forwarding where necessary
- Establish default routes

6.⁠ ⁠Enable and Test Connectivity

- Ensure ping works between ns1 and ns2
- Document and test all network paths
- Verify full connectivity

## Bonus Challenge

Implement your solution using either:

- A bash script for automation
- ⁠A Makefile for automated setup and teardown

## Deliverables

1.⁠ ⁠Complete implementation (either manual commands or automation script)
2.⁠ ⁠Network diagram showing your topology
3.⁠ ⁠Documentation of:

- IP addressing scheme
- Routing configuration
- Testing procedures and results

## Technical Requirements

- ⁠All commands must be executed with root privileges
- ⁠Solution must work on a standard Linux system

## Evaluation Criteria

- ⁠Correct network topology implementation
- Proper isolation between namespaces
- Successful routing between networks
- Code quality (if automation is implemented)
- Documentation quality

## Note

Remember to add a clean up function to clean your network namespaces and bridges after testing to avoid conflicts with other network configurations.

========================================================

## Documentation Requirement

All students must prepare proper documentation for their project.  
The documentation should be created in one of the following formats:

- README (Markdown) or
- PPT / PPTX or
- TXT / DOCX

The documentation file must be uploaded to your **GitHub repository or Cloud Storage Drive**.  
After uploading, submit the **GitHub repository /Cloud Drive Link** in the **Google Form** provided below.

Link:

Please make sure the documentation is complete, well-organized, and clearly explains your project.
