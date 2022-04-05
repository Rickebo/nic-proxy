## Introduction

Scripts useful to quickly setup a dante proxy server for an additional network interface.

## My use case

I wrote these scripts to easier use other software to route some network traffic on my windows PC through another
network adapter (or network interface). By running these scripts in WSL, and setting the metric of the different
adapters in windows, I can easily and selectively route different processes traffic through different interfaces in a
way that does not interrupt my workflow.

For a similar use case, I recommend using [NetRouteView](https://www.nirsoft.net/utils/network_route_view.html) to set
metrics (priorities) for different network adapters, since the built-in options in windows for doing so are cumbersome
to use and proved to be unreliable for me.

## Prerequisites

To run the script, apt must be installed and set up, as well as wget if the command below is used. Note that the script
installs some other dependencies if not already installed, such as git. 

## Setup

To run the setup script remotely, run the following command:

```bash
wget https://raw.githubusercontent.com/Rickebo/nic-proxy/main/setup-remote.sh; sudo bash ./setup-remote.sh
```

The script does the following:
1. Identifies all network interfaces that can access [https://api.ipify.org/](https://api.ipify.org/).
2. Filter out the network interfaces that yield the same IP as ``curl https://api.ipify.org/``. So, for example, if the
   response of ``curl https://api.ipify.org/`` is ``1.1.1.1``, and the response of ``curl --interface eth0
   https://api.ipify.org/`` is also ``1.1.1.1``, the interface ``eth0`` is excluded. The script can easily be edited to
   change this behavior.
3. Set up a dante SOCKS server listening for connections on localhost by default, proxying through a suitable interface
   if one was found.

## Warnings

Note the following:

- The script has not been thoroughly tested and therefore probably wont work for other systems and configurations.
- There are almost always other better solutions to route network traffic over other network interfaces.