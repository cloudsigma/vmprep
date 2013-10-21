#!/bin/bash

## Intro block
clear
echo ""
echo "################################################################################"
echo "#                                                                              #"
echo "#                    CloudSigma disk image creation tool.                      #"
echo "#                                                                              #"
echo "################################################################################"
echo ""

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
    echo "The user 'cloudsigma' doesn't exist. Exiting."
    exit 1
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

## Function for pre-distribution specific function.
function linux_before {
  # Install the first-launch script
  install_exec "$GITHUBFILEPATH/cs_first_boot.sh" '/usr/sbin/cs_first_boot.sh'
  install_exec "$GITHUBFILEPATH/cs_install_ssh_keys.sh" '/usr/sbin/cs_install_ssh_keys.sh'

  # Overwrite /etc/rc.local
  curl -sL "$GITHUBFILEPATH/rc_local" > /etc/rc.local
  exit_check "Fetch rc.local"

  # Disable root-login (can be enabled by setting a password)
  passwd -l root > /dev/null
  exit_check "Disabling root login"

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

  # Clear the history list
  history -c

  # Make sure we don't leave any SSH host keys behind to avoid MiTM-attacks.
  rm -f /etc/ssh/ssh_host_*
  exit_check "Removing ssh host keys"
}

## Debian
function debian {

  apt-get --quiet update
  apt-get -y --quiet upgrade

  # Make sure desired packages are installed
  apt-get install -y --quiet sudo python-pip vim ufw fail2ban

  # Clean up
  apt-get --quiet autoremove
  apt-get --quiet clean

  # Add user 'cloudsigma' to dialout group so that
  # it can read /dev/ttyS0 (needed for server contextualization)
  usermod -a -G dialout cloudsigma

  # Add final line(s) to rc.local
  echo -e 'exit 0' >> /etc/rc.local

  # Install string to Motd (after login)
  echo -e "\nDiscover True IaaS with CloudSigma.\n\n$SYSSTRING\n" > /etc/motd

  # Configure Uncomplicated Firewall (ufw) block all but SSH
  # (Disable IPv6 to avoid duplicate rules)
  sed -i 's/^IPV6=yes/IPV6=no/g' /etc/default/ufw > /dev/null
  ufw allow ssh > /dev/null
  echo 'y' | ufw enable > /dev/null
}

## Ubuntu
function ubuntu {
  # Use the same routine as Debian
  debian

  # Install the latest kernel
  apt-get install -y --quiet linux-image-virtual linux-virtual

  # Install string to Motd (after login)
  echo -e "\nDiscover True IaaS with CloudSigma.\n\n$SYSSTRING\n" > /etc/motd.tail
}

## CentOS
function centos {

  # TODO: ssh key authentication doesn't work.

  # Make sure we're up to date
  echo "Running upgrade..."
  yum -y --quiet upgrade

  # Add user 'cloudsigma' to dialout group so that
  # it can read /dev/ttyS0 (needed for server contextualization)
  usermod -a -G dialout cloudsigma

  # Install EPEL repository (required for fail2ban and python-pip)
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

  # Make sure desired packages are installed
  yum install --quiet -y vim fail2ban python-pip system-config-securitylevel-tui
  chkconfig fail2ban on

  # Clean up
  yum --quiet clean all

  # Add final line(s) to rc.local
  echo -e 'touch /var/lock/subsys/local\nexit 0' >> /etc/rc.local

  # Configure networking
  echo -e 'DEVICE=eth0\nBOOTPROTO=dhcp\nONBOOT=yes' > /etc/sysconfig/network-scripts/ifcfg-eth0

  # Install string to Motd (after login)
  echo -e "\nDiscover True IaaS with CloudSigma.\n\n$SYSSTRING\n" > /etc/motd
}

## RedHat Enterprise Linux
function redhat {
  # Use same routine as CentOS
  centos
}

## Fedora
function fedora {

  # TODO: add rc.local equivalent feature for first-boot script

  # TODO: fail2ban?

  # Make sure we're up to date
  yum -y --quiet upgrade

  # Add user 'cloudsigma' to dialout group so that
  # it can read /dev/ttyS0 (needed for server contextualization)
  usermod -a -G dialout cloudsigma

  # Make sure desired packages are installed
  #yum install --quiet -y vim python-pip
  yum --quiet clean all

  # Install string to Motd (after login)
  echo -e "\nDiscover True IaaS with CloudSigma.\n\n$SYSSTRING\n" > /etc/motd
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
