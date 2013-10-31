#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Get system information

## Returns 'Debian', 'Ubuntu', 'Fedora', CentOS  etc.
DIST=$(python -c 'import platform; dist = platform.linux_distribution()[0]; print dist[0].upper() + dist[1:]')

# System functions
function get_home {
    echo $(awk -F: -v v=$1 '{if ($1==v) print $6}' /etc/passwd)
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
  else
      echo "No SSH key found."
      exit 1
  fi
}

function set_vnc_password {
  ## Set the VNC password as the password for the user 'cloudsigma'
  VNCPWD=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\nvnc_password\n>" > /dev/ttyS1; wait %1)
  PWDSTRING="cloudsigma:$VNCPWD"
  echo $PWDSTRING | sudo /usr/sbin/chpasswd
}

function install_newrelic {
  curl -o /tmp/nrsetup.sh https://raw.github.com/cloudsigma/newrelic_server_monitor_installer/master/install.sh
  chmod +x /tmp/nrsetup.sh && /tmp/nrsetup.sh && rm /tmp/nrsetup.sh
}


function install_desktop_ubuntu {
  sudo apt-get -y install ubuntu-desktop
}

function install_desktop_centos {
  sudo yum -y groupinstall "Desktop" "Desktop Platform" "X Window System" "Fonts"
  sudo sed -e 's/id:3:initdefault:/id:5:initdefault:/g' -i /etc/inittab
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
  sudo tzselect
}

function set_timezone_ubuntu {
  sudo dpkg-reconfigure tzdata
}

function set_timezone {
  if  [ $DIST = 'Ubuntu' ]; then
    set_timezone_ubuntu
  elif [ $DIST = 'Debian' ]; then
    set_timezone_ubuntu
  elif [ $DIST = 'CentOS' ]; then
    set_timezone_centos
  elif [ $DIST = 'RedHat' ]; then
    set_timezpne_centos
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
  *)
    echo -e 'Valid options are:'

    echo -e '\t* install-ssh-key'
    echo -e '\t\tInstalls the SSH Key from the WebApp to the current user\n\t\t(override by passing a username as a variable).'

    echo -e '\t* set-vnc-password'
    echo -e '\t\tSets the VNC password as the password for the user "cloudsigma".'

    echo -e '\t* install-newrelic'
    echo -e '\t\tInstalls New Relic Server Monitoring agent.'

    echo -e '\t* install-desktop'
    echo -e '\t\tInstalls a desktop environment. This will take while...'

    echo -e '\t* set-timezone'
    echo -e '\t\tReconfigure the timezone.'

    ;;
esac
