#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

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
SSHKEY=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\n/meta/ssh_public_key\n>" > /dev/ttyS1; wait %1)
if [[ "$SSHKEY" ]]; then
    create_ssh_folder cloudsigma
    CLOUDSIGMAHOME=$(get_home cloudsigma)
    echo -e "$SSHKEY" >> $CLOUDSIGMAHOME/.ssh/authorized_keys
else
    echo "No SSH key found."
    exit 1
fi
