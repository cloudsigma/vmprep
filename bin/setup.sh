#!/bin/bash
# vim: tabstop=4 expandtab shiftwidth=2 softtabstop=2

## Intro block
clear

# Display banner
curl -sL https://raw.github.com/cloudsigma/vmprep/master/files/banner
echo -e "\n\nWelcome to vmprep, CloudSigma's Virtual Machine preparation tool."

################################################################################
# Pre-flight checks
################################################################################

GITHUBFILEPATH="https://raw.github.com/cloudsigma/vmprep/master/files"

## Require a signature
echo "Please enter your signature (e.g. 'JD' for John Doe):"
read SIGN

if [ -z $SIGN ]; then
  echo 'Signature required. Exiting.'
  exit 1
fi

## Does Python exist (required)?
## (`which python` would have been a cleaner solution, but it behaves
## too differently on CentOS vs. Debian, which makes it hard to
## parse the result properly)

PATHLIST=$(echo $PATH | sed -e 's/:/ /g')
for i in $PATHLIST; do
  FOUNDPYTHON=False
  if [ -f "$i/python" ]; then
    FOUNDPYTHON=True
    break
  fi
done

if [ $FOUNDPYTHON == 'False' ]; then
  echo 'Python is missing. Exiting.'
  exit 1
fi

################################################################################
# Fetch system data (via Python)
################################################################################

## Returns 'Linux', 'Windows' etc.
OS=$(python -c 'import platform; print platform.system()')

## Returns 'Debian', 'Ubuntu', 'Fedora', CentOS  etc.
DIST=$(python -c 'import platform; dist = platform.linux_distribution()[0]; print dist[0].upper() + dist[1:]')

## Returns the distribution version.
DISTVER=$(python -c 'import platform; print platform.linux_distribution()[1]')

## Returns '32bit' or '64bit'
ARCH=$(python -c 'import platform; print platform.architecture()[0]')

## Generate a hostname based on distribution and version (eg. ubuntu1204.local)
HOSTNAME=$(python -c "print '%s%s.local' % ('$DIST'.lower(), '$DISTVER'.replace('.', ''))")

SYSSTRING="$OS - $DIST $DISTVER ($ARCH)\nBuild date: $(date +"%Y-%m-%d") ($SIGN)"

################################################################################
# Various checks and helper functions
################################################################################

# Make sure we're running as root
function running_as_root {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

# Make sure the user 'cloudsigma' exist.
function check_cs_user {
  CSUSR=$(python -c "import pwd; print 'cloudsigma' in [entry.pw_name for entry in pwd.getpwall()]")
  if [ $CSUSR == 'False' ]; then
    adduser cloudsigma --create-home --shell /bin/bash
  fi
}

# Abort if a command fails to exit cleanly (exit code 0).
# $1 = description
function exit_check {
  if [ ! $? -eq 0 ]; then
      echo "$1 failed to run properly. Exiting."
      exit 1
  fi
}

# Fetch and install a file into /usr/sbin.
# $1 = URL
function install_exec {
  FILENAME=$(basename $1)
  ABSPATH="/usr/sbin/$FILENAME"
  curl -sL -o $ABSPATH $1
  exit_check "Fetch $1"
  chown root:root $ABSPATH
  chmod 0755 $ABSPATH
  unset FILENAME
  unset ABSPATH
}

################################################################################
# Functions for different systems
################################################################################

## Function for pre-distribution-specific function.
function linux_before {
  # Install the first-launch script
  install_exec "$GITHUBFILEPATH/cs_first_boot.sh" '/usr/sbin/cs_first_boot.sh'
  install_exec "$GITHUBFILEPATH/cs_util.sh" '/usr/sbin/cs_util.sh'

  # Get banner
  BANNER=$(curl -sL https://raw.github.com/cloudsigma/vmprep/master/files/banner)

  # Overwrite /etc/rc.local
  curl -sL "$GITHUBFILEPATH/rc_local" > /etc/rc.local
  exit_check "Fetch rc.local"

  # Set a random root password and disable login (can be enabled by setting a password)
  ROOTPWD=$(openssl rand -base64 32)
  ROOTPWDSTRING="root:$ROOTPWD"
  echo $ROOTPWDSTRING | /usr/sbin/chpasswd
  passwd -l root > /dev/null
  exit_check "Disabling root login"

  # Set a random password for cloudsigma (to harden the system prior to the VNC pwd is set on boot)
  CSPWD=$(openssl rand -base64 32)
  CSPWDSTRING="cloudsigma:$CSPWD"
  echo $CSPWDSTRING | /usr/sbin/chpasswd

  # Make sure user 'cloudsigma' can `sudo` (without password).
  mkdir -p /etc/sudoers.d
  echo -e 'cloudsigma\tALL=(ALL)\tNOPASSWD: ALL' > /etc/sudoers.d/cloudsigma
  chown root:root /etc/sudoers.d/cloudsigma
  chmod 0440 /etc/sudoers.d/cloudsigma

  # Improve security by disabling root login via SSH
  sed -e 's/^.*PermitRootLogin.*$/PermitRootLogin no/g' -i /etc/ssh/sshd_config > /dev/null
  exit_check "Disable root login via ssh"
}

## Function for post-distribution specific function.
function linux_after {

  # Overwrite `/etc/issue` with some system information and a greeting (for tty/VNC)
  curl -sL $GITHUBFILEPATH/issue > /etc/issue
  exit_check "Fetch 'issue'"
  echo -e "\n$SYSSTRING\n"  >> /etc/issue

  # Touch the trigger file
  touch /home/cloudsigma/.first_boot

  # Remove all log-files
  find /var/log -type f -delete

  # Remove bash-history files
  for file in /root/.bash_history /home/cloudsigma/.bash_history; do
    truncate -s 0 $file
  done

  # Make sure no SSH keys were installed
  rm -rf /home/cloudsigma/.ssh
  rm -rf /root/.ssh

  # Clear the history list
  history -c

  # Make sure we don't leave any SSH host keys behind to avoid MiTM-attacks.
  rm -f /etc/ssh/ssh_host_*
  exit_check "Removing ssh host keys"

  # Prevent new network interface from showing up as eth1
  if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    truncate -s 0 /etc/udev/rules.d/70-persistent-net.rules
  fi

  if [ -f /lib/udev/write_net_rules ]; then
    truncate -s 0 /lib/udev/write_net_rules
  fi

  # Set the hostname and remove the temporary one
  echo $HOSTNAME > /etc/hostname
  sed -i "s/^.*$(hostname).*$//g" /etc/hosts > /dev/null
  hostname $HOSTNAME
  sed -i "1s/^/127.0.0.1\t$(hostname)\t$(hostname -s)\n/" /etc/hosts
}

## Debian
function debian {

  apt-get --quiet update
  apt-get -y --quiet upgrade

  # Make sure desired packages are installed
  apt-get install -y --quiet sudo python-pip vim ufw fail2ban bash-completion acpid

  # Clean up
  apt-get --quiet autoremove
  apt-get --quiet clean

  # Add user 'cloudsigma' to dialout group so that
  # it can read /dev/ttyS0 (needed for server contextualization)
  usermod -a -G dialout cloudsigma

  # Add final line(s) to rc.local
  echo -e 'exit 0' >> /etc/rc.local

  # Make sure to only run this on Debian. Ubuntu uses `motd.tail`,
  # so this is to avoid the message being displayed twice.
  if [ $DIST == 'Debian' ]; then
    # Install string to Motd (after login)
    echo -e "\n$BANNER\n\n$SYSSTRING\n" > /etc/motd
  fi

  # Configure Uncomplicated Firewall (ufw) block all but SSH
  # (Disable IPv6 to avoid duplicate rules)
  sed -i 's/^IPV6=yes/IPV6=no/g' /etc/default/ufw > /dev/null
  ufw allow ssh > /dev/null
  echo 'y' | ufw enable > /dev/null

  # Fix bug with non-persistent DHCP
  # (http://www.metacloud.com/wp-content/uploads/2013/10/OS_Summit_Portland_Images.pdf)
  if [ -h /sbin/dhclient3 ]; then
    rm -f /sbin/dhclient3
  fi

  # Make sure no CD-ROM references are present in source.list.
  sed -i 's/^deb cdrom/# deb cdrom/g; s/^deb-src cdrom/# deb cdrom-src/g' /etc/apt/sources.list > /dev/null
}

## Ubuntu
function ubuntu {
  # Use the same routine as Debian
  debian

  # Install the latest kernel
  apt-get install -y --quiet linux-image-virtual linux-virtual cloud-initramfs-growroot

  # Install string to Motd (after login)
  echo -e "\n$BANNER\n\n$SYSSTRING\n" > /etc/motd.tail
}

## CentOS
function centos {

  # TODO: ssh key authentication doesn't work.
  # https://github.com/cloudsigma/vmprep/issues/1

  # Make sure we're up to date
  echo "Running upgrade..."
  yum -y upgrade

  # Add user 'cloudsigma' to dialout group so that
  # it can read /dev/ttyS0 (needed for server contextualization)
  usermod -a -G dialout cloudsigma

  # Install EPEL repository (required for fail2ban and python-pip)
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

  # Make sure desired packages are installed
  yum install -y vim fail2ban python-pip system-config-securitylevel-tui cloud-utils
  chkconfig fail2ban on

  # Clean up
  yum --quiet clean all

  # Add final line(s) to rc.local
  echo -e 'touch /var/lock/subsys/local\nexit 0' >> /etc/rc.local

  # Configure networking
  echo -e 'DEVICE=eth0\nBOOTPROTO=dhcp\nONBOOT=yes' > /etc/sysconfig/network-scripts/ifcfg-eth0

  # Install string to Motd (after login)
  echo -e "\n$BANNER\n\n$SYSSTRING\n" > /etc/motd

  # Fix bug with non-persistent DHCP
  # (http://www.metacloud.com/wp-content/uploads/2013/10/OS_Summit_Portland_Images.pdf)
  echo "PERSISTENT_DHCLIENT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0

  # Make sure the MAC address isn't stored
  sed -i 's/^HWADDR.*$//g' /etc/sysconfig/network-scripts/ifcfg-eth0 > /dev/null
}

## RedHat Enterprise Linux
function redhat {
  # Use same routine as CentOS
  centos
}

## Fedora
function fedora {

  # Make sure we're up to date
  echo "Running upgrade..."
  yum -y upgrade

  # Make sure desired packages are installed
  yum install -y vim fail2ban python-pip system-config-securitylevel-tui cloud-initramfs-growroot
  chkconfig fail2ban on

  # Add user 'cloudsigma' to dialout group so that
  # it can read /dev/ttyS0 (needed for server contextualization)
  usermod -a -G dialout cloudsigma

  # Clean up
  yum clean all

  # Install string to Motd (after login)
  echo -e "\nDiscover True IaaS with CloudSigma.\n\n$SYSSTRING\n" > /etc/motd

  # Add final line(s) to rc.local
  echo -e 'exit 0' >> /etc/rc.local
  chmod +x /etc/rc.local

  # Install string to Motd (after login)
  echo -e "\n$BANNER\n\n$SYSSTRING\n" > /etc/motd
}

################################################################################
# Enough functions already. Let's execute some code.
################################################################################

# Pre-flight checks.
running_as_root
check_cs_user

if [ $OS == 'Linux' ]; then

  linux_before # Call on `linux_before` function

  if [ $DIST == 'Debian' ]; then
    debian # Call on `debian` function
  elif  [ $DIST = 'Ubuntu' ]; then
    ubuntu # Call on `ubuntu` function
  elif [ $DIST = 'CentOS' ]; then
    centos # Call on `centos` function
  elif [ $DIST = 'RedHat' ]; then
    redhat # Call on `redhat` funcation
  elif [ $DIST = 'Fedora' ]; then
    fedora # Call on `fedora` function
  else
    echo "$DIST is an unsupported Linux distribution"
  fi

  linux_after # Call on `linux_after` function

else
  echo "$OS is an unsupported platform."
fi
