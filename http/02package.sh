#!/bin/bash
set -ux 

dnf install -y \
chrony \
net-tools \
tar \
zip \
bzip2 \
bind-utils \
git \
patch \
gcc \
openssl-devel \
make \
net-tools \
vim \
wget \
curl \
rsync \
socat \
traceroute \
epel-release

sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=https\?://download.fedoraproject.org/pub/epel/|baseurl=https://mirror.sjtu.edu.cn/fedora/epel/|g' \
    -i.bak \
    /etc/yum.repos.d/epel*


