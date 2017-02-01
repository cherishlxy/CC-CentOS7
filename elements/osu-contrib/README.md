# Disk Image Builder

This folder contains elements to build a KVM and SR-IOV-based appliance for the Chameleon Project. 

These elements will build a custom kernel for the image which enables IOMMU in the kernel by default. They also build a custom installation of OFED which will be installed upon the first boot of the image. In addition, KVM and necessary virtualisation packages will be installed which are necessary to launch VMs.

To use these elements, some parameters need to be specified. These include OS_VERSION and KERNEL_VERSION in 05-custom-kernel, and OFED_NAME and OFED_URl in 01-custom-ofed. Ideally, these should be set to the latest versions available, respectively. It might also be necessary to update the custom kernel config (https://github.com/shashankgugnani/chameleon.git) in case newer kernels have some updated parameters. After these parameters have been specified, the elements can be directly used by disk-image-buildes by specifying the chameleon-elements folder in the ELEMENTS_PATH.
