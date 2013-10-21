#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DIST=$(python -c 'import platform; dist = platform.linux_distribution()[0]; print dist[0].upper() + dist[1:]')

function generate_ssh_host_key_debian {
  # Regenerate SSH keys.
  # Fall back to manually generate keys if dpkg fails.

  test -f /etc/ssh/ssh_host_dsa_key || ssh-keygen -t dsa -N "" -f /etc/ssh/ssh_host_dsa_key
  test -f /etc/ssh/ssh_host_rsa_key || ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
  test -f /etc/ssh/ssh_host_ecdsa_key || ssh-keygen -t ecdsa -N "" -f /etc/ssh/ssh_host_ecdsa_key
  service ssh restart
}

# Silly Debian/Ubuntu doesn't generate SSH host keys on boot if they are absent.
if [ $DIST == 'Debian' ]; then
  generate_ssh_host_key_debian
elif [ $DIST == 'Ubuntu' ]; then
  generate_ssh_host_key_debian
fi

## Set the VNC password as the password for the user 'cloudsigma'
VNCPWD=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\nvnc_password\n>" > /dev/ttyS1; wait %1)
PWDSTRING="cloudsigma:$VNCPWD"
echo $PWDSTRING | /usr/sbin/chpasswd

## Makes sure `hostname` is present in /etc/hosts
# TODO

## Install SSH keys
/usr/sbin/cs_install_ssh_keys.sh
