#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Get system information

## Returns 'Debian', 'Ubuntu', 'Fedora', CentOS  etc.
DIST=$(python -c 'import platform; dist = platform.linux_distribution()[0]; print dist[0].upper() + dist[1:]')

# System functions
function get_home {
    echo $(awk -F: -v v=$1 '{if ($1==v) print $6}' /etc/passwd)
}

# Make sure we're running as root
function running_as_root {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

function create_ssh_folder {
    BASE=$(get_home $1)
    mkdir -p $BASE/.ssh
    chmod 0700 $BASE/.ssh
    touch $BASE/.ssh/authorized_keys
    chmod 0600 $BASE/.ssh/authorized_keys
    chown -R $1:$1 $BASE/.ssh
}

# Install the SSH key if present.
# $1 is is the user account.
function install_ssh_key {
  # Set the target to the variable passed, but fall back to the current user.
  if [ -z "$1" ]; then
    TARGET="$(whoami)"
  else
    TARGET="$1"
  fi

  SSHKEY=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\n/meta/ssh_public_key\n>" > /dev/ttyS1; wait %1)
  if [[ "$SSHKEY" ]]; then
      create_ssh_folder $TARGET
      USERHOME=$(get_home $TARGET)
      echo -e "$SSHKEY" >> $USERHOME/.ssh/authorized_keys
      echo "Found and installed SSH key for $TARGET."
  else
      echo "No SSH key found."
      exit 1
  fi
}

function set_vnc_password {
  running_as_root

  ## Set the VNC password as the password for the user 'cloudsigma'
  VNCPWD=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\nvnc_password\n>" > /dev/ttyS1; wait %1)
  if [[ "$VNCPWD" ]]; then
    PWDSTRING="cloudsigma:$VNCPWD"
    echo $PWDSTRING | /usr/sbin/chpasswd
    echo "VNC Password set for user cloudsigma"
  else
    echo "Unable to retrieve VNC password"
    exit 1
  fi
}

function install_newrelic {
  curl -o /tmp/nrsetup.sh https://raw.github.com/cloudsigma/newrelic_server_monitor_installer/master/install.sh
  chmod +x /tmp/nrsetup.sh && /tmp/nrsetup.sh && rm /tmp/nrsetup.sh
}


function install_desktop_ubuntu {
  running_as_root
  apt-get -y install ubuntu-desktop
}

function install_desktop_centos {
  running_as_root
  yum -y groupinstall "Desktop" "Desktop Platform" "X Window System" "Fonts"
  sed -e 's/id:3:initdefault:/id:5:initdefault:/g' -i /etc/inittab
}

function install_desktop {
  if  [ $DIST = 'Ubuntu' ]; then
    install_desktop_ubuntu
  elif [ $DIST = 'CentOS' ]; then
    install_desktop_centos
  elif [ $DIST = 'RedHat' ]; then
    install_desktop_centos
  else
    echo "$DIST is an unsupported Linux distribution"
  fi
}

function set_timezone_centos {
  running_as_root
  tzselect
}

function set_timezone_ubuntu {
  running_as_root
  dpkg-reconfigure tzdata
}

function set_timezone {
  if  [ $DIST = 'Ubuntu' ]; then
    set_timezone_ubuntu
  elif [ $DIST = 'Debian' ]; then
    set_timezone_ubuntu
  elif [ $DIST = 'CentOS' ]; then
    set_timezone_centos
  elif [ $DIST = 'RedHat' ]; then
    set_timezone_centos
  else
    echo "$DIST is an unsupported Linux distribution"
  fi

}

function self_update {
  running_as_root
  CSUTIL=/usr/sbin/cs_util.sh
  curl -sL -o $CSUTIL https://raw.github.com/cloudsigma/vmprep/master/files/cs_util.sh
  chmod +x $CSUTIL
  chown root:root $CSUTIL
}

function disable_firewall_ubuntu {
  running_as_root
  ufw disable
  echo 'Firewall disabled.'
}

function disable_firewall_centos {
  running_as_root
  service iptables save
  service iptables stop
  chkconfig iptables off
  echo 'Firewall disabled.'
}

function disable_firewall {
  if  [ $DIST = 'Ubuntu' ]; then
    disable_firewall_ubuntu
  elif [ $DIST = 'Debian' ]; then
    disable_firewall_ubuntu
  elif [ $DIST = 'CentOS' ]; then
    disaable_firewall_centos
  elif [ $DIST = 'RedHat' ]; then
    disable_firewall_centos
  else
    echo "$DIST is an unsupported Linux distribution"
  fi
}

#### Process user input
case "$1" in
  install-ssh-key)
    install_ssh_key $2
    ;;
  set-vnc-password)
    set_vnc_password
    ;;
  install-newrelic)
    install_newrelic
    ;;
  install-desktop)
    install_desktop
    ;;
  set-timezone)
    set_timezone
    ;;
  disable-firewall)
    disable_firewall
    ;;
  update)
    self_update
    ;;
  *)
    echo -e 'Valid options are:'

    echo -e '\t* install-ssh-key'
    echo -e '\t\tInstalls the SSH Key from the WebApp to the current user\n\t\t(override by passing a username as a variable).'

    echo -e '\t* set-vnc-password'
    echo -e '\t\tSets the VNC password as the password for the user "cloudsigma".'

    echo -e '\t* install-newrelic'
    echo -e '\t\tInstalls New Relic Server Monitoring agent using:\n\t\thttps://github.com/cloudsigma/newrelic_server_monitor_installer'

    echo -e '\t* install-desktop'
    echo -e '\t\tInstalls a desktop environment. This will take while...'

    echo -e '\t* set-timezone'
    echo -e '\t\tReconfigure the timezone.'

    echo -e '\t* disable-firewall'
    echo -e '\t\tDisable the firewall.'

    echo -e '\t* update'
    echo -e '\t\tDownload and install the latest version of cs_util.sh.'
    ;;
esac
