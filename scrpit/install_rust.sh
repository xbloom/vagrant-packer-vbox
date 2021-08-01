#!/bin/bash
set -e

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

mkdir -p $HOME/.cargo/

cat > $HOME/.cargo/config <<- "EOF"
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
EOF

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

dnf -y install cmake gcc openssl-devel