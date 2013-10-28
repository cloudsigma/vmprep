# Installation instructions for Debian

## Basic info

Like all pre-installed virtual machines, the machine will use:

 * A 10GB disk size
 * VirtIO for both networking and disk
 * 64bit version of Debian

The screenshots were taken during an Debian 7.2 installation.

## Screenshots

![00](https://raw.github.com/cloudsigma/vmprep/master/img/debian/00.png)
![01](https://raw.github.com/cloudsigma/vmprep/master/img/debian/01.png)
![02](https://raw.github.com/cloudsigma/vmprep/master/img/debian/02.png)

**Note:** Select the location of the data center.

![03](https://raw.github.com/cloudsigma/vmprep/master/img/debian/03.png)
![04](https://raw.github.com/cloudsigma/vmprep/master/img/debian/04.png)

**Note:** Enter 'debian72.local' as the hostname for Debian 7.2.

![05](https://raw.github.com/cloudsigma/vmprep/master/img/debian/05.png)

**Note:** Enter a strong root password (the root account will be overwritten later).

![06](https://raw.github.com/cloudsigma/vmprep/master/img/debian/06.png)
![07](https://raw.github.com/cloudsigma/vmprep/master/img/debian/07.png)
![08](https://raw.github.com/cloudsigma/vmprep/master/img/debian/08.png)
![09](https://raw.github.com/cloudsigma/vmprep/master/img/debian/09.png)
![10](https://raw.github.com/cloudsigma/vmprep/master/img/debian/10.png)
![11](https://raw.github.com/cloudsigma/vmprep/master/img/debian/11.png)
![12](https://raw.github.com/cloudsigma/vmprep/master/img/debian/12.png)

**Note:** It is essential that 'LVM' is selected here.

![13](https://raw.github.com/cloudsigma/vmprep/master/img/debian/13.png)
![14](https://raw.github.com/cloudsigma/vmprep/master/img/debian/14.png)

**Note:** Select to store all files on one partition, since this will make it easier for most users (and also simpler when expanding to LVM volume with another disk).

![15](https://raw.github.com/cloudsigma/vmprep/master/img/debian/15.png)
![16](https://raw.github.com/cloudsigma/vmprep/master/img/debian/16.png)
![17](https://raw.github.com/cloudsigma/vmprep/master/img/debian/17.png)
![18](https://raw.github.com/cloudsigma/vmprep/master/img/debian/18.png)
![19](https://raw.github.com/cloudsigma/vmprep/master/img/debian/19.png)
![20](https://raw.github.com/cloudsigma/vmprep/master/img/debian/20.png)
![21](https://raw.github.com/cloudsigma/vmprep/master/img/debian/21.png)
![22](https://raw.github.com/cloudsigma/vmprep/master/img/debian/22.png)
![23](https://raw.github.com/cloudsigma/vmprep/master/img/debian/23.png)
![24](https://raw.github.com/cloudsigma/vmprep/master/img/debian/24.png)

**Note:** Make sure to only select 'SSH server' and 'Standard system utilities.'

![25](https://raw.github.com/cloudsigma/vmprep/master/img/debian/25.png)
![26](https://raw.github.com/cloudsigma/vmprep/master/img/debian/26.png)

## Final words

Once you have setup the system, log in to the system and run the `vmprep` script.
