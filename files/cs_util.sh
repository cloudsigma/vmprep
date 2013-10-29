#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

### System functions
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

## Install the SSH key if present.
## $1 is is the user account.
function set_ssh_key {
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
  echo $PWDSTRING | /usr/sbin/chpasswd
}

function install_newrelic {
  curl -o /tmp/nrsetup.sh https://raw.github.com/cloudsigma/newrelic_server_monitor_installer/master/install.sh
  chmod +x /tmp/nrsetup.sh && /tmp/nrsetup.sh && rm /tmp/nrsetup.sh
}


#### Process user input
case "$1" in
  set-ssh-key)
    set_ssh_key $2
    ;;
  set-vnc-password)
    set_vnc_password
    ;;
  install-newrelic)
    install_newrelic
    ;;
  *)
    echo -e 'Valid options are:'
    echo -e '\t* set-ssh-key <username> (defaults to the runtime user)'
    echo -e '\t* set-vnc-password'
    echo -e '\t* install_newrelic'
    ;;
esac
