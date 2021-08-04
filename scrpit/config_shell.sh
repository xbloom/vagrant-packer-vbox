#!/bin/bash
set -euxo pipefail

dnf install -y jq bash-completion

# configure the shell.


BAT_VERSION=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep -Eo '"tag_name": "v(.*)"' | sed -E 's/.*"([^"]+)".*/\1/')
BAT_RELEASE="bat-$BAT_VERSION-x86_64-unknown-linux-musl"
BAT_ARCHIVE="$BAT_RELEASE.tar.gz"
curl -SsL "https://github.com/sharkdp/bat/releases/download/$BAT_VERSION/$BAT_ARCHIVE" | tar -xzf - -C /tmp/
cp /tmp/$BAT_RELEASE/bat /usr/local/bin/bat
rm -rf /tmp/$BAT_RELEASE/

