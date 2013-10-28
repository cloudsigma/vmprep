# Disk image preparation tool

(**Warning:** Work in progress)

The purpose of this tool is to have a predictable tool that prepares disk images for our drives library. The tool is also open source, such that the modifications that we make to the operating systems are transparent and easy to audit.

We've also designed these base images to be as convenient as possible for you as a user. Just clone the image, and you should be good to go. Even your SSH key will be automatically installed.

## Status

This tool has been tested on:

 * CentOS 6.4
 * Debian 7.2
 * Ubuntu 12.04

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

### CentOS

Please see these [installation instructions](https://github.com/cloudsigma/vmprep/blob/master/docs/centos.md).

By default, the firewall is configured to only accept SSH connections. To alter the firewall, we recommend that you use `system-config-securitylevel-tui` (or `iptables` directly).

## Usage

First, make sure that `curl` and `python` are installed. Once that is done, simply run this command as root:

    curl -sL -o /tmp/setup.sh https://raw.github.com/cloudsigma/vmprep/master/bin/setup.sh
    chmod +x /tmp/setup.sh && sudo /tmp/setup.sh && rm /tmp/setup.sh

## FAQ

### How do I install a graphical interface?

On Ubuntu, run the following command:

    sudo apt-get install ubuntu-desktop

On CentOS, run the following command:

    sudo yum -y groupinstall "Desktop" "Desktop Platform" "X Window System" "Fonts"
    sudo sed -e 's/id:3:initdefault:/id:5:initdefault:/g' -i /etc/inittab

### How do I update the timezone?

On CentOS, run the following command:

    sudo tzselect

On Debian/Ubuntu, run the this command:

    sudo dpkg-reconfigure tzdata

### How do I install SSH keys added after the first boot?

You can simply run the command the initiator calls on:

    cs_install_ssh_keys.sh

Please note that this script is hard-coded to only install the keys into the 'cloudsigma' user account.
