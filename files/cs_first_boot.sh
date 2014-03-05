#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
DIST=$(python -c 'import platform; dist = platform.linux_distribution()[0]; print dist[0].upper() + dist[1:]')

# Expand the disk volume
echo "Expanding root disk..."
growpart /dev/vda 2
resize2fs /dev/vda2

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

# CentOS / RHEL will require a reboot to properly expand disk
# We set boot
if [ $DIST == 'CentOS' ]; then
  touch /home/cloudsigma/.reboot_me
  touch /home/cloudsigma/.resize_disk
elif [ $DIST == 'Redhat' ]; then
  touch /home/cloudsigma/.reboot_me
  touch /home/cloudsigma/.resize_disk
fi

# Retrieve list of commands passed on as 'run_on_first_boot' and execute them.
function run_on_first_boot {
  COMMANDS=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\nmeta/run_on_first_boot\n>" > /dev/ttyS1; wait %1)
  if [[ "$COMMANDS" ]]; then
    $COMMANDS
    echo "Ran commands: "$COMMANDS""
  else
    echo "No commands in 'run_on_first_boot'"
  fi
}

# Provision a hostname based on 'hostname'.
# The hostname must be a FQDN that is accepted by `hostname`
function provision_hostname {
  HOSTNAME=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\n/meta/hostname\n>" > /dev/ttyS1; wait %1)

  if [[ "$HOSTNAME" ]]; then
    echo $HOSTNAME > /etc/hostname
    sed -i "s/^.*$(hostname).*$//g" /etc/hosts > /dev/null
    hostname $HOSTNAME
    sed -i "1s/^/127.0.0.1\t$(hostname)\t$(hostname -s)\n/" /etc/hosts
    echo "Set `hostname` to $HOSTNAME."
  else
    echo "No hostname provided."
  fi
}

# Set the VNC password as the password for the user 'cloudsigma'
/usr/sbin/cs_util.sh set-vnc-password

# Install SSH keys for CloudSigma
/usr/sbin/cs_util.sh install-ssh-key cloudsigma

# Provision hostname
provision_hostname

# Run commands passed on in 'run_on_first_boot'
run_on_first_boot
