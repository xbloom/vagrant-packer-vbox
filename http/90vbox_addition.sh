#!/bin/bash

set -e
set -x

if [ "$PACKER_BUILDER_TYPE" != "virtualbox-iso" ]; then
  exit 0
fi

#
# packages need to install VBGA
# dnf -y install epel
# dnf -y install bzip2 elfutils-libelf-devel gcc kernel-devel-`uname -r` kernel-headers perl tar dkms
dnf -y install bzip2 elfutils-libelf-devel gcc kernel-devel kernel-headers perl tar dkms

VBOX_VERSION=$(cat ~/.vbox_version)
cd /tmp
mount -o loop,ro ~/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt/
sh /mnt/VBoxLinuxAdditions.run --nox11

umount /mnt/
rm -f ~/VBoxGuestAdditions_*.iso