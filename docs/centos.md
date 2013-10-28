# Installation instructions for CentOS

## Basic info

Like all pre-installed virtual machines, the machine will use:

 * A 10GB disk size
 * VirtIO for both networking and disk
 * 64bit version of CentOS

The screenshots were taken during an CentOS 6.4 installation.

## Installation Screenshots

![00](https://raw.github.com/cloudsigma/vmprep/master/img/centos/00.png)
![01](https://raw.github.com/cloudsigma/vmprep/master/img/centos/01.png)
![02](https://raw.github.com/cloudsigma/vmprep/master/img/centos/02.png)
![03](https://raw.github.com/cloudsigma/vmprep/master/img/centos/03.png)
![04](https://raw.github.com/cloudsigma/vmprep/master/img/centos/04.png)
![05](https://raw.github.com/cloudsigma/vmprep/master/img/centos/05.png)
![06](https://raw.github.com/cloudsigma/vmprep/master/img/centos/06.png)
![07](https://raw.github.com/cloudsigma/vmprep/master/img/centos/07.png)
![08](https://raw.github.com/cloudsigma/vmprep/master/img/centos/08.png)
![09](https://raw.github.com/cloudsigma/vmprep/master/img/centos/09.png)
![10](https://raw.github.com/cloudsigma/vmprep/master/img/centos/10.png)
![11](https://raw.github.com/cloudsigma/vmprep/master/img/centos/11.png)
![12](https://raw.github.com/cloudsigma/vmprep/master/img/centos/12.png)
![13](https://raw.github.com/cloudsigma/vmprep/master/img/centos/13.png)
**Note:** Upon first boot, you need to login via VNC and run `dhclient eth0` such that we can login to the server via SSH.


## Preparation

Once you have received an IP and are able to SSH in, you need to run the following command prior to moving on to the VM preparation tool.

    adduser cloudsigma -m -s /bin/bash

## Final words

Once you have setup the system, log in to the system and run the `vmprep` script.

