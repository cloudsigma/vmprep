# Disk image preparation tool

(**Warning:** Work in progress)

The purpose of this tool is to have a predictable tool that prepares disk images for our drives library. The tool is also open source, such that the modifications that we make to the operating systems are transparent and easy to audit.

We've also designed these base images to be as convenient as possible for you as a user. Just clone the image, and you should be good to go. Even your SSH key will be automatically installed.

## Status

This tool has been tested on:

 * CentOS 6.4
 * Debian 7.2
 * Ubuntu 12.04
 * Ubuntu 13.10

## Overview

In order to keep things consistent, we make a few things consistent across all Linux distributions:

 * All images are 64bit.
 * The user standard user is 'cloudsigma'.
 * Root login is disabled via SSH.
 * The root account is disabled by default, but you can still `sudo` to switch to root.
 * The password set for the user is the VNC password from the web console (which is set on the first boot).
 * SSH is enabled (and port 22 is opened in the firewall).
 * If an SSH key is present, it will be installed for the user 'cloudsigma'.
 * To improve security further, `fail2ban` is installed, which provides additional protection against brute-force attacks.
 * All operating systems are using `eth0` as the network interface, and it is configured to use DHCP.
 * A system upgrade (via the native package manager) is executed to ensure that all the latest packages are installed.
 * All disk images are 10GB in size and are using LVM (such that you can easily expand it with another disk).
 * All disk images are created to run with VirtIO for both disks and network interface.
 * The keyboard layout is set to English (US).

## Installation notes for operating system.

### Ubuntu

Please see these [installation instructions](https://github.com/cloudsigma/vmprep/blob/master/docs/ubuntu.md).

In order to increase the security, the post-installation script installs Uncomplicated Firewall (ufw), and configured to block all connections with the exception of SSH. To disable ufw, simply run `sudo ufw disable`. For more information about ufw, please visit [this](https://help.ubuntu.com/community/UFW) page.

### Debian

Please see these [installation instructions](https://github.com/cloudsigma/vmprep/blob/master/docs/debian.md).

Similarly to Ubuntu, 'ufw' is installed.

### CentOS

Please see these [installation instructions](https://github.com/cloudsigma/vmprep/blob/master/docs/centos.md).

By default, the firewall is configured to only accept SSH connections. To alter the firewall, we recommend that you use `system-config-securitylevel-tui` (or `iptables` directly).

## Usage

First, make sure that `curl` and `python` are installed. Once that is done, simply run this command as root:

    curl -sL -o /tmp/setup.sh https://www.cloudsigma.com/vmprep.sh
    chmod +x /tmp/setup.sh && /tmp/setup.sh && rm -f /tmp/setup.sh

## FAQ

### How do I install a graphical interface?

Simply run the following command:

    sudo cs_util.sh install-desktop

### How do I update the timezone?

Just run the following command:

    sudo cs_util.sh set-timezone

### How do I install SSH keys added after the first boot?

By default, the SSH key(s) stored in the WebApp for the server (or drive) will be installed to the account 'cloudsigma'. If you wish to do this later on, you can use the same tool again.

    cs_util.sh install-ssh-key

This will install your SSH key(s) to your account. If you wish to install the same SSH key to a different account, you can do that too by runnning:

    cs_util.sh install-ssh-key otheruser
