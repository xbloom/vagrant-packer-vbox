#!/bin/bash
set -eu

if ! command -v kubectl &> /dev/null ; then
    echo 'installing kubectl.' >&2
    curl -L "https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl" -o /tmp/kubectl && chmod 755 /tmp/kubectl
    sudo mv /tmp/kubectl /usr/bin/
fi

if ! command -v yq &> /dev/null ; then
    echo 'installing yq.' >&2
    YQ_VERSION=$(curl --silent "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep -Eo '"tag_name": "v(.*)"' | sed -E 's/.*"([^"]+)".*/\1/')
    YQ_ARCHIVE="yq_linux_amd64.tar.gz"
    echo "download => https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_ARCHIVE"
    curl -SsL "https://ghproxy.com/https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_ARCHIVE" | tar -xzf - -C /tmp/
    mv /tmp/yq_linux_amd64 /usr/bin/yq
fi