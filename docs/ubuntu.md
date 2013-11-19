# Installation instructions for Ubuntu

## Basic info

Like all pre-installed virtual machines, the machine will use:

 * A 10GB disk size
 * VirtIO for both networking and disk
 * 64bit version of Ubuntu

The screenshots were taken during an Ubuntu 12.04 installation for the Zurich datacenter.

## Screenshots
![00](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/00.png)

![01](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/01.png)

*Note:* Make sure you press F4 to select 'Install a minimal virtual machine'.

![02](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/02.png)
![03](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/03.png)

*Note:* Select the physical location of the datacenter for the disk image (in this case, Switzerland). This is used to configure the system for the closest mirror.

![04](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/04.png)
![05](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/05.png)
![06](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/06.png)

*Note:* Make sure you select 'English (US)' as the keyboard mapping.

![07](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/07.png)
![08](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/08.png)

*Note:* Set the hostname to 'ubuntu1204.local' (for Ubuntu 12.04).

![09](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/09.png)

*Note:* Create the user 'CloudSigma User'.

![10](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/10.png)

*Note:* This actual username will be 'cloudsigma'.

![11](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/11.png)

*Note:* Enter a temporary password. This will be overwritten later on.

![12](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/12.png)
![13](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/13.png)
![14](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/14.png)

*Note:* The timezone shall match the datacenter location.

![15](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/15.png)

*Note:* We need to manually partition the disks for the automatic disk expansion to work.

![16](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/16.png)
![17](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/17.png)
![18](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/18.png)

*Note:* First we create a 2GB swap (`/dev/vda1`). It is essential that this is the first partition.

![19](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/19.png)
![20](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/20.png)
![21](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/21.png)
![22](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/22.png)
![23](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/23.png)

*Note:* Make sure to modify the partition type to 'swap'.

![24](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/24.png)
![25](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/25.png)
![26](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/26.png)

*Note:* Next we create the root partition (`/dev/vda1`) for the remaining space.

![27](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/27.png)
![28](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/28.png)
![29](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/29.png)
![30](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/30.png)
![31](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/31.png)

*Note:* Make sure to set the 'Bootable flag' to 'On'.

![32](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/32.png)
![33](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/33.png)

*Note:* When done, this is how the partition table should look like.

![34](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/34.png)
![35](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/35.png)
![36](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/36.png)

*Note:* Configure the system to automatically install security updates.

![37](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/37.png)

*Note:* Only install 'OpenSSH Server'. Everything else should be deselected.

![38](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/38.png)
![39](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/39.png)

## Final words

Once you have setup the system, log in to the system and install `curl` and then run the `vmprep` script.

