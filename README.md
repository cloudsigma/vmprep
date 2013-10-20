# CloudSigma disk image preparation tool

(Warning: work in progress)

The purpose of this tool is to have a predictable tool that prepares disk images for our drives library. The tool is also open source, such that the modifications that we make to the operating systems are transparent and easy to audit.

## Status

This tool has been tested on:

 * Ubuntu 12.04
 * CentOS 6.4

## Overview

In order to keep things consistent, we make a few things consistent across all Linux distributions:

 * The user standard user is 'cloudsigma'.
 * Root login is disabled via SSH.
 * The root password is sett to null, hence you need to use `sudo` to switch to root.
 * The password set for the user is the VNC password from the web console (which is set on the first boot).
 * SSH is enabled (and port 22 is opened in the firewall).
 * If an SSH key is present, it will be installed for the user 'cloudsigma'.
 * To improve security further, `fail2ban` is installed, which provides additional security against brute-force attacks.
 * All operating systems are using `eth0` as the network interface, and it is configured to use DHCP.
 * A system upgrade (via the native package manager) is executed to ensure that all the latest packages are installed.
 * All disk images are 10GB in size and are using LVM (such that you can easily add another disk)
 * Root login via SSH is disabled.
 * The timezone is set to CET
 * All disk images are created to run with VirtIO for both disks and network interface

## Installation notes for operating system.

### Ubuntu
For Ubuntu, we will use the 'minimal virtual installation' (press F2 in the boot screen). We also configure these systems to automatically install security updates.

In order to increase the security, Uncomplicated Firewall (ufw) is installed, and configured to block all connections with the exception of SSH. To disable ufw, simply run `sudo ufw disable`. For more information about ufw, please visit (insert link).

### Debian

### CentOS
The most notable change is that the root account is disabled by default. We've also disabled root-login via SSH.

## Usage

First, make sure that `curl` is installed. Once that is done, simply run this command as root:

    curl -sL -o /tmp/setup.sh https://raw.github.com/cloudsigma/vmprep/master/bin/setup.sh
    chmod +x /tmp/setup.sh
    rm /tmp/setup.sh

## FAQ

### How do I install a graphical interface?
TODO

### How do I update the timezone?
TODO

### How do I install SSH keys added after the initial clone

Just run the command:

    cs_install_ssh_keys.sh

