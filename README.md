# Social Tables Docker-Machine DNS Config Utility

This is a utility for making [Docker Machine](https://docs.docker.com/machine/overview/) VMs accessible via hostname on OSX via [Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html).

When Docker Machine starts a VM to run containers, it can be hard to anticipate what IP it will mount at, making static configuration of both hosts and application-specific redirects (think Dockerized web services implementing flows like OAuth) challenging to configure and maintain. This utility solves the problem by making it easy to automatically update a dnsmasq configuration to point to this occasionally-moving target.

## Contents

This repo contains two primary scripts:

- *update-docker-machine-dns.sh*: A script for updating the current dnsmasq configuration to assign a domain to an actively-running docker-machine instance's ip. Accepts optional arguments to specify which docker-machine name and host name to use, and can be run continuously via the -d flag.
- *install.sh*: An all-in-one installer which installs and configures dnsmasq and a launch daemon which runs update-docker-machine-dns in the background. Targets the "default" docker machine VM. This VM and hostname can be configured as daemon program arguments in the com.socialtables.docker-hostname-daemon.plist.

## Prerequisites

You should have Docker Toolbox and Homebrew installed.

## Usage

```
docker-machine start
./install.sh [-v]
```
