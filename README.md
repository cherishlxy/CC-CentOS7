# CC-CentOS7

This directory contains the scripts used to generate the Chameleon KVM and
bare-metal CentOS 7 images. It relies on diskimage-builder.

## Installation

Images are created with the *diskimage-builder*:
http://docs.openstack.org/developer/diskimage-builder

Requirements:
- *qemu-utils* (ubuntu/debian) or *qemu* (Fedora/RHEL/opensuse).

To install dependencies on Centos, please run the following commands:

```
sudo yum install epel-release
yum install qemu-img # or apt-get install qemu-disk
pip install diskimage-builder
```

## Usage

The main script takes an output path as a unique (optional) input parameter:
```
./create-image.sh <output_file>
```

and can be used as in the following example:
```
[cc@image-builder-jpastor CC-CentOS7]$ ./create-image.sh image.qcow2
CentOS-7-x86_64-GenericCloud-1608.qcow2.xz: OK
xz: CentOS-7-x86_64-GenericCloud-1608.qcow2: File exists

[...]

Converting image using qemu-img convert
Image file image.qcow2 created...
mv image.qcow2-compressed image.qcow2
Image built in image.qcow2
to add the image in glance run the following command:
glance image-create --name "CC-CentOS7" --disk-format qcow2 --container-format bare --file image.qcow2
```

At the end of its execution, the script provides the Glance command that can be
used to upload the image to an existing OpenStack infrastructure.

The other scripts in the `elements` directory are invoked by create-image.sh.
This script does the following:

* Download a CentOS 7 cloud image from upstream
* Customize it for Chameleon (see `elements` directory for details)
* Generate an image compatible with OpenStack KVM and bare-metal

The image must then be uploaded and registered with Glance (currently done
manually, by running the Glance command given at the end of execution).
