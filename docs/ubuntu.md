# Installation instructions for Ubuntu

## Basic info

Like all pre-installed virtual machines, the machine will use:

 * A 10GB disk size
 * VirtIO for both networking and disk
 * 64bit version of Ubuntu

The screenshots were taken during an Ubuntu 12.04 installation.

## Screenshots
![0](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/0.png)
![1](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/1.png)
![2](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/2.png)
![3](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/3.png)
![3.1](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/3.1.png)
![3](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/3.png)
![5](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/5.png)
![6](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/6.png)

**Note:** It's important that you set the hostname to `ubuntu.local` or `ubuntu1204.local` such that the original hostname received from the DHCP server isn't used.

![7](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/7.png)
![8](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/8.png)
![8.1](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/8.2.png)

**Note:** Set a random password. This will be changed on first boot in the customer's environment.

![8.2](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/8.1.png)
![9](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/9.png)
![10](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/10.png)
![11](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/11.png)

**Note:** It is essential that you select `LVM` here.

![12](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/12.png)
![13](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/13.png)
![14](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/14.png)
![15](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/15.png)
![16](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/16.png)
![17](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/17.png)

**Note:** Make sure you select automatic security updates.

![18](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/18.png)

**Note:** Makes sure to select `OpenSSH server`. It is the only thing you need to select.

![19](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/19.png)
![20](https://raw.github.com/cloudsigma/vmprep/master/img/ubuntu/20.png)


## Final words

Once you have setup the system, just go ahead and run the `vmprep` script.

